part of 'skill_task_cubit.dart';

@immutable
sealed class SkillTaskState {
  const SkillTaskState();

  /// Backend task ids with a completion request currently in flight.
  Set<int> get completingTaskIds => const {};

  bool isCompleting(int taskId) => completingTaskIds.contains(taskId);
}

final class SkillTaskInitial extends SkillTaskState {
  const SkillTaskInitial();
}

final class SkillTaskCompleting extends SkillTaskState {
  const SkillTaskCompleting({this.completingTaskIds = const {}});

  @override
  final Set<int> completingTaskIds;
}

final class SkillTaskCompleteSuccess extends SkillTaskState {
  const SkillTaskCompleteSuccess({
    required this.taskId,
    this.completedAt,
    this.completingTaskIds = const {},
  });

  final int taskId;
  final String? completedAt;

  @override
  final Set<int> completingTaskIds;
}

final class SkillTaskCompleteFailure extends SkillTaskState {
  const SkillTaskCompleteFailure({
    required this.taskId,
    required this.message,
    this.fieldErrors = const {},
    this.completingTaskIds = const {},
  });

  final int taskId;
  final String message;

  /// Field-level validation messages from a 422 response, keyed by field.
  final Map<String, List<String>> fieldErrors;

  @override
  final Set<int> completingTaskIds;
}
