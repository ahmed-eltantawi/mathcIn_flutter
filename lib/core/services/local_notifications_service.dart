import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

///* [LocalNotificationService] renders push messages while the app is open.
///* Firebase does not display anything automatically in the foreground, so
///* FCM messages are re-surfaced here through a single Android channel.
///* Taps are forwarded as payload strings through [onTap]; navigation
///* decisions stay in [PushNotificationsService].
class LocalNotificationService {
  LocalNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static final StreamController<String?> _tapController =
      StreamController<String?>.broadcast();

  static Stream<String?> get onTap => _tapController.stream;

  static bool _initialized = false;

  //! ===== Channel =====
  static const String channelId = 'matchin_default';
  static const String channelName = 'MatchIn notifications';
  static const String channelDescription = 'MatchIn push notifications';

  ///! =========== initialize the local notification plugin ===========
  static Future<void> init() async {
    if (_initialized) {
      return;
    }

    try {
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );

      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: _onTap,
      );

      // --- Android 8+ requires a channel before anything is shown ---
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDescription,
          importance: Importance.high,
        ),
      );

      // --- Android 13+ requires a runtime permission to post ---
      await android?.requestNotificationsPermission();

      _initialized = true;
    } catch (e) {
      log('LocalNotificationService.init error: $e');
    }
  }

  //! ======= show a foreground message as a local notification ========
  static Future<void> showFromMessage(RemoteMessage message) async {
    try {
      final title =
          message.notification?.title ?? message.data['title']?.toString();
      final body =
          message.notification?.body ?? message.data['body']?.toString();

      // --- Skip empty payloads so nothing blank or duplicated is shown ---
      if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
        return;
      }

      const android = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      );
      const darwin = DarwinNotificationDetails();
      const details = NotificationDetails(android: android, iOS: darwin);

      final int notificationId =
          message.messageId?.hashCode ??
          (DateTime.now().millisecondsSinceEpoch % 100000);

      await _plugin.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: details,
        payload: _encodePayload(message.data),
      );
    } catch (e) {
      log('LocalNotificationService.showFromMessage error: $e');
    }
  }

  //! ======= payload of the tap that launched a terminated app ========
  static Future<String?> consumeLaunchPayload() async {
    try {
      final launchDetails = await _plugin.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        return launchDetails?.notificationResponse?.payload;
      }
    } catch (e) {
      log('LocalNotificationService.consumeLaunchPayload error: $e');
    }
    return null;
  }

  //! ======= Releases all resources held by this service ========
  static Future<void> dispose() async {
    _initialized = false;
    if (!_tapController.isClosed) {
      await _tapController.close();
    }
  }

  //! ======= handle notification taps =======
  static void _onTap(NotificationResponse response) {
    if (!_tapController.isClosed) {
      _tapController.add(response.payload);
    }
  }

  static String _encodePayload(Map<String, dynamic> data) {
    try {
      return jsonEncode(data);
    } catch (e) {
      log('LocalNotificationService._encodePayload error: $e');
      return '';
    }
  }
}
