import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/chatbot/domain/repositories/chatbot_repository.dart';

class UpdateConversationUseCase {
  const UpdateConversationUseCase({required this.repository});

  final ChatbotRepository repository;

  Future<Either<Failure, Unit>> call({
    required String conversationId,
    String? title,
    bool? isArchived,
  }) {
    return repository.updateConversation(
      conversationId: conversationId,
      title: title,
      isArchived: isArchived,
    );
  }
}
