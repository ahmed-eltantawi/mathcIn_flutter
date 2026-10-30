import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/chatbot/data/models/chatbot_send_message_response_model.dart';
import 'package:MatchIn/features/chatbot/domain/repositories/chatbot_repository.dart';

class SendMessageUseCase {
  const SendMessageUseCase({required this.repository});

  final ChatbotRepository repository;

  Future<Either<Failure, ChatbotSendMessageResponseModel>> call({
    required String conversationId,
    required String message,
  }) {
    return repository.sendMessage(
      conversationId: conversationId,
      message: message,
    );
  }
}
