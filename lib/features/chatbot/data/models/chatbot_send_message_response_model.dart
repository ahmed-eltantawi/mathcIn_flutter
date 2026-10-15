import 'chat_message_model.dart';
import 'chat_model.dart';

class ChatbotSendMessageResponseModel {
  const ChatbotSendMessageResponseModel({
    this.userMessage,
    required this.mentorReply,
    this.conversation,
  });

  factory ChatbotSendMessageResponseModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = json;
    if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      data = json['data'] as Map<String, dynamic>;
    }

    ChatMessageModel? userMsg;
    if (data.containsKey('user_message') && data['user_message'] is Map<String, dynamic>) {
      userMsg = ChatMessageModel.fromJson(data['user_message'] as Map<String, dynamic>);
    }

    ChatMessageModel aiReply;
    if (data.containsKey('mentor_reply') && data['mentor_reply'] is Map<String, dynamic>) {
      aiReply = ChatMessageModel.fromJson(data['mentor_reply'] as Map<String, dynamic>);
    } else if (data.containsKey('assistant_message') &&
        data['assistant_message'] is Map<String, dynamic>) {
      aiReply = ChatMessageModel.fromJson(data['assistant_message'] as Map<String, dynamic>);
    } else {
      aiReply = ChatMessageModel.fromJson(data);
    }

    ChatModel? convo;
    if (data.containsKey('conversation') && data['conversation'] is Map<String, dynamic>) {
      convo = ChatModel.fromJson(data['conversation'] as Map<String, dynamic>);
    }

    return ChatbotSendMessageResponseModel(
      userMessage: userMsg,
      mentorReply: aiReply,
      conversation: convo,
    );
  }

  final ChatMessageModel? userMessage;
  final ChatMessageModel mentorReply;
  final ChatModel? conversation;
}
