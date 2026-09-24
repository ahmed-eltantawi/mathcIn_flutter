import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_entity.dart';
import '../repositories/chatbot_repository.dart';

class GetChatHistoryUseCase {
  const GetChatHistoryUseCase({required this.repository});

  final ChatbotRepository repository;

  Future<Either<Failure, List<ChatEntity>>> call() {
    return repository.getChatHistory();
  }
}
