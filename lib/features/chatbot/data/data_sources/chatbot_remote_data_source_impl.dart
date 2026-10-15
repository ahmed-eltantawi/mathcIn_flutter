import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/core/networking/api_end_points.dart';
import '../models/chat_message_model.dart';
import '../models/chat_model.dart';
import '../models/chatbot_send_message_response_model.dart';
import 'chatbot_remote_data_source.dart';

class ChatbotRemoteDataSourceImpl implements ChatbotRemoteDataSource {
  const ChatbotRemoteDataSourceImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  @override
  Future<List<ChatModel>> getConversations() async {
    final response = await apiConsumer.get(EndPoint.mentorConversations);

    dynamic listData = response;
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      listData = response['data'];
    }

    if (listData is List) {
      return listData
          .whereType<Map<String, dynamic>>()
          .map((json) => ChatModel.fromJson(json))
          .toList();
    }

    return const [];
  }

  @override
  Future<ChatModel> getConversationDetails(String conversationId) async {
    final response = await apiConsumer.get(
      EndPoint.mentorConversationDetails(conversationId),
    );

    if (response is Map<String, dynamic>) {
      if (response.containsKey('data') && response['data'] is Map<String, dynamic>) {
        return ChatModel.fromJson(response['data'] as Map<String, dynamic>);
      }
      return ChatModel.fromJson(response);
    }

    throw const FormatException('Invalid conversation response format');
  }

  @override
  Future<ChatModel> createConversation({
    String? title,
    String? message,
    String? contextMode,
    int? jobPostId,
  }) async {
    final body = <String, dynamic>{};
    if (title != null && title.isNotEmpty) body['title'] = title;
    if (message != null && message.isNotEmpty) body['message'] = message;
    if (contextMode != null && contextMode.isNotEmpty) {
      body[ApiKey.contextMode] = contextMode;
    }
    if (jobPostId != null) body[ApiKey.jobPostId] = jobPostId;

    final response = await apiConsumer.post(
      EndPoint.mentorConversations,
      data: body,
    );

    if (response is Map<String, dynamic>) {
      if (response.containsKey('data') && response['data'] is Map<String, dynamic>) {
        final data = response['data'] as Map<String, dynamic>;
        // If data wraps a conversation object
        if (data.containsKey('conversation') && data['conversation'] is Map<String, dynamic>) {
          return ChatModel.fromJson(data['conversation'] as Map<String, dynamic>);
        }
        // If data returns user_message and mentor_reply along with id/title
        final messages = <ChatMessageModel>[];
        if (data.containsKey('user_message') && data['user_message'] is Map<String, dynamic>) {
          messages.add(ChatMessageModel.fromJson(data['user_message'] as Map<String, dynamic>));
        }
        if (data.containsKey('mentor_reply') && data['mentor_reply'] is Map<String, dynamic>) {
          messages.add(ChatMessageModel.fromJson(data['mentor_reply'] as Map<String, dynamic>));
        }
        final chat = ChatModel.fromJson(data);
        if (messages.isNotEmpty && chat.messages.isEmpty) {
          return ChatModel.fromEntity(chat.copyWith(messages: messages));
        }
        return chat;
      }
      return ChatModel.fromJson(response);
    }

    throw const FormatException('Invalid create conversation response format');
  }

  @override
  Future<ChatbotSendMessageResponseModel> sendMessage({
    required String conversationId,
    required String message,
  }) async {
    final response = await apiConsumer.post(
      EndPoint.mentorConversationMessages(conversationId),
      data: {'message': message},
    );

    if (response is Map<String, dynamic>) {
      return ChatbotSendMessageResponseModel.fromJson(response);
    }

    throw const FormatException('Invalid send message response format');
  }

  @override
  Future<void> updateConversation({
    required String conversationId,
    String? title,
    bool? isArchived,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (isArchived != null) body[ApiKey.isArchived] = isArchived;

    await apiConsumer.patch(
      EndPoint.mentorConversationDetails(conversationId),
      data: body,
    );
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await apiConsumer.delete(
      EndPoint.mentorConversationDetails(conversationId),
    );
  }

  @override
  Future<Map<String, dynamic>> getContextPreview() async {
    final response = await apiConsumer.get(EndPoint.mentorContextPreview);
    if (response is Map<String, dynamic>) {
      if (response.containsKey('data') && response['data'] is Map<String, dynamic>) {
        return response['data'] as Map<String, dynamic>;
      }
      return response;
    }
    return const {};
  }
}
