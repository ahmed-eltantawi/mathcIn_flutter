import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_entity.dart';
import '../entities/chat_message_entity.dart';

abstract class ChatbotRepository {
  Future<Either<Failure, List<ChatEntity>>> getChatHistory();
  Future<Either<Failure, ChatEntity>> getChatById(String id);
  Future<Either<Failure, ChatMessageEntity>> sendMessage({
    required String chatId,
    required String messageContent,
    required List<ChatMessageEntity> currentMessages,
  });
  Future<Either<Failure, Unit>> saveChatSession(ChatEntity chat);
  Future<Either<Failure, Unit>> deleteChatSession(String chatId);
  Future<Either<Failure, Unit>> clearAllChatSessions();
}
