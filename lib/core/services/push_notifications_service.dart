import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:MatchIn/core/routing/app_router.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/services/local_notifications_service.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';

///* [PushNotificationsService] owns Firebase Cloud Messaging plumbing.
///* FCM only *delivers* pushes; the backend notification inbox (list,
///* unread count, mark-as-read) is untouched and keeps working as before.
///* The FCM token is persisted locally only — the backend currently
///* exposes no documented device-token endpoint, so nothing is uploaded.
class PushNotificationsService {
  PushNotificationsService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static SharedPreferencesService? _storage;
  static StreamSubscription<String>? _tokenRefreshSub;
  static StreamSubscription<RemoteMessage>? _foregroundSub;
  static StreamSubscription<RemoteMessage>? _openedAppSub;
  static StreamSubscription<String?>? _localTapSub;
  static RemoteMessage? _pendingInitialMessage;
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  //! ===== Routes a push tap is allowed to open =====
  // --- Deliberately narrow: deep links needing extras (e.g. job
  // --- details) fall back to the notification center instead. ---
  static const List<String> _allowedRoutes = [
    AppRoutes.knotifications,
    AppRoutes.kHomeView,
  ];

  ///! ======================= init =======================
  // --- Never blocks startup: every step degrades gracefully. ---
  static Future<void> init({required SharedPreferencesService storage}) async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    _storage = storage;

    try {
      await LocalNotificationService.init();

      // --- Ask for permission; denial only disables display, not setup ---
      try {
        await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      } catch (e) {
        log('PushNotificationsService.requestPermission error: $e');
      }

      // --- iOS needs this to present anything while foregrounded ---
      if (Platform.isIOS) {
        try {
          await _messaging.setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
        } catch (e) {
          log('PushNotificationsService.iosOptions error: $e');
        }
      }

      // --- System shows background notification-messages itself, so the
      // --- background handler only re-initializes Firebase. Foreground
      // --- messages are re-surfaced through LocalNotificationService,
      // --- which guarantees no duplicate notifications. ---
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // --- Persist the token locally and keep it fresh ---
      try {
        final token = await _messaging.getToken();
        if (token != null && token.isNotEmpty) {
          await _persistToken(token);
        }
      } catch (e) {
        log('PushNotificationsService.getToken error: $e');
      }
      _tokenRefreshSub = _messaging.onTokenRefresh.listen(
        _persistToken,
        onError: (Object e) =>
            log('PushNotificationsService.onTokenRefresh error: $e'),
      );

      // --- Foreground: display via local notifications ---
      _foregroundSub = FirebaseMessaging.onMessage.listen(
        _handleForegroundMessage,
        onError: (Object e) =>
            log('PushNotificationsService.onMessage error: $e'),
      );

      // --- Background tap: app is resumed through the push ---
      _openedAppSub = FirebaseMessaging.onMessageOpenedApp.listen(
        _handleNotificationTap,
        onError: (Object e) =>
            log('PushNotificationsService.onMessageOpenedApp error: $e'),
      );

      // --- Foreground local-notification taps ---
      _localTapSub = LocalNotificationService.onTap.listen(
        _handleLocalTapPayload,
        onError: (Object e) =>
            log('PushNotificationsService.localTap error: $e'),
      );

      // --- Terminated: FCM tap that launched the app ---
      try {
        _pendingInitialMessage = await _messaging.getInitialMessage();
      } catch (e) {
        log('PushNotificationsService.getInitialMessage error: $e');
      }

      // --- Terminated: local-notification tap that launched the app ---
      String? launchPayload;
      try {
        launchPayload = await LocalNotificationService.consumeLaunchPayload();
      } catch (e) {
        log('PushNotificationsService.consumeLaunchPayload error: $e');
      }

      // --- Navigate once the first frame (and the router) is ready ---
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final initial = _pendingInitialMessage;
        _pendingInitialMessage = null;
        if (initial != null) {
          _handleNotificationTap(initial);
        } else if (launchPayload != null && launchPayload.isNotEmpty) {
          _handleLocalTapPayload(launchPayload);
        }
      });
    } catch (e) {
      log('PushNotificationsService.init error: $e');
    }
  }

  //! ======= last FCM token persisted on this device =======
  static String? get cachedToken => _storage?.getFcmToken();

  //! ======= Releases all listeners held by this service =======
  static Future<void> dispose() async {
    _initialized = false;
    _storage = null;
    _pendingInitialMessage = null;
    await _tokenRefreshSub?.cancel();
    await _foregroundSub?.cancel();
    await _openedAppSub?.cancel();
    await _localTapSub?.cancel();
    _tokenRefreshSub = null;
    _foregroundSub = null;
    _openedAppSub = null;
    _localTapSub = null;
    await LocalNotificationService.dispose();
  }

  //! ======= foreground message: re-surface locally =======
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      // --- Honor the in-app notification preference ---
      if (_storage?.isNotificationsEnabled() == false) {
        return;
      }
      await LocalNotificationService.showFromMessage(message);
    } catch (e) {
      log('PushNotificationsService._handleForegroundMessage error: $e');
    }
  }

  //! ======= background/resume tap =======
  static void _handleNotificationTap(RemoteMessage message) {
    _handleDataTap(message.data);
  }

  //! ======= local-notification tap =======
  static void _handleLocalTapPayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      _handleDataTap(const {});
      return;
    }
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        _handleDataTap(decoded);
        return;
      }
    } catch (e) {
      log('PushNotificationsService._handleLocalTapPayload error: $e');
    }
    _handleDataTap(const {});
  }

  //! ======= resolve a tap payload into a guarded route =======
  static void _handleDataTap(Map<String, dynamic> data) {
    try {
      final isLoggedIn = _storage?.isLoggedIn() ?? false;

      final requested = data['route']?.toString();
      var target = AppRoutes.knotifications;
      if (requested != null && _allowedRoutes.contains(requested)) {
        target = requested;
      }

      // --- The inbox API needs an auth token, so signed-out users and
      // --- guests never land on it; they fall back to home instead. ---
      if (target == AppRoutes.knotifications && !isLoggedIn) {
        target = AppRoutes.kHomeView;
      }

      AppRouter.router.go(target);
    } catch (e) {
      log('PushNotificationsService._handleDataTap error: $e');
    }
  }

  //! ======= persist the FCM token locally (no backend endpoint) =======
  static Future<void> _persistToken(String token) async {
    try {
      if (_storage?.getFcmToken() == token) {
        return;
      }
      await _storage?.saveFcmToken(token);
    } catch (e) {
      log('PushNotificationsService._persistToken error: $e');
    }
  }
}

///* Background-isolate entry point for terminated/background messages.
///* Must stay top-level with the entry-point pragma so tree-shaking keeps it.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
