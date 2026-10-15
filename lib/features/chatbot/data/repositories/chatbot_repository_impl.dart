import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/chatbot_repository.dart';
import '../data_sources/chatbot_local_data_source.dart';
import '../data_sources/chatbot_remote_data_source.dart';
import '../models/chat_model.dart';
import '../models/chatbot_send_message_response_model.dart';

class ChatbotRepositoryImpl implements ChatbotRepository {
  ChatbotRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.sharedPreferencesService,
  });

  final ChatbotRemoteDataSource remoteDataSource;
  final ChatbotLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final SharedPreferencesService sharedPreferencesService;

  String? get _currentUserId => sharedPreferencesService.getUserId()?.toString();

  @override
  Future<Either<Failure, List<ChatEntity>>> getConversations() async {
    final uid = _currentUserId;
    if (await networkInfo.isConnected) {
      try {
        final remoteList = await remoteDataSource.getConversations();
        await localDataSource.saveAllChatSessions(remoteList, userId: uid);
        return Right(remoteList);
      } on ServerException catch (e) {
        final cached = await localDataSource.getChatSessions(userId: uid);
        if (cached.isNotEmpty) {
          return Right(cached);
        }
        return Left(ServerFailure(message: e.errorModel.errorMessage));
      } on OfflineException {
        final cached = await localDataSource.getChatSessions(userId: uid);
        if (cached.isNotEmpty) {
          return Right(cached);
        }
        return const Left(OfflineFailure());
      } catch (e) {
        final cached = await localDataSource.getChatSessions(userId: uid);
        if (cached.isNotEmpty) {
          return Right(cached);
        }
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      final cached = await localDataSource.getChatSessions(userId: uid);
      if (cached.isNotEmpty) {
        return Right(cached);
      }
      return const Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, ChatEntity>> getConversationDetails(
    String conversationId,
  ) async {
    final uid = _currentUserId;
    if (await networkInfo.isConnected) {
      try {
        final details = await remoteDataSource.getConversationDetails(conversationId);
        await localDataSource.saveChatSession(details, userId: uid);
        return Right(details);
      } on ServerException catch (e) {
        final cached = await localDataSource.getChatSession(conversationId, userId: uid);
        if (cached != null) {
          return Right(cached);
        }
        return Left(ServerFailure(message: e.errorModel.errorMessage));
      } on OfflineException {
        final cached = await localDataSource.getChatSession(conversationId, userId: uid);
        if (cached != null) {
          return Right(cached);
        }
        return const Left(OfflineFailure());
      } catch (e) {
        final cached = await localDataSource.getChatSession(conversationId, userId: uid);
        if (cached != null) {
          return Right(cached);
        }
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      final cached = await localDataSource.getChatSession(conversationId, userId: uid);
      if (cached != null) {
        return Right(cached);
      }
      return const Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, ChatEntity>> createConversation({
    String? title,
    String? message,
    String? contextMode,
    int? jobPostId,
  }) async {
    final uid = _currentUserId;
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      final session = await remoteDataSource.createConversation(
        title: title,
        message: message,
        contextMode: contextMode,
        jobPostId: jobPostId,
      );
      await localDataSource.saveChatSession(session, userId: uid);
      return Right(session);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.errorModel.errorMessage));
    } on OfflineException {
      return const Left(OfflineFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatbotSendMessageResponseModel>> sendMessage({
    required String conversationId,
    required String message,
  }) async {
    final uid = _currentUserId;
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      final response = await remoteDataSource.sendMessage(
        conversationId: conversationId,
        message: message,
      );

      // Reconcile and update local cache
      final localChat = await localDataSource.getChatSession(conversationId, userId: uid);
      if (localChat != null) {
        final updatedMessages = List<ChatMessageEntity>.from(localChat.messages);
        if (response.userMessage != null &&
            !updatedMessages.any((m) => m.id == response.userMessage!.id)) {
          updatedMessages.add(response.userMessage!);
        }
        updatedMessages.add(response.mentorReply);

        final updatedChat = ChatModel.fromEntity(localChat.copyWith(
          messages: updatedMessages,
          updatedAt: DateTime.now(),
        ));
        await localDataSource.saveChatSession(updatedChat, userId: uid);
      }

      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.errorModel.errorMessage));
    } on OfflineException {
      return const Left(OfflineFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateConversation({
    required String conversationId,
    String? title,
    bool? isArchived,
  }) async {
    final uid = _currentUserId;
    try {
      final localChat = await localDataSource.getChatSession(conversationId, userId: uid);
      if (localChat != null) {
        final updatedChat = ChatModel.fromEntity(localChat.copyWith(
          title: title ?? localChat.title,
          isArchived: isArchived ?? localChat.isArchived,
          updatedAt: DateTime.now(),
        ));
        await localDataSource.saveChatSession(updatedChat, userId: uid);
      }

      if (await networkInfo.isConnected) {
        await remoteDataSource.updateConversation(
          conversationId: conversationId,
          title: title,
          isArchived: isArchived,
        );
      }

      return const Right(unit);
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to update conversation'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteConversation(String conversationId) async {
    final uid = _currentUserId;
    try {
      await localDataSource.deleteChatSession(conversationId, userId: uid);

      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.deleteConversation(conversationId);
        } catch (_) {
          // Local delete is primary; non-blocking remote error
        }
      }

      return const Right(unit);
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to delete chat session'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearAllLocalConversations() async {
    final uid = _currentUserId;
    try {
      await localDataSource.clearAllChatSessions(userId: uid);
      return const Right(unit);
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to clear chat sessions'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getContextPreview() async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      final preview = await remoteDataSource.getContextPreview();
      return Right(preview);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.errorModel.errorMessage));
    } on OfflineException {
      return const Left(OfflineFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
