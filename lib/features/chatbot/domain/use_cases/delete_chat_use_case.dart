import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/chatbot/domain/repositories/chatbot_repository.dart';

class DeleteChatUseCase {
  const DeleteChatUseCase({required this.repository});

  final ChatbotRepository repository;

  Future<Either<Failure, Unit>> call(String conversationId) {
    return repository.deleteConversation(conversationId);
  }
}
