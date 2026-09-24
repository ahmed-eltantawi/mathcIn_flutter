import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/chatbot_repository.dart';

class ClearAllChatsUseCase {
  const ClearAllChatsUseCase({required this.repository});

  final ChatbotRepository repository;

  Future<Either<Failure, Unit>> call() {
    return repository.clearAllChatSessions();
  }
}
