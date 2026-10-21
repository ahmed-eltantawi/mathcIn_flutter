import 'package:equatable/equatable.dart';

class AwardXpParams extends Equatable {
  const AwardXpParams({
    required this.xp,
    required this.reason,
    this.roadmapId,
    this.taskId,
    this.milestoneId,
  });

  final int xp;
  final String reason;
  final int? roadmapId;
  final int? taskId;
  final int? milestoneId;

  Map<String, dynamic> toJson() {
    return {
      'xp': xp,
      'reason': reason,
      if (roadmapId != null) 'roadmap_id': roadmapId,
      if (taskId != null) 'task_id': taskId,
      if (milestoneId != null) 'milestone_id': milestoneId,
    };
  }

  @override
  List<Object?> get props => [xp, reason, roadmapId, taskId, milestoneId];
}
