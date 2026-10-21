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

  RoadmapTask copyWith({
    int? id,
    String? title,
    String? description,
    int? estimatedHours,
    bool? isCompleted,
    String? completedAt,
  }) {
    return RoadmapTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

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
