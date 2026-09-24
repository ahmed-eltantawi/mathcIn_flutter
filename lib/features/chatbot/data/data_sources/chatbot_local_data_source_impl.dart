import 'dart:convert';
import 'package:MatchIn/core/cache/cache_key.dart';
import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import '../models/chat_message_model.dart';
import '../models/chat_model.dart';
import 'chatbot_local_data_source.dart';

class ChatbotLocalDataSourceImpl implements ChatbotLocalDataSource {
  ChatbotLocalDataSourceImpl({required this.sharedPreferencesHelper});

  final SharedPreferencesHelper sharedPreferencesHelper;

  @override
  Future<List<ChatModel>> getChatSessions() async {
    final rawList = sharedPreferencesHelper.getStringList(key: CacheKey.chatSessions);
    if (rawList == null || rawList.isEmpty) {
      return [];
    }

    final List<ChatModel> sessions = [];
    for (final rawJson in rawList) {
      try {
        final map = jsonDecode(rawJson) as Map<String, dynamic>;
        final chatWithoutMessages = ChatModel.fromJson(map);

        final messagesKey = '${CacheKey.chatMessagesPrefix}${chatWithoutMessages.id}';
        final messagesRaw = sharedPreferencesHelper.getStringList(key: messagesKey);

        final messagesList = messagesRaw != null
            ? messagesRaw
                .map((m) => ChatMessageModel.fromJson(jsonDecode(m) as Map<String, dynamic>))
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
  Future<ChatModel?> getChatSession(String chatId) async {
    final sessions = await getChatSessions();
    try {
      return sessions.firstWhere((s) => s.id == chatId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveChatSession(ChatModel chat) async {
    final rawList = sharedPreferencesHelper.getStringList(key: CacheKey.chatSessions) ?? [];

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
    ).toJson();

    if (existingIndex >= 0) {
      sessionMaps[existingIndex] = sessionHeader;
    } else {
      sessionMaps.insert(0, sessionHeader);
    }

    final updatedRawList = sessionMaps.map((m) => jsonEncode(m)).toList();
    await sharedPreferencesHelper.saveData(
      key: CacheKey.chatSessions,
      value: updatedRawList,
    );

    final messagesKey = '${CacheKey.chatMessagesPrefix}${chat.id}';
    final messagesRaw = chat.messages
        .map((m) => jsonEncode(ChatMessageModel.fromEntity(m).toJson()))
        .toList();

    await sharedPreferencesHelper.saveData(
      key: messagesKey,
      value: messagesRaw,
    );
  }

  @override
  Future<void> deleteChatSession(String chatId) async {
    final rawList = sharedPreferencesHelper.getStringList(key: CacheKey.chatSessions) ?? [];
    final List<Map<String, dynamic>> sessionMaps = [];
    for (final s in rawList) {
      try {
        sessionMaps.add(jsonDecode(s) as Map<String, dynamic>);
      } catch (_) {}
    }

    sessionMaps.removeWhere((m) => m['id'] == chatId);

    final updatedRawList = sessionMaps.map((m) => jsonEncode(m)).toList();
    await sharedPreferencesHelper.saveData(
      key: CacheKey.chatSessions,
      value: updatedRawList,
    );

    final messagesKey = '${CacheKey.chatMessagesPrefix}$chatId';
    await sharedPreferencesHelper.deleteData(key: messagesKey);
  }

  @override
  Future<void> clearAllChatSessions() async {
    final rawList = sharedPreferencesHelper.getStringList(key: CacheKey.chatSessions) ?? [];
    for (final rawJson in rawList) {
      try {
        final map = jsonDecode(rawJson) as Map<String, dynamic>;
        final id = map['id'] as String?;
        if (id != null) {
          await sharedPreferencesHelper.deleteData(key: '${CacheKey.chatMessagesPrefix}$id');
        }
      } catch (_) {}
    }
    await sharedPreferencesHelper.deleteData(key: CacheKey.chatSessions);
  }
}
