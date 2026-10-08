import 'dart:convert';
import 'package:MatchIn/core/cache/cache_key.dart';
import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/features/notification/data/datasources/notification_local_data_source.dart';
import 'package:MatchIn/features/notification/data/models/notification_model.dart';

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  const NotificationLocalDataSourceImpl({
    required this.sharedPreferencesHelper,
  });

  final SharedPreferencesHelper sharedPreferencesHelper;

  static const String _notificationsKey =
      '${CacheKey.notificationsPrefix}cached_list';

  @override
  Future<List<NotificationModel>> getCachedNotifications({
    bool? unreadOnly,
  }) async {
    final rawJson = sharedPreferencesHelper.getString(key: _notificationsKey);
    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is List) {
        final list = decoded
            .whereType<Map<String, dynamic>>()
            .map((map) => NotificationModel.fromJson(map))
            .toList();

        if (unreadOnly == true) {
          return list.where((n) => !n.isRead).toList();
        }
        return list;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveNotifications(
    List<NotificationModel> notifications, {
    bool replace = false,
  }) async {
    List<NotificationModel> finalList;

    if (replace) {
      finalList = notifications;
    } else {
      final existing = await getCachedNotifications();
      final map = <int, NotificationModel>{};

      // Put existing first
      for (final n in existing) {
        map[n.id] = n;
      }
      // Overwrite/insert new items
      for (final n in notifications) {
        map[n.id] = n;
      }

      // Preserve newest first ordering
      finalList = map.values.toList();
    }

    final encoded = jsonEncode(finalList.map((n) => n.toJson()).toList());
    await sharedPreferencesHelper.saveData(
      key: _notificationsKey,
      value: encoded,
    );

    final unread = finalList.where((n) => !n.isRead).length;
    await saveUnreadCount(unread);
  }

  @override
  Future<NotificationModel?> markNotificationAsReadLocally(int id) async {
    final list = await getCachedNotifications();
    NotificationModel? updatedModel;

    final updatedList = list.map((item) {
      if (item.id == id) {
        updatedModel = NotificationModel(
          id: item.id,
          type: item.type,
          title: item.title,
          message: item.message,
          readAt: DateTime.now().toIso8601String(),
          isRead: true,
          createdAt: item.createdAt,
          data: item.data,
        );
        return updatedModel!;
      }
      return item;
    }).toList();

    await saveNotifications(updatedList, replace: true);
    return updatedModel;
  }

  @override
  Future<int> markAllNotificationsAsReadLocally() async {
    final list = await getCachedNotifications();
    int count = 0;

    final nowIso = DateTime.now().toIso8601String();
    final updatedList = list.map((item) {
      if (!item.isRead) {
        count++;
        return NotificationModel(
          id: item.id,
          type: item.type,
          title: item.title,
          message: item.message,
          readAt: nowIso,
          isRead: true,
          createdAt: item.createdAt,
          data: item.data,
        );
      }
      return item;
    }).toList();

    await saveNotifications(updatedList, replace: true);
    await saveUnreadCount(0);
    return count;
  }

  @override
  Future<int> getCachedUnreadCount() async {
    final list = await getCachedNotifications();
    if (list.isNotEmpty) {
      return list.where((n) => !n.isRead).length;
    }

    final raw = sharedPreferencesHelper.getString(
      key: CacheKey.unreadNotificationsCount,
    );
    return int.tryParse(raw ?? '') ?? 0;
  }

  @override
  Future<void> saveUnreadCount(int count) async {
    await sharedPreferencesHelper.saveData(
      key: CacheKey.unreadNotificationsCount,
      value: count.toString(),
    );
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferencesHelper.deleteData(key: _notificationsKey);
    await sharedPreferencesHelper.deleteData(
      key: CacheKey.unreadNotificationsCount,
    );
  }
}
