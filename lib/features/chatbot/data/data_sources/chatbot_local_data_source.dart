import '../models/chat_model.dart';

abstract class ChatbotLocalDataSource {
  Future<List<ChatModel>> getChatSessions({String? userId});
  Future<ChatModel?> getChatSession(String chatId, {String? userId});
  Future<void> saveChatSession(ChatModel chat, {String? userId});
  Future<void> saveAllChatSessions(List<ChatModel> chats, {String? userId});
  Future<void> deleteChatSession(String chatId, {String? userId});
  Future<void> clearAllChatSessions({String? userId});
}
