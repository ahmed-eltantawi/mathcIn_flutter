import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/chatbot/domain/entities/chat_entity.dart';
import 'package:MatchIn/features/chatbot/domain/repositories/chatbot_repository.dart';

class GetChatHistoryUseCase {
  const GetChatHistoryUseCase({required this.repository});

  final ChatbotRepository repository;

  Future<Either<Failure, List<ChatEntity>>> call() {
    return repository.getConversations();
  }
}
