import 'package:MatchIn/features/jobsAndApplications/domain/entities/skill_entity.dart';
///! Constants for JSON keys used in SkillModel
abstract class SkillModelKey {
  static const String id = 'id';
  static const String name = 'name';
  static const String importance = 'importance';
  static const String requiredLevel = 'required_level';
}

class SkillModel {
  const SkillModel({
    required this.id,
    required this.name,
    this.importance,
    this.requiredLevel,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json[SkillModelKey.id] is int
          ? json[SkillModelKey.id] as int
          : int.tryParse(json[SkillModelKey.id]?.toString() ?? '0') ?? 0,
      name: json[SkillModelKey.name] as String? ?? '',
      importance: json[SkillModelKey.importance] is int
          ? json[SkillModelKey.importance] as int
          : int.tryParse(json[SkillModelKey.importance]?.toString() ?? ''),
      requiredLevel: json[SkillModelKey.requiredLevel] as String?,
    );
  }

  final int id;
  final String name;
  final int? importance;
  final String? requiredLevel;

  Map<String, dynamic> toJson() {
    return {
      SkillModelKey.id: id,
      SkillModelKey.name: name,
      SkillModelKey.importance: importance,
      SkillModelKey.requiredLevel: requiredLevel,
    };
  }

  SkillEntity toEntity() {
    return SkillEntity(
      id: id,
      name: name,
      importance: importance,
      requiredLevel: requiredLevel,
    );
  }
}
