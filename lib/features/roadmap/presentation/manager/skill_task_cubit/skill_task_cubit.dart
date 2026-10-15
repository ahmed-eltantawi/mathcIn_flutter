import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/roadmap/domain/entities/complete_roadmap_task_params.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/complete_roadmap_task_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'skill_task_state.dart';

/// Backend task completion for the roadmap Skill Details sheet.
///
/// No optimistic updates: a task is reported completed only after the
/// PATCH succeeds. In-flight task ids are tracked so duplicate taps for
/// the same task collapse into a single request. This cubit holds request
/// status only; roadmap content stays owned by [RoadmapCubit].
class SkillTaskCubit extends Cubit<SkillTaskState> {
  SkillTaskCubit({required this.completeRoadmapTaskUseCase})
    : super(const SkillTaskInitial());

  final CompleteRoadmapTaskUseCase completeRoadmapTaskUseCase;

  final Set<int> _completingTaskIds = {};

  /// Completes the backend task [taskId] (a [RoadmapTask.id]).
  /// Duplicate calls while a request for the same task is running are
  /// ignored. Emits failure without touching roadmap content.
  Future<void> completeTask({required int taskId}) async {
    if (_completingTaskIds.contains(taskId)) return;
    _completingTaskIds.add(taskId);
    if (isClosed) return;
    emit(
      SkillTaskCompleting(
        completingTaskIds: Set<int>.unmodifiable(_completingTaskIds),
      ),
    );

    final result = await completeRoadmapTaskUseCase(
      CompleteRoadmapTaskParams(taskId: taskId),
    );
    _completingTaskIds.remove(taskId);
    if (isClosed) return;
    final remaining = Set<int>.unmodifiable(_completingTaskIds);
    result.fold(
      (failure) => emit(
        SkillTaskCompleteFailure(
          taskId: taskId,
          message: failure.message,
          fieldErrors: failure is ServerFailure
              ? failure.fieldErrors
              : const {},
          completingTaskIds: remaining,
        ),
      ),
      (task) => emit(
        SkillTaskCompleteSuccess(
          taskId: task.id,
          completedAt: task.completedAt,
          completingTaskIds: remaining,
        ),
      ),
    );
  }
}
