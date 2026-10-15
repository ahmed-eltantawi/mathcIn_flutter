import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_entity.dart';
import '../repositories/chatbot_repository.dart';

class GetConversationDetailsUseCase {
  const GetConversationDetailsUseCase({required this.repository});

  final ChatbotRepository repository;

  Future<Either<Failure, ChatEntity>> call(String conversationId) {
    return repository.getConversationDetails(conversationId);
  }
}
