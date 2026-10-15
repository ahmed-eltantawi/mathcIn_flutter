import 'dart:typed_data';

import 'package:MatchIn/core/cache/secure_storage_helper.dart';
import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/core/networking/dio_consumer.dart';
import 'package:MatchIn/core/services/secure_storage_service.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _CaptureAdapter implements HttpClientAdapter {
  _CaptureAdapter({this.statusCode = 200});

  final int statusCode;
  Uri? capturedUri;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    capturedUri = options.uri;
    if (statusCode == 200) {
      return ResponseBody.fromString('{}', 200);
    }
    return ResponseBody.fromString(
      '{"message":"Unauthenticated."}',
      statusCode,
    );
  }

  @override
  void close({bool force = false}) {}
}

class _FakeSecureStorageService
    extends SecureStorageService {
  _FakeSecureStorageService()
    : super(SecureStorageHelper());

  @override
  Future<String?> getAccessToken() async => null;

  @override
  Future<String?> getRefreshToken() async => null;

  @override
  Future<void> deleteTokens() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferencesService preferencesService;
  late _CaptureAdapter adapter;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    preferencesService = SharedPreferencesService(
      SharedPreferencesHelper(preferences: prefs),
    );
    adapter = _CaptureAdapter();
  });

  DioConsumer buildConsumer() {
    final dio = Dio()..httpClientAdapter = adapter;
    return DioConsumer(
      dio: dio,
      secureStorageService: _FakeSecureStorageService(),
      sharedPreferencesService: preferencesService,
    );
  }

  group('DioConsumer centralized base URL', () {
    test('uses the configured EndPoint base URL', () async {
      await buildConsumer().get('jobs');

      expect(
        adapter.capturedUri.toString(),
        Uri.parse(EndPoint.baseUrl)
            .resolve('jobs')
            .toString(),
      );
    });

    test(
      'the interceptor never overrides the centralized URL',
      () async {
        // --- Even with a different valid value cached, requests follow
        // --- EndPoint instead of any configuration-manager behavior. ---
        await preferencesService.saveApiBaseUrl(
          'https://cached.example/api/',
        );

        await buildConsumer().get('jobs');

        expect(
          adapter.capturedUri.toString(),
          Uri.parse(EndPoint.baseUrl)
              .resolve('jobs')
              .toString(),
        );
      },
    );

    test('token refresh follows the same centralized configuration', () async {
      adapter = _CaptureAdapter(statusCode: 401);
      final consumer = buildConsumer();

      // --- No refresh token: interceptor logs out and forwards the 401
      // --- without creating a differently-configured Dio instance. ---
      await expectLater(
        consumer.get('jobs'),
        throwsA(isA<ServerException>()),
      );
      expect(
        consumer.dio.options.baseUrl,
        EndPoint.baseUrl,
      );
    });
  });
}
