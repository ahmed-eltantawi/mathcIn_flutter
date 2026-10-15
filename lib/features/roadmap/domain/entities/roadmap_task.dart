import 'package:equatable/equatable.dart';

class RoadmapTask extends Equatable {
  const RoadmapTask({
    required this.id,
    required this.title,
    this.description,
    this.estimatedHours,
    this.isCompleted = false,
    this.completedAt,
  });

  final int id;
  final String title;
  final String? description;
  final int? estimatedHours;
  final bool isCompleted;
  final String? completedAt;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    estimatedHours,
    isCompleted,
    completedAt,
  ];
}
