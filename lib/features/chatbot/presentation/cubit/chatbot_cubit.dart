import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/use_cases/clear_all_chats_use_case.dart';
import '../../domain/use_cases/create_conversation_use_case.dart';
import '../../domain/use_cases/delete_chat_use_case.dart';
import '../../domain/use_cases/get_chat_history_use_case.dart';
import '../../domain/use_cases/get_context_preview_use_case.dart';
import '../../domain/use_cases/get_conversation_details_use_case.dart';
import '../../domain/use_cases/send_message_use_case.dart';
import '../../domain/use_cases/update_conversation_use_case.dart';
import 'chatbot_state.dart';

class ChatbotCubit extends Cubit<ChatbotState> {
  ChatbotCubit({
    required this.getChatHistoryUseCase,
    required this.getConversationDetailsUseCase,
    required this.createConversationUseCase,
    required this.sendMessageUseCase,
    required this.updateConversationUseCase,
    required this.deleteChatUseCase,
    required this.clearAllChatsUseCase,
    required this.getContextPreviewUseCase,
    required this.sharedPreferencesService,
  }) : super(const ChatbotState());

  final GetChatHistoryUseCase getChatHistoryUseCase;
  final GetConversationDetailsUseCase getConversationDetailsUseCase;
  final CreateConversationUseCase createConversationUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final UpdateConversationUseCase updateConversationUseCase;
  final DeleteChatUseCase deleteChatUseCase;
  final ClearAllChatsUseCase clearAllChatsUseCase;
  final GetContextPreviewUseCase getContextPreviewUseCase;
  final SharedPreferencesService sharedPreferencesService;

  void initializeChat() {
    emit(state.copyWith(
      activeChatId: '',
      activeChatTitle: '',
      messages: const [],
      isGenerating: false,
      isOpeningChat: false,
      isAuthRequired: false,
      isOffline: false,
      clearFailedMessage: true,
      clearErrorMessage: true,
      status: ChatbotStatus.initial,
    ));
    loadHistory();
  }

