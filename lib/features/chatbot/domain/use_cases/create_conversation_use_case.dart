import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/chatbot/domain/entities/chat_entity.dart';
import 'package:MatchIn/features/chatbot/domain/repositories/chatbot_repository.dart';

class CreateConversationUseCase {
  const CreateConversationUseCase({required this.repository});

  final ChatbotRepository repository;

  Future<Either<Failure, ChatEntity>> call({
    String? title,
    String? message,
    String? contextMode,
    int? jobPostId,
  }) {
    return repository.createConversation(
      title: title,
      message: message,
      contextMode: contextMode,
      jobPostId: jobPostId,
    );
  }
}
