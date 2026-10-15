import '../../domain/entities/chat_message_entity.dart';
import 'suggested_action_model.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.content,
    required super.sender,
    required super.timestamp,
    super.isError = false,
    super.suggestedActions = const [],
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final senderRaw = (json['sender'] ?? json['role'] ?? 'user').toString().toLowerCase();
    final sender = (senderRaw == 'user') ? MessageSender.user : MessageSender.ai;

    final content = (json['content'] ?? json['message'] ?? json['text'] ?? '').toString();

    DateTime ts;
    final rawTs = json['timestamp'] ?? json['created_at'];
    if (rawTs is String && rawTs.isNotEmpty) {
      ts = DateTime.tryParse(rawTs) ?? DateTime.now();
    } else {
      ts = DateTime.now();
    }

    final rawActions = json['suggested_actions'] ?? json['actions'];
    List<SuggestedActionModel> actions = const [];
    if (rawActions is List) {
      actions = rawActions
          .whereType<Map<String, dynamic>>()
          .map((e) => SuggestedActionModel.fromJson(e))
          .toList();
    }

    return ChatMessageModel(
      id: (json['id'] ?? '').toString(),
      content: content,
      sender: sender,
      timestamp: ts,
      isError: json['isError'] as bool? ?? false,
      suggestedActions: actions,
    );
  }

  factory ChatMessageModel.fromEntity(ChatMessageEntity entity) {
    return ChatMessageModel(
      id: entity.id,
      content: entity.content,
      sender: entity.sender,
      timestamp: entity.timestamp,
      isError: entity.isError,
      suggestedActions: entity.suggestedActions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender': sender == MessageSender.user ? 'user' : 'ai',
      'timestamp': timestamp.toIso8601String(),
      'isError': isError,
      'suggested_actions': suggestedActions
          .map((a) => SuggestedActionModel.fromEntity(a).toJson())
          .toList(),
    };
  }
}
