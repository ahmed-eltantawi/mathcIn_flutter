import 'package:MatchIn/features/profile/domain/entities/skill_search_result_entity.dart';

class SkillSearchResultModel extends SkillSearchResultEntity {
  const SkillSearchResultModel({required super.id, required super.name});

  factory SkillSearchResultModel.fromJson(Map<String, dynamic> json) {
    return SkillSearchResultModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}
