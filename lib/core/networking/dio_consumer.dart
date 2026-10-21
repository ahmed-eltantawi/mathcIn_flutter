import 'dart:typed_data';

import 'package:MatchIn/core/errors/error_model.dart';
import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/core/networking/api_interceptor.dart';
import 'package:MatchIn/core/networking/connectivity_cubit.dart';
import 'package:MatchIn/core/services/app_config_service.dart';
import 'package:MatchIn/core/services/secure_storage_service.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:dio/dio.dart';

/// [DioConsumer] is a class that implements the [ApiConsumer] interface
/// It Implements the main four methods [post], [get], [put], [delete]
class DioConsumer extends ApiConsumer {
  DioConsumer({
    required this.dio,
    required SecureStorageService secureStorageService,
    required SharedPreferencesService sharedPreferencesService,
    ConnectivityCubit? connectivityCubit,
  }) {
    //! =================== Configurations ===================
    // takeing base url from the centralized end point configuration
    dio.options.baseUrl = EndPoint.baseUrl;

    // adding api interceptor
    dio.interceptors.add(
      ApiInterceptor(
        dio,
        secureStorageService: secureStorageService,
        sharedPreferencesService: sharedPreferencesService,
        connectivityCubit: connectivityCubit,
      ),
    );

    // adding log interceptor
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
      ),
    );
  }

  final Dio dio; // injecting dio

  //! =================== Configuration guard ===================

  // --- No hardcoded fallback exists anywhere: a request proceeds only
  // --- with a Firestore-resolved or valid cached base URL. Otherwise it
  // --- fails fast with a recoverable error instead of hitting an
  // --- obsolete backend. Repositories map this to a Failure as usual. ---
  void _requireResolvedBaseUrl() {
    if (!AppConfigService.isValidBaseUrl(EndPoint.baseUrl)) {
      throw ServerException(
        errorModel: const ErrorModel(
          statusCode: 0,
          errorMessage: 'API configuration is unavailable. Please check your connection and try again.',
        ),
      );
    }
  }

  //! =================== Methods ===================

  //? ---------- Delete ----------
  @override
  Future delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    bool isFormData = false,
  }) async {
    _requireResolvedBaseUrl();
    try {
      final dynamic response = await dio.delete(
        path,
        queryParameters: queryParameters,
        data: isFormData ? FormData.fromMap(data) : data,
      );
      return response.data;
    } on DioException catch (e) {
      handleDioExceptions(e);
    }
  }

  //? ---------- Get ----------
  @override
  Future get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  }) async {
    _requireResolvedBaseUrl();
    try {
      final dynamic response = await dio.get(
        path,
        queryParameters: queryParameters,
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      handleDioExceptions(e);
    }
  }

  //? ---------- Post ----------
  @override
  Future post(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    bool isFormData = false,
    void Function(int sentBytes, int totalBytes)? onSendProgress,
  }) async {
    _requireResolvedBaseUrl();
    try {
      final dynamic response = await dio.post(
        path,
        queryParameters: queryParameters,
        data: isFormData ? FormData.fromMap(data) : data,
        onSendProgress: onSendProgress,
      );
      return response.data;
    } on DioException catch (e) {
      handleDioExceptions(e);
    }
  }

  //? ---------- Put ----------
  @override
  Future put(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    bool isFormData = false,
  }) async {
    _requireResolvedBaseUrl();
    try {
      final dynamic response = await dio.put(
        path,
        queryParameters: queryParameters,
        data: isFormData ? FormData.fromMap(data) : data,
      );
      return response.data;
    } on DioException catch (e) {
      handleDioExceptions(e);
    }
  }

  //? ---------- Patch ----------
  @override
  Future patch(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    bool isFormData = false,
  }) async {
    _requireResolvedBaseUrl();
    try {
      final dynamic response = await dio.patch(
        path,
        queryParameters: queryParameters,
        data: isFormData ? FormData.fromMap(data) : data,
      );
      return response.data;
    } on DioException catch (e) {
      handleDioExceptions(e);
    }
  }

  //? ---------- Download bytes ----------
  @override
  Future<({Uint8List bytes, String? fileName, String? mimeType})> downloadBytes(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    _requireResolvedBaseUrl();
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(responseType: ResponseType.bytes),
      );
      final data = response.data;
      final Uint8List bytes;
      if (data is Uint8List) {
        bytes = data;
      } else if (data is List<int>) {
        bytes = Uint8List.fromList(data);
      } else {
        throw const FormatException('Invalid binary response format');
      }
      final headers = response.headers;
      return (
        bytes: bytes,
        fileName: _fileNameFrom(headers.value('content-disposition')),
        mimeType: headers.value('content-type')?.split(';').first.trim(),
      );
    } on DioException catch (e) {
      handleDioExceptions(e);
      throw const FormatException('Invalid binary response format');
    }
  }

  /// Extracts `filename=` from a `Content-Disposition` header value.
  static String? _fileNameFrom(String? contentDisposition) {
    if (contentDisposition == null || contentDisposition.isEmpty) {
      return null;
    }
    final match = RegExp(
      'filename[^;=]*=([^;]+)',
      caseSensitive: false,
    ).firstMatch(contentDisposition);
    var name = match?.group(1)?.trim() ?? '';
    if (name.length >= 2 && name.startsWith('"') && name.endsWith('"')) {
      name = name.substring(1, name.length - 1);
    }
    // RFC 5987 encoded form: UTF-8''percent-encoded.
    final prefix = RegExp("^[^']*'[^']*'");
    if (prefix.hasMatch(name) && name.contains('%')) {
      try {
        final decoded = Uri.decodeComponent(name.replaceFirst(prefix, ''));
        if (decoded.trim().isNotEmpty) name = decoded.trim();
      } catch (_) {
        // Keep the raw token when decoding fails.
      }
    }
    return name.isEmpty ? null : name;
  }
}
