import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/chatbot_repository.dart';
import '../data_sources/chatbot_local_data_source.dart';
import '../data_sources/chatbot_remote_data_source.dart';
import '../models/chat_message_model.dart';
import '../models/chat_model.dart';

class ChatbotRepositoryImpl implements ChatbotRepository {
  ChatbotRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final ChatbotRemoteDataSource remoteDataSource;
  final ChatbotLocalDataSource localDataSource;

  @override
  Future<Either<Failure, List<ChatEntity>>> getChatHistory() async {
    try {
      final sessions = await localDataSource.getChatSessions();
      return Right(sessions);
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to load chat history'));
    }
  }

  @override
  Future<Either<Failure, ChatEntity>> getChatById(String id) async {
    try {
      final chat = await localDataSource.getChatSession(id);
      if (chat != null) {
        return Right(chat);
      }
      return const Left(CacheFailure(message: 'Chat session not found'));
    } catch (e) {
      return const Left(CacheFailure(message: 'Error fetching chat session'));
    }
  }

  @override
  Future<Either<Failure, ChatMessageEntity>> sendMessage({
    required String chatId,
    required String messageContent,
    required List<ChatMessageEntity> currentMessages,
  }) async {
    try {
      final historyModels = currentMessages
          .map((m) => ChatMessageModel.fromEntity(m))
          .toList();

      final responseMessage = await remoteDataSource.sendMessage(
        chatId: chatId,
        messageContent: messageContent,
        history: historyModels,
      );

      return Right(responseMessage);
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to get response from AI'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveChatSession(ChatEntity chat) async {
    try {
      await localDataSource.saveChatSession(ChatModel.fromEntity(chat));
      return const Right(unit);
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to save chat session'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteChatSession(String chatId) async {
    try {
      await localDataSource.deleteChatSession(chatId);
      return const Right(unit);
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to delete chat session'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearAllChatSessions() async {
    try {
      await localDataSource.clearAllChatSessions();
      return const Right(unit);
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to clear chat sessions'));
    }
  }
}
