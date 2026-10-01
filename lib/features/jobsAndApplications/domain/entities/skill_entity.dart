import 'package:equatable/equatable.dart';

class SkillEntity extends Equatable {
  const SkillEntity({
    required this.id,
    required this.name,
    this.importance,
    this.requiredLevel,
  });

  final int id;
  final String name;
  final int? importance;
  final String? requiredLevel;

  @override
  List<Object?> get props => [id, name, importance, requiredLevel];
}
