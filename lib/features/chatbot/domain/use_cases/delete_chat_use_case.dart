import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/chatbot_repository.dart';

class DeleteChatUseCase {
  const DeleteChatUseCase({required this.repository});

  final ChatbotRepository repository;

  Future<Either<Failure, Unit>> call(String chatId) {
    return repository.deleteChatSession(chatId);
  }
}
