import 'dart:async';

import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/services/app_config_service.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeBaseUrlProvider implements BaseUrlProvider {
  FakeBaseUrlProvider({this.url, this.error});

  String? url;
  Object? error;

  @override
  Future<String?> fetchBaseUrl() async {
    if (error != null) {
      throw error!;
    }
    return url;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferencesService preferencesService;
  late FakeBaseUrlProvider provider;
  late AppConfigService configService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    preferencesService = SharedPreferencesService(
      SharedPreferencesHelper(preferences: prefs),
    );
    provider = FakeBaseUrlProvider();
    configService = AppConfigService(
      sharedPreferencesService: preferencesService,
      baseUrlProvider: provider,
    );
  });

  group('AppConfigService.isValidBaseUrl', () {
    test('accepts https urls with and without trailing slash', () {
      expect(
        AppConfigService.isValidBaseUrl('https://backend.example.com/api/'),
        isTrue,
      );
      expect(
        AppConfigService.isValidBaseUrl('https://example.com/api'),
        isTrue,
      );
    });

    test('accepts http urls', () {
      expect(
        AppConfigService.isValidBaseUrl('http://localhost:8080/api/'),
        isTrue,
      );
    });

    test('rejects null, empty, and blank values', () {
      expect(AppConfigService.isValidBaseUrl(null), isFalse);
      expect(AppConfigService.isValidBaseUrl(''), isFalse);
      expect(AppConfigService.isValidBaseUrl('   '), isFalse);
    });

    test('rejects relative paths and non-http schemes', () {
      expect(AppConfigService.isValidBaseUrl('jobs'), isFalse);
      expect(AppConfigService.isValidBaseUrl('/api/v1'), isFalse);
      expect(AppConfigService.isValidBaseUrl('example.com/api/'), isFalse);
      expect(AppConfigService.isValidBaseUrl('ftp://example.com/'), isFalse);
      expect(AppConfigService.isValidBaseUrl('not a url'), isFalse);
    });

    test('rejects urls without a host', () {
      expect(AppConfigService.isValidBaseUrl('https://'), isFalse);
      expect(AppConfigService.isValidBaseUrl('https:///api'), isFalse);
    });
  });

  group('AppConfigService.normalizeBaseUrl', () {
    test('keeps a trailing slash as is', () {
      expect(
        AppConfigService.normalizeBaseUrl('https://example.com/api/'),
        'https://example.com/api/',
      );
    });

    test('appends a missing trailing slash', () {
      expect(
        AppConfigService.normalizeBaseUrl('https://example.com/api'),
        'https://example.com/api/',
      );
    });

    test('trims surrounding whitespace', () {
      expect(
        AppConfigService.normalizeBaseUrl('  https://example.com/api  '),
        'https://example.com/api/',
      );
    });
  });

  group('AppConfigService.refresh with a valid Firebase url', () {
    test('returns the normalized url and caches it', () async {
      provider.url = 'https://firebase.example/api';

      final result = await configService.refresh();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('refresh should succeed with a valid url'),
        (url) => expect(url, 'https://firebase.example/api/'),
      );
      expect(
        preferencesService.getApiBaseUrl(),
        'https://firebase.example/api/',
      );
      expect(configService.currentBaseUrl, 'https://firebase.example/api/');
    });
  });

  group('AppConfigService.refresh with a missing document', () {
    test('reports a failure and keeps the cached url', () async {
      await preferencesService.saveApiBaseUrl('https://cached.example/api/');
      provider.url = null;

      final result = await configService.refresh();

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, contains('not configured'));
      }, (_) => fail('refresh should fail when the document is missing'));
      // --- A failed fetch must never wipe a valid cached url ---
      expect(configService.currentBaseUrl, 'https://cached.example/api/');
    });
  });

  group('AppConfigService.refresh when Firestore fails', () {
    test('maps offline errors to OfflineFailure', () async {
      provider.error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
      );

      final result = await configService.refresh();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<OfflineFailure>()),
        (_) => fail('refresh should fail when Firestore is unavailable'),
      );
    });

    test('maps timeouts to OfflineFailure', () async {
      provider.error = TimeoutException('fetch timed out');

      final result = await configService.refresh();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<OfflineFailure>()),
        (_) => fail('refresh should fail on timeout'),
      );
    });

    test('maps permission errors to ServerFailure', () async {
      provider.error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'Missing or insufficient permissions.',
      );

      final result = await configService.refresh();

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, isNotEmpty);
      }, (_) => fail('refresh should fail on permission errors'));
    });

    test('reports Firebase init failures without throwing', () async {
      final offlineService = AppConfigService(
        sharedPreferencesService: preferencesService,
        baseUrlProvider: FirestoreBaseUrlProvider(),
      );

      final result = await offlineService.refresh();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, isNotEmpty),
        (_) => fail('refresh should fail without Firebase'),
      );
    });
  });

  group('AppConfigService.refresh with an empty or invalid url', () {
    test('rejects empty values and keeps the cache', () async {
      await preferencesService.saveApiBaseUrl('https://cached.example/api/');
      provider.url = '   ';

      final result = await configService.refresh();

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, contains('invalid'));
      }, (_) => fail('refresh should fail on empty urls'));
      expect(configService.currentBaseUrl, 'https://cached.example/api/');
    });

    test('rejects non-http urls and keeps the cache', () async {
      await preferencesService.saveApiBaseUrl('https://cached.example/api/');
      provider.url = 'ftp://files.example/api/';

      final result = await configService.refresh();

      expect(result.isLeft(), isTrue);
      expect(configService.currentBaseUrl, 'https://cached.example/api/');
    });
  });

  group('AppConfigService.currentBaseUrl priority', () {
    test('prefers a valid cached url', () async {
      await preferencesService.saveApiBaseUrl('https://cached.example/api');
      expect(configService.currentBaseUrl, 'https://cached.example/api/');
      expect(configService.hasCachedBaseUrl, isTrue);
    });

    // --- No hardcoded fallback exists: null means no request may be sent ---
    test('returns null when nothing is cached', () {
      expect(configService.currentBaseUrl, isNull);
      expect(configService.hasCachedBaseUrl, isFalse);
    });

    test('returns null for an invalid cached value', () async {
      await preferencesService.saveApiBaseUrl('not-a-url');
      expect(configService.currentBaseUrl, isNull);
      expect(configService.hasCachedBaseUrl, isFalse);
    });
  });
}
