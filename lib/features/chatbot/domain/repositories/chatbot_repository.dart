import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/chatbot_send_message_response_model.dart';
import '../entities/chat_entity.dart';

abstract class ChatbotRepository {
  Future<Either<Failure, List<ChatEntity>>> getConversations();

  Future<Either<Failure, ChatEntity>> getConversationDetails(String conversationId);

  Future<Either<Failure, ChatEntity>> createConversation({
    String? title,
    String? message,
    String? contextMode,
    int? jobPostId,
  });

  Future<Either<Failure, ChatbotSendMessageResponseModel>> sendMessage({
    required String conversationId,
    required String message,
  });

  Future<Either<Failure, Unit>> updateConversation({
    required String conversationId,
    String? title,
    bool? isArchived,
  });

  Future<Either<Failure, Unit>> deleteConversation(String conversationId);

  Future<Either<Failure, Unit>> clearAllLocalConversations();

  Future<Either<Failure, Map<String, dynamic>>> getContextPreview();
}
