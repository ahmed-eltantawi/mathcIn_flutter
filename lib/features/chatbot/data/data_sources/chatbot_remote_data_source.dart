import '../models/chat_model.dart';
import '../models/chatbot_send_message_response_model.dart';

abstract class ChatbotRemoteDataSource {
  Future<List<ChatModel>> getConversations();

  Future<ChatModel> getConversationDetails(String conversationId);

  Future<ChatModel> createConversation({
    String? title,
    String? message,
    String? contextMode,
    int? jobPostId,
  });

  Future<ChatbotSendMessageResponseModel> sendMessage({
    required String conversationId,
    required String message,
  });

  Future<void> updateConversation({
    required String conversationId,
    String? title,
    bool? isArchived,
  });

  Future<void> deleteConversation(String conversationId);

  Future<Map<String, dynamic>> getContextPreview();
}
