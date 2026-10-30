import 'package:MatchIn/features/chatbot/data/models/chat_model.dart';
import 'package:MatchIn/features/chatbot/domain/entities/chat_message_entity.dart';

abstract class ChatbotLocalDataSource {
  Future<List<ChatModel>> getChatSessions({String? userId});
  Future<ChatModel?> getChatSession(String chatId, {String? userId});
  Future<void> saveChatSession(ChatModel chat, {String? userId});
  Future<void> saveAllChatSessions(List<ChatModel> chats, {String? userId});
  Future<void> appendMessages(String chatId, List<ChatMessageEntity> messages, {String? userId, DateTime? updatedAt});
  Future<void> deleteChatSession(String chatId, {String? userId});
  Future<void> clearAllChatSessions({String? userId});
}
