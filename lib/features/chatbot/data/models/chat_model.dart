import '../../domain/entities/chat_entity.dart';
import 'chat_message_model.dart';

class ChatModel extends ChatEntity {
  const ChatModel({
    required super.id,
    required super.title,
    required super.createdAt,
    required super.updatedAt,
    super.messages = const [],
    super.isArchived = false,
    super.jobPostId,
    super.contextMode,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    final rawMessages = json['messages'];
    List<ChatMessageModel> messagesList = const [];
    if (rawMessages is List) {
      messagesList = rawMessages
          .whereType<Map<String, dynamic>>()
          .map((e) => ChatMessageModel.fromJson(e))
          .toList();
    }

    return ChatModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? 'Chat').toString(),
      createdAt: parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: parseDate(json['updatedAt'] ?? json['updated_at']),
      messages: messagesList,
      isArchived: json['is_archived'] as bool? ?? false,
      jobPostId: (json['job_post_id'] as num?)?.toInt(),
      contextMode: json['context_mode'] as String?,
    );
  }

  factory ChatModel.fromEntity(ChatEntity entity) {
    return ChatModel(
      id: entity.id,
      title: entity.title,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      messages: entity.messages,
      isArchived: entity.isArchived,
      jobPostId: entity.jobPostId,
      contextMode: entity.contextMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'messages': messages
          .map((m) => ChatMessageModel.fromEntity(m).toJson())
          .toList(),
      'is_archived': isArchived,
      'job_post_id': jobPostId,
      'context_mode': contextMode,
    };
  }
}
