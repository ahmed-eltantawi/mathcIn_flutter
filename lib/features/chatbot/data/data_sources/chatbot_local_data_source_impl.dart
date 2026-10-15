import 'dart:convert';
import 'package:MatchIn/core/cache/cache_key.dart';
import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import '../models/chat_message_model.dart';
import '../models/chat_model.dart';
import 'chatbot_local_data_source.dart';

class ChatbotLocalDataSourceImpl implements ChatbotLocalDataSource {
  ChatbotLocalDataSourceImpl({required this.sharedPreferencesHelper});

  final SharedPreferencesHelper sharedPreferencesHelper;

  String _sessionsKey(String? userId) =>
      userId != null && userId.isNotEmpty
          ? '${CacheKey.chatSessions}_$userId'
          : CacheKey.chatSessions;

  String _messagesKey(String chatId, String? userId) =>
      userId != null && userId.isNotEmpty
          ? '${CacheKey.chatMessagesPrefix}${userId}_$chatId'
          : '${CacheKey.chatMessagesPrefix}$chatId';

  @override
  Future<List<ChatModel>> getChatSessions({String? userId}) async {
    final key = _sessionsKey(userId);
    final rawList = sharedPreferencesHelper.getStringList(key: key);
    if (rawList == null || rawList.isEmpty) {
      return [];
    }

    final List<ChatModel> sessions = [];
    for (final rawJson in rawList) {
      try {
        final map = jsonDecode(rawJson) as Map<String, dynamic>;
        final chatWithoutMessages = ChatModel.fromJson(map);

        final mKey = _messagesKey(chatWithoutMessages.id, userId);
        final messagesRaw = sharedPreferencesHelper.getStringList(key: mKey);

        final messagesList = messagesRaw != null
            ? messagesRaw
                .map((m) => ChatMessageModel.fromJson(
                    jsonDecode(m) as Map<String, dynamic>))
                .toList()
            : <ChatMessageModel>[];

        sessions.add(ChatModel.fromEntity(
          chatWithoutMessages.copyWith(messages: messagesList),
        ));
      } catch (_) {
        // Skip malformed items
      }
    }

    sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sessions;
  }

  @override
  Future<ChatModel?> getChatSession(String chatId, {String? userId}) async {
    final sessions = await getChatSessions(userId: userId);
    try {
      return sessions.firstWhere((s) => s.id == chatId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveChatSession(ChatModel chat, {String? userId}) async {
    final key = _sessionsKey(userId);
    final rawList = sharedPreferencesHelper.getStringList(key: key) ?? [];

    final List<Map<String, dynamic>> sessionMaps = [];
    for (final s in rawList) {
      try {
        sessionMaps.add(jsonDecode(s) as Map<String, dynamic>);
      } catch (_) {}
    }

    final existingIndex = sessionMaps.indexWhere((m) => m['id'] == chat.id);
    final sessionHeader = ChatModel(
      id: chat.id,
      title: chat.title,
      createdAt: chat.createdAt,
      updatedAt: chat.updatedAt,
      messages: const [],
      isArchived: chat.isArchived,
      jobPostId: chat.jobPostId,
      contextMode: chat.contextMode,
    ).toJson();

    if (existingIndex >= 0) {
      sessionMaps[existingIndex] = sessionHeader;
    } else {
      sessionMaps.insert(0, sessionHeader);
    }

    final updatedRawList = sessionMaps.map((m) => jsonEncode(m)).toList();
    await sharedPreferencesHelper.saveData(
      key: key,
      value: updatedRawList,
    );

    final mKey = _messagesKey(chat.id, userId);
    final messagesRaw = chat.messages
        .map((m) => jsonEncode(ChatMessageModel.fromEntity(m).toJson()))
        .toList();

    await sharedPreferencesHelper.saveData(
      key: mKey,
      value: messagesRaw,
    );
  }

  @override
  Future<void> saveAllChatSessions(List<ChatModel> chats, {String? userId}) async {
    for (final chat in chats) {
      await saveChatSession(chat, userId: userId);
    }
  }

  @override
  Future<void> deleteChatSession(String chatId, {String? userId}) async {
    final key = _sessionsKey(userId);
    final rawList = sharedPreferencesHelper.getStringList(key: key) ?? [];
    final List<Map<String, dynamic>> sessionMaps = [];
    for (final s in rawList) {
      try {
        sessionMaps.add(jsonDecode(s) as Map<String, dynamic>);
      } catch (_) {}
    }

    sessionMaps.removeWhere((m) => m['id'] == chatId);

    final updatedRawList = sessionMaps.map((m) => jsonEncode(m)).toList();
    await sharedPreferencesHelper.saveData(
      key: key,
      value: updatedRawList,
    );

    final mKey = _messagesKey(chatId, userId);
    await sharedPreferencesHelper.deleteData(key: mKey);
  }

  @override
  Future<void> clearAllChatSessions({String? userId}) async {
    final key = _sessionsKey(userId);
    final rawList = sharedPreferencesHelper.getStringList(key: key) ?? [];
    for (final rawJson in rawList) {
      try {
        final map = jsonDecode(rawJson) as Map<String, dynamic>;
        final id = map['id'] as String?;
        if (id != null) {
          final mKey = _messagesKey(id, userId);
          await sharedPreferencesHelper.deleteData(key: mKey);
        }
      } catch (_) {}
    }
    await sharedPreferencesHelper.deleteData(key: key);
  }
}
