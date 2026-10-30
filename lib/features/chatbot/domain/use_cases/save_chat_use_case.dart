import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/chatbot/domain/entities/chat_entity.dart';
import 'package:MatchIn/features/chatbot/domain/repositories/chatbot_repository.dart';

class SaveChatUseCase {
  const SaveChatUseCase({required this.repository});

  final ChatbotRepository repository;

  Future<Either<Failure, Unit>> call(ChatEntity chat) {
    return repository.updateConversation(
      conversationId: chat.id,
      title: chat.title,
      isArchived: chat.isArchived,
    );
  }
}
