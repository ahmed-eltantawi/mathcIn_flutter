import 'package:equatable/equatable.dart';
import 'suggested_action_entity.dart';

enum MessageSender { user, ai }

class ChatMessageEntity extends Equatable {
  const ChatMessageEntity({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.isError = false,
    this.suggestedActions = const [],
  });

  final String id;
  final String content;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isError;
  final List<SuggestedActionEntity> suggestedActions;

  ChatMessageEntity copyWith({
    String? id,
    String? content,
    MessageSender? sender,
    DateTime? timestamp,
    bool? isError,
    List<SuggestedActionEntity>? suggestedActions,
  }) {
    return ChatMessageEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      isError: isError ?? this.isError,
      suggestedActions: suggestedActions ?? this.suggestedActions,
    );
  }

  @override
  List<Object?> get props => [
        id,
        content,
        sender,
        timestamp,
        isError,
        suggestedActions,
      ];
}