  Future<void> loadHistory() async {
    emit(state.copyWith(isLoadingHistory: true));

    final result = await getChatHistoryUseCase();
    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoadingHistory: false,
          isOffline: failure is OfflineFailure,
          errorMessage: failure.message,
        ));
      },
      (history) {
        emit(state.copyWith(
          isLoadingHistory: false,
          chatHistory: history,
          isOffline: false,
        ));
      },
    );
  }

  Future<void> selectChat(String conversationId) async {
    if (conversationId.isEmpty) return;

    // Optimistically show cached messages from chatHistory if available
    final existingIndex = state.chatHistory.indexWhere((c) => c.id == conversationId);
    if (existingIndex >= 0) {
      final cached = state.chatHistory[existingIndex];
      emit(state.copyWith(
        activeChatId: cached.id,
        activeChatTitle: cached.title,
        messages: cached.messages,
        isGenerating: false,
        isOpeningChat: true,
        clearFailedMessage: true,
        clearErrorMessage: true,
      ));
    } else {
      emit(state.copyWith(
        activeChatId: conversationId,
        isOpeningChat: true,
        clearFailedMessage: true,
        clearErrorMessage: true,
      ));
    }

    final result = await getConversationDetailsUseCase(conversationId);
    result.fold(
      (failure) {
        emit(state.copyWith(
          isOpeningChat: false,
          isOffline: failure is OfflineFailure,
          errorMessage: failure.message,
        ));
      },
      (chatDetails) {
        emit(state.copyWith(
          activeChatId: chatDetails.id,
          activeChatTitle: chatDetails.title,
          messages: chatDetails.messages,
          isOpeningChat: false,
          isOffline: false,
          status: ChatbotStatus.success,
        ));
      },
    );
  }

  Future<void> sendMessage(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty || state.isGenerating) return;

    // Auth check: candidate endpoints require authentication
    if (!sharedPreferencesService.isLoggedIn()) {
      emit(state.copyWith(
        isAuthRequired: true,
        errorMessage: 'Authentication required to use AI Career Mentor',
      ));
      return;
    }

    final userMsgId = 'msg_${DateTime.now().millisecondsSinceEpoch}';
    final userMessage = ChatMessageEntity(
      id: userMsgId,
      content: trimmedText,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    final updatedMessages = List<ChatMessageEntity>.from(state.messages)..add(userMessage);

    emit(state.copyWith(
      messages: updatedMessages,
      isGenerating: true,
      status: ChatbotStatus.loading,
      clearFailedMessage: true,
      clearErrorMessage: true,
      isAuthRequired: false,
      isOffline: false,
    ));

    // If starting a fresh chat session without an active conversation ID
    if (state.activeChatId.isEmpty) {
      final title = trimmedText.length > 32
          ? '${trimmedText.substring(0, 32)}...'
          : trimmedText;

      final createResult = await createConversationUseCase(
        title: title,
        message: trimmedText,
      );

      await createResult.fold(
        (failure) async {
          _handleSendFailure(failure, trimmedText);
        },
        (createdSession) async {
          // If createdSession already contains messages (backend returned reply)
          if (createdSession.messages.isNotEmpty) {
            emit(state.copyWith(
              activeChatId: createdSession.id,
              activeChatTitle: createdSession.title,
              messages: createdSession.messages,
              isGenerating: false,
              status: ChatbotStatus.success,
            ));
          } else {
            // Otherwise, send message explicitly to the new session
            emit(state.copyWith(
              activeChatId: createdSession.id,
              activeChatTitle: createdSession.title,
            ));
            await _dispatchSendMessage(createdSession.id, trimmedText);
          }
          await loadHistory();
        },
      );
    } else {
      await _dispatchSendMessage(state.activeChatId, trimmedText);
    }
  }

  Future<void> _dispatchSendMessage(String conversationId, String messageText) async {
    final result = await sendMessageUseCase(
      conversationId: conversationId,
      message: messageText,
    );

    result.fold(
      (failure) {
        _handleSendFailure(failure, messageText);
      },
      (response) {
        final finalMessages = List<ChatMessageEntity>.from(state.messages);

        // If backend returned user_message with canonical ID, update it
        if (response.userMessage != null) {
          final lastUserIndex = finalMessages.lastIndexWhere(
            (m) => m.sender == MessageSender.user && m.content == messageText,
          );
          if (lastUserIndex >= 0) {
            finalMessages[lastUserIndex] = response.userMessage!;
          }
        }

        // Add mentor reply
        finalMessages.add(response.mentorReply);

        emit(state.copyWith(
          messages: finalMessages,
          isGenerating: false,
          status: ChatbotStatus.success,
          clearFailedMessage: true,
          clearErrorMessage: true,
        ));

        loadHistory();
      },
    );
  }

  void _handleSendFailure(Failure failure, String originalText) {
    final isOffline = failure is OfflineFailure;
    final errorMessage = failure.message;

    final errorMsg = ChatMessageEntity(
      id: 'err_${DateTime.now().millisecondsSinceEpoch}',
      content: errorMessage,
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
      isError: true,
    );

    final finalMessages = List<ChatMessageEntity>.from(state.messages)..add(errorMsg);

    emit(state.copyWith(
      messages: finalMessages,
      isGenerating: false,
      isOffline: isOffline,
      failedMessage: originalText,
      errorMessage: errorMessage,
      status: ChatbotStatus.failure,
    ));
  }

  Future<void> retryLastFailedMessage() async {
    final messageToRetry = state.failedMessage;
    if (messageToRetry == null || messageToRetry.isEmpty) return;

    // Remove the error message from the list
    final cleaned = state.messages.where((m) => !m.isError).toList();
    emit(state.copyWith(
      messages: cleaned,
      clearFailedMessage: true,
      clearErrorMessage: true,
    ));

    await sendMessage(messageToRetry);
  }

  Future<void> updateChatTitle(String conversationId, String newTitle) async {
    if (newTitle.trim().isEmpty) return;

    final result = await updateConversationUseCase(
      conversationId: conversationId,
      title: newTitle.trim(),
    );

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) {
        if (state.activeChatId == conversationId) {
          emit(state.copyWith(activeChatTitle: newTitle.trim()));
        }
        loadHistory();
      },
    );
  }

  Future<void> deleteChat(String conversationId) async {
    await deleteChatUseCase(conversationId);
    if (state.activeChatId == conversationId) {
      initializeChat();
    } else {
      await loadHistory();
    }
  }

  Future<void> clearAllChats() async {
    await clearAllChatsUseCase();
    initializeChat();
  }

  Future<void> loadContextPreview() async {
    final result = await getContextPreviewUseCase();
    result.fold(
      (_) {},
      (preview) => emit(state.copyWith(contextPreview: preview)),
    );
  }
}
