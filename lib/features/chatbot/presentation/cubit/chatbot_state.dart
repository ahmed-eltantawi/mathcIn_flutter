import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/chat_message_entity.dart';

enum ChatbotStatus { initial, loading, success, failure }

class ChatbotState extends Equatable {
  const ChatbotState({
    this.status = ChatbotStatus.initial,
    this.activeChatId = '',
    this.activeChatTitle = '',
    this.messages = const [],
    this.chatHistory = const [],
    this.isGenerating = false,
    this.isLoadingHistory = false,
    this.isOpeningChat = false,
    this.isOffline = false,
    this.isAuthRequired = false,
    this.failedMessage,
    this.errorMessage,
    this.contextPreview,
  });

  final ChatbotStatus status;
  final String activeChatId;
  final String activeChatTitle;
  final List<ChatMessageEntity> messages;
  final List<ChatEntity> chatHistory;
  final bool isGenerating;
  final bool isLoadingHistory;
  final bool isOpeningChat;
  final bool isOffline;
  final bool isAuthRequired;
  final String? failedMessage;
  final String? errorMessage;
  final Map<String, dynamic>? contextPreview;

  ChatbotState copyWith({
    ChatbotStatus? status,
    String? activeChatId,
    String? activeChatTitle,
    List<ChatMessageEntity>? messages,
    List<ChatEntity>? chatHistory,
    bool? isGenerating,
    bool? isLoadingHistory,
    bool? isOpeningChat,
    bool? isOffline,
    bool? isAuthRequired,
    String? failedMessage,
    bool clearFailedMessage = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    Map<String, dynamic>? contextPreview,
  }) {
    return ChatbotState(
      status: status ?? this.status,
      activeChatId: activeChatId ?? this.activeChatId,
      activeChatTitle: activeChatTitle ?? this.activeChatTitle,
      messages: messages ?? this.messages,
      chatHistory: chatHistory ?? this.chatHistory,
      isGenerating: isGenerating ?? this.isGenerating,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      isOpeningChat: isOpeningChat ?? this.isOpeningChat,
      isOffline: isOffline ?? this.isOffline,
      isAuthRequired: isAuthRequired ?? this.isAuthRequired,
      failedMessage: clearFailedMessage ? null : (failedMessage ?? this.failedMessage),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      contextPreview: contextPreview ?? this.contextPreview,
    );
  }

  @override
  List<Object?> get props => [
        status,
        activeChatId,
        activeChatTitle,
        messages,
        chatHistory,
        isGenerating,
        isLoadingHistory,
        isOpeningChat,
        isOffline,
        isAuthRequired,
        failedMessage,
        errorMessage,
        contextPreview,
      ];
}
