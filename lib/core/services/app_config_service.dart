import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';

///* AppConfigService: runtime API base-url configuration.
///* Fetches the base URL through [BaseUrlProvider] (Firestore in production),
///* validates it, caches the last valid value locally, and serves it
///* synchronously so networking never blocks on a remote fetch. A valid
///* cached value is never overwritten by a missing, empty, or invalid one.
///* Priority: Firebase Firestore > valid cache. Null means no valid
///* configuration is available and no request may be sent.
class AppConfigService {
  AppConfigService({
    required this.sharedPreferencesService,
    required this.baseUrlProvider,
  });

  final SharedPreferencesService sharedPreferencesService;
  final BaseUrlProvider baseUrlProvider;

  //! ===== Current base URL =====

  // --- Synchronous snapshot of the valid cache, or null when no valid
  // --- configuration exists. There is no fallback URL by design. ---
  String? get currentBaseUrl {
    final cached = sharedPreferencesService.getApiBaseUrl();
    if (isValidBaseUrl(cached)) {
      return normalizeBaseUrl(cached!);
    }
    return null;
  }

  bool get hasCachedBaseUrl =>
      isValidBaseUrl(sharedPreferencesService.getApiBaseUrl());

  //! ===== Remote refresh =====

  // --- Fetches remote config; persists only valid values ---
  Future<Either<Failure, String>> refresh() async {
    try {
      final String? rawUrl = await baseUrlProvider.fetchBaseUrl();

      // --- Never overwrite a valid cached URL with an invalid value ---
      if (rawUrl == null) {
        return const Left(
          ServerFailure(message: 'Remote API base URL is not configured'),
        );
      }
      if (!isValidBaseUrl(rawUrl)) {
        return const Left(
          ServerFailure(message: 'Remote API base URL is invalid'),
        );
      }

      final normalized = normalizeBaseUrl(rawUrl);
      await sharedPreferencesService.saveApiBaseUrl(normalized);
      return Right(normalized);
    } on TimeoutException {
      return const Left(
        OfflineFailure(message: 'API configuration fetch timed out'),
      );
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
        return const Left(
          OfflineFailure(
            message: 'Device is offline; keeping cached API base URL',
          ),
        );
      }
      return Left(
        ServerFailure(
          message: 'Failed to load API configuration: ${e.message ?? e.code}',
        ),
      );
    } catch (e) {
      log('AppConfigService.refresh error: $e');
      return const Left(
        ServerFailure(
          message: 'Unexpected error while loading API configuration',
        ),
      );
    }
  }

  //! ===== Validation =====

  static bool isValidBaseUrl(String? url) {
    if (url == null) {
      return false;
    }
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      return false;
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.isAbsolute) {
      return false;
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return false;
    }
    return uri.host.isNotEmpty;
  }

  static String normalizeBaseUrl(String url) {
    final trimmed = url.trim();
    return trimmed.endsWith('/') ? trimmed : '$trimmed/';
  }
}

///* Abstraction over the remote base-url source so the service depends on
///* an interface (dependency inversion) and stays testable without Firebase.
abstract class BaseUrlProvider {
  /// Returns the raw configured URL, or null when it is not configured.
  Future<String?> fetchBaseUrl();
}

///* Production [BaseUrlProvider] reading `consts/base_url.base_url`.
class FirestoreBaseUrlProvider implements BaseUrlProvider {
  FirestoreBaseUrlProvider({
    this.firestore,
    this.fetchTimeout = const Duration(seconds: 8),
  });

  final FirebaseFirestore? firestore;
  final Duration fetchTimeout;

  @override
  Future<String?> fetchBaseUrl() async {
    // --- Firebase failures must never crash the caller or block startup ---
    if (Firebase.apps.isEmpty) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'app-not-initialized',
        message: 'Firebase is not initialized; keeping cached API base URL',
      );
    }

    final db = firestore ?? FirebaseFirestore.instance;

    final snapshot = await db
        .collection(AppConfigKey.collection)
        .doc(AppConfigKey.document)
        .get(const GetOptions(source: Source.serverAndCache))
        .timeout(fetchTimeout);

    final Map<String, dynamic>? data = snapshot.data();
    final Object? rawUrl = data?[AppConfigKey.field];
    return rawUrl is String ? rawUrl : null;
  }
}

//* Firestore location of the runtime API base-url configuration.
abstract class AppConfigKey {
  static const String collection = 'consts';
  static const String document = 'base_url';
  static const String field = 'base_url';
}
