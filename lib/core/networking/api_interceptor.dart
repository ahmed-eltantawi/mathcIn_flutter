import 'dart:async';

import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/core/services/secure_storage_service.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:dio/dio.dart';

import 'package:MatchIn/core/networking/connectivity_cubit.dart';

///* APi interceptor used to handle api requests
///* It will add access token in request header
///* and refresh token if access token is expired
///* It will also handle api errors
class ApiInterceptor extends Interceptor {
  ApiInterceptor(
    this.dio, {
    required this.secureStorageService,
    required this.sharedPreferencesService,
    this.connectivityCubit,
  });

  final Dio dio;
  final SecureStorageService secureStorageService;
  final SharedPreferencesService sharedPreferencesService;
  final ConnectivityCubit? connectivityCubit;

  // This Completer prevent multiple refresh token requests
  static Completer<bool>? _refreshCompleter;

  ///! ======================= on request =======================
  /// This will be called before each request
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await secureStorageService.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers[ApiHeaderKey.authorization] =
          ApiHeaderKey.getAuthorizationValue(accessToken: accessToken);
    }

    // add app language in request header (API expects 'en' | 'ar')
    final langCode = sharedPreferencesService.getLanguageCode();
    options.headers[ApiHeaderKey.acceptLanguage] =
        langCode.toLowerCase().startsWith('ar') ? 'ar' : 'en';

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    connectivityCubit?.reportNetworkSuccess();
    super.onResponse(response, handler);
  }

  ///! ======================= on error =======================
  /// This will be called when request throw error
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isTimeout =
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout;
    final isOffline = err.type == DioExceptionType.connectionError;

    if (isTimeout || isOffline) {
      connectivityCubit?.reportNetworkError(isTimeout: isTimeout);
    }

    // if error is not unauthorized return normal error
    if (err.response?.statusCode != 401) {
      return super.onError(err, handler);
    }

    // if request is public request don't refresh token
    if (_isPublicRequest(err.requestOptions)) {
      return handler.next(err);
    }

    // if refresh request already running wait for result
    if (_refreshCompleter != null) {
      final success = await _refreshCompleter!.future;

      // if refresh success retry failed request
      if (success) {
        final accessToken = await secureStorageService.getAccessToken();

        // update authorization header with new token
        err.requestOptions.headers[ApiHeaderKey.authorization] =
            ApiHeaderKey.getAuthorizationValue(accessToken: accessToken);

        try {
          // retry old request
          final response = await dio.fetch(err.requestOptions);

          return handler.resolve(response);
        } on DioException {
          return handler.next(err);
        }
      } else {
        return handler.next(err);
      }
    }

    // create new completer for refresh token request
    _refreshCompleter = Completer<bool>();

    // get refresh token from secure storage
    final refreshToken = await secureStorageService.getRefreshToken();

    // if refresh token is null logout user
    if (refreshToken == null) {
      _refreshCompleter!.complete(false);
      _refreshCompleter = null;

      await _performLogout();

      return handler.next(err);
    }

    try {
      // create new dio instance for refresh token request, following the
      // same centralized configuration as every other API request
      final refreshDio = Dio(BaseOptions(baseUrl: EndPoint.baseUrl));

      // call refresh token endpoint
      final response = await refreshDio.post(
        EndPoint.refreshToken,
        data: {ApiKey.refreshToken: refreshToken},
      );

      // extract new tokens from response
      final newAccessToken = response.data[ApiKey.accessToken] as String;

      final newRefreshToken = response.data[ApiKey.refreshToken] as String;

      // save new tokens in secure storage
      await secureStorageService.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      // complete refresh request successfully
      _refreshCompleter!.complete(true);
      _refreshCompleter = null;

      // update authorization header with new access token
      err.requestOptions.headers[ApiHeaderKey.authorization] =
          ApiHeaderKey.getAuthorizationValue(accessToken: newAccessToken);

      // retry old request with new token
      final retryResponse = await dio.fetch(err.requestOptions);

      return handler.resolve(retryResponse);
    } catch (e) {
      // if refresh token request failed logout user
      _refreshCompleter!.complete(false);
      _refreshCompleter = null;

      await _performLogout();

      return handler.next(err);
    }
  }

  /// check if request is public request
  bool _isPublicRequest(RequestOptions options) {
    final path = _normalizePath(options.path);

    return path == _normalizePath(EndPoint.login) ||
        path == _normalizePath(EndPoint.register) ||
        path == _normalizePath(EndPoint.refreshToken) ||
        path == _normalizePath(EndPoint.verifyEmailOtp) ||
        path == _normalizePath(EndPoint.resendEmailOtp) ||
        path == _normalizePath(EndPoint.forgotPassword) ||
        path == _normalizePath(EndPoint.verifyPasswordResetOtp) ||
        path == _normalizePath(EndPoint.resetPassword);
  }

  /// normalize path to compare endpoints correctly
  String _normalizePath(String path) {
    final normalizedPath = path.startsWith(EndPoint.baseUrl)
        ? path.substring(EndPoint.baseUrl.length)
        : path;

    // remove last slash if exist
    if (normalizedPath.endsWith('/')) {
      return normalizedPath.substring(0, normalizedPath.length - 1);
    }

    return normalizedPath;
  }

  /// clear local auth data and logout user.
  /// Guest mode has no session: a 401 must not wipe the guest flag
  /// (otherwise "Continue as Guest" stops working after home fires API
  /// calls without a token) and must not broadcast a logout event.
  Future<void> _performLogout() async {
    final isGuest = sharedPreferencesService.isGuest();
    await sharedPreferencesService.clearAuthData();

    await secureStorageService.deleteTokens();

    if (!isGuest) {
      AuthEventBus.instance.addEvent(AuthEvent.logout);
    }
  }
}

enum AuthEvent { logout }

///! ======================= auth event bus =======================
class AuthEventBus {
  AuthEventBus._();

  static final AuthEventBus instance = AuthEventBus._();

  final _streamController = StreamController<AuthEvent>.broadcast();

  Stream<AuthEvent> get stream => _streamController.stream;

  /// add new auth event to stream
  void addEvent(AuthEvent event) {
    if (!_streamController.isClosed) {
      _streamController.add(event);
    }
  }

  /// close stream controller
  void close() => _streamController.close();
}
