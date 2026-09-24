import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_entity.dart';
import '../repositories/chatbot_repository.dart';

class SaveChatUseCase {
  const SaveChatUseCase({required this.repository});

  final ChatbotRepository repository;

  Future<Either<Failure, Unit>> call(ChatEntity chat) {
    return repository.saveChatSession(chat);
  }
}
