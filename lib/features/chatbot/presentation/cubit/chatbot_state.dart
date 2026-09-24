import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/chat_message_entity.dart';

enum ChatbotStatus { initial, loading, success, failure }

class ChatbotState extends Equatable {
  const ChatbotState({
    this.status = ChatbotStatus.initial,
    this.activeChatId = '',
    this.messages = const [],
    this.chatHistory = const [],
    this.isGenerating = false,
    this.errorMessage,
  });

  final ChatbotStatus status;
  final String activeChatId;
  final List<ChatMessageEntity> messages;
  final List<ChatEntity> chatHistory;
  final bool isGenerating;
  final String? errorMessage;

  ChatbotState copyWith({
    ChatbotStatus? status,
    String? activeChatId,
    List<ChatMessageEntity>? messages,
    List<ChatEntity>? chatHistory,
    bool? isGenerating,
    String? errorMessage,
  }) {
    return ChatbotState(
      status: status ?? this.status,
      activeChatId: activeChatId ?? this.activeChatId,
      messages: messages ?? this.messages,
      chatHistory: chatHistory ?? this.chatHistory,
      isGenerating: isGenerating ?? this.isGenerating,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        activeChatId,
        messages,
        chatHistory,
        isGenerating,
        errorMessage,
      ];
}
