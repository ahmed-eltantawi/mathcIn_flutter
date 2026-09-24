import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/core/networking/api_end_points.dart';
import '../models/chat_message_model.dart';
import 'chatbot_remote_data_source.dart';

class ChatbotRemoteDataSourceImpl implements ChatbotRemoteDataSource {
  ChatbotRemoteDataSourceImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  @override
  Future<ChatMessageModel> sendMessage({
    required String chatId,
    required String messageContent,
    required List<ChatMessageModel> history,
  }) async {
    final response = await apiConsumer.post(
      EndPoint.chatMessage,
      data: {
        'chat_id': chatId,
        'message': messageContent,
        'history': history.map((m) => m.toJson()).toList(),
      },
    );

    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return ChatMessageModel.fromJson(response['data'] as Map<String, dynamic>);
    }

    return ChatMessageModel.fromJson(response as Map<String, dynamic>);
  }
}
