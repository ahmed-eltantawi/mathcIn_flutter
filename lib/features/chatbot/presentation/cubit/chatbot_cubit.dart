import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/use_cases/clear_all_chats_use_case.dart';
import '../../domain/use_cases/delete_chat_use_case.dart';
import '../../domain/use_cases/get_chat_history_use_case.dart';
import '../../domain/use_cases/save_chat_use_case.dart';
import '../../domain/use_cases/send_message_use_case.dart';
import 'chatbot_state.dart';

class ChatbotCubit extends Cubit<ChatbotState> {
  ChatbotCubit({
    required this.getChatHistoryUseCase,
    required this.sendMessageUseCase,
    required this.saveChatUseCase,
    required this.deleteChatUseCase,
    required this.clearAllChatsUseCase,
  }) : super(const ChatbotState());

  final GetChatHistoryUseCase getChatHistoryUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final SaveChatUseCase saveChatUseCase;
  final DeleteChatUseCase deleteChatUseCase;
  final ClearAllChatsUseCase clearAllChatsUseCase;

  void initializeChat() {
    final newChatId = 'chat_${DateTime.now().millisecondsSinceEpoch}';
    emit(state.copyWith(
      activeChatId: newChatId,
      messages: const [],
      isGenerating: false,
      status: ChatbotStatus.success,
    ));
    loadHistory();
  }

  Future<void> loadHistory() async {
    final result = await getChatHistoryUseCase();
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (history) => emit(state.copyWith(chatHistory: history)),
    );
  }

  Future<void> selectChat(String chatId) async {
    final existingChatIndex = state.chatHistory.indexWhere((c) => c.id == chatId);
    if (existingChatIndex >= 0) {
      final selectedChat = state.chatHistory[existingChatIndex];
      emit(state.copyWith(
        activeChatId: selectedChat.id,
        messages: selectedChat.messages,
        isGenerating: false,
        status: ChatbotStatus.success,
      ));
    }
  }

  Future<void> sendMessage(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty || state.isGenerating) return;

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
    ));

    final result = await sendMessageUseCase(
      chatId: state.activeChatId,
      messageContent: trimmedText,
      currentMessages: updatedMessages,
    );

    result.fold(
      (failure) async {
        final errorMsg = ChatMessageEntity(
          id: 'err_${DateTime.now().millisecondsSinceEpoch}',
          content: failure.message,
          sender: MessageSender.ai,
          timestamp: DateTime.now(),
          isError: true,
        );

        final finalMessages = List<ChatMessageEntity>.from(state.messages)..add(errorMsg);
        emit(state.copyWith(
          messages: finalMessages,
          isGenerating: false,
          status: ChatbotStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (aiResponse) async {
        final finalMessages = List<ChatMessageEntity>.from(state.messages)..add(aiResponse);

        String title = 'Chat';
        if (finalMessages.isNotEmpty) {
          final firstUserMsg = finalMessages.firstWhere(
            (m) => m.sender == MessageSender.user,
            orElse: () => userMessage,
          );
          title = firstUserMsg.content.length > 30
              ? '${firstUserMsg.content.substring(0, 30)}...'
              : firstUserMsg.content;
        }

        final currentChat = ChatEntity(
          id: state.activeChatId,
          title: title,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          messages: finalMessages,
        );

        await saveChatUseCase(currentChat);

        emit(state.copyWith(
          messages: finalMessages,
          isGenerating: false,
          status: ChatbotStatus.success,
        ));

        await loadHistory();
      },
    );
  }

  Future<void> deleteChat(String chatId) async {
    await deleteChatUseCase(chatId);
    if (state.activeChatId == chatId) {
      initializeChat();
    } else {
      await loadHistory();
    }
  }

  Future<void> clearAllChats() async {
    await clearAllChatsUseCase();
    initializeChat();
  }
}
