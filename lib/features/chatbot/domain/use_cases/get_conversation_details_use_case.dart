import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/chatbot/domain/entities/chat_entity.dart';
import 'package:MatchIn/features/chatbot/domain/repositories/chatbot_repository.dart';

class GetConversationDetailsUseCase {
  const GetConversationDetailsUseCase({required this.repository});

  final ChatbotRepository repository;

  Future<Either<Failure, ChatEntity>> call(String conversationId) {
    return repository.getConversationDetails(conversationId);
  }
}
