import 'package:equatable/equatable.dart';
import 'chat_message_entity.dart';

class ChatEntity extends Equatable {
  const ChatEntity({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
    this.isArchived = false,
    this.jobPostId,
    this.contextMode,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessageEntity> messages;
  final bool isArchived;
  final int? jobPostId;
  final String? contextMode;

  ChatEntity copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ChatMessageEntity>? messages,
    bool? isArchived,
    int? jobPostId,
    String? contextMode,
  }) {
    return ChatEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      isArchived: isArchived ?? this.isArchived,
      jobPostId: jobPostId ?? this.jobPostId,
      contextMode: contextMode ?? this.contextMode,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        createdAt,
        updatedAt,
        messages,
        isArchived,
        jobPostId,
        contextMode,
      ];
}
