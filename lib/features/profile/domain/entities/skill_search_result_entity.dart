import 'package:equatable/equatable.dart';

class SkillSearchResultEntity extends Equatable {
  const SkillSearchResultEntity({required this.id, required this.name});

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
