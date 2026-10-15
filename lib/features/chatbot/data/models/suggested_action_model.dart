import '../../domain/entities/suggested_action_entity.dart';

class SuggestedActionModel extends SuggestedActionEntity {
  const SuggestedActionModel({
    required super.type,
    required super.label,
  });

  factory SuggestedActionModel.fromJson(Map<String, dynamic> json) {
    return SuggestedActionModel(
      type: json['type'] as String? ?? 'suggested_prompt',
      label: (json['label'] ?? json['title'] ?? json['text'] ?? '').toString(),
    );
  }

  factory SuggestedActionModel.fromEntity(SuggestedActionEntity entity) {
    return SuggestedActionModel(
      type: entity.type,
      label: entity.label,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'label': label,
    };
  }
}
