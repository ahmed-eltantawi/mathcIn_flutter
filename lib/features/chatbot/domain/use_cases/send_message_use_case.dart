import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_message_entity.dart';
import '../repositories/chatbot_repository.dart';

class SendMessageUseCase {
  const SendMessageUseCase({required this.repository});

  final ChatbotRepository repository;

  Future<Either<Failure, ChatMessageEntity>> call({
    required String chatId,
    required String messageContent,
    required List<ChatMessageEntity> currentMessages,
  }) {
    return repository.sendMessage(
      chatId: chatId,
      messageContent: messageContent,
      currentMessages: currentMessages,
    );
  }
}
