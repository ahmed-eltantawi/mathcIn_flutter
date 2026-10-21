import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/roadmap/domain/entities/complete_roadmap_task_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_task.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/complete_roadmap_task_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/repositories/roadmap_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'skill_task_state.dart';

/// Backend task completion for the roadmap Skill Details sheet.
///
/// Optimistic-first: the intended completion applies to the durable local
/// cache and paints immediately ([SkillTaskOptimisticUpdate]); the PATCH
/// then confirms it. Offline the change is queued ([SkillTaskQueuedOffline]);
/// on confirmed failure the optimistic mark rolls back and
/// [SkillTaskCompleteFailure] is emitted. In-flight task ids are tracked
/// so duplicate taps for the same task collapse into one request.
/// This cubit holds request status only; roadmap content stays owned by
/// [RoadmapCubit].
class SkillTaskCubit extends Cubit<SkillTaskState> {
  SkillTaskCubit({
    required this.completeRoadmapTaskUseCase,
    required this.repository,
  }) : super(const SkillTaskInitial());

  final CompleteRoadmapTaskUseCase completeRoadmapTaskUseCase;
  final RoadmapRepository repository;

  final Set<int> _completingTaskIds = {};

  /// Completes the backend task [taskId] (a [RoadmapTask.id]).
  /// [roadmapId] targets the cached roadmap for optimistic + offline
  /// updates. Duplicate calls while a request for the same task is
  /// running are ignored.
  Future<void> completeTask({
    required int taskId,
    int? roadmapId,
    String? completionNote,
  }) async {
    if (_completingTaskIds.contains(taskId)) return;
    _completingTaskIds.add(taskId);
    if (isClosed) return;
    emit(
      SkillTaskCompleting(
        completingTaskIds: Set<int>.unmodifiable(_completingTaskIds),
      ),
    );

    // --- Optimistic paint: persist the intent locally first so the UI
    // --- updates without waiting for the network round-trip. Missing
    // --- cache (or a non-conforming repository double) skips this and
    // --- keeps the legacy request-then-paint behavior. ---
    if (roadmapId != null) {
      RoadmapTask? optimistic;
      try {
        optimistic = await repository.applyLocalCompletion(
          roadmapId: roadmapId,
          taskId: taskId,
        );
      } catch (_) {
        optimistic = null;
      }
      if (optimistic != null && !isClosed) {
        emit(
          SkillTaskOptimisticUpdate(
            taskId: taskId,
            completingTaskIds: Set<int>.unmodifiable(_completingTaskIds),
          ),
        );
      }
    }

    final result = await completeRoadmapTaskUseCase(
      CompleteRoadmapTaskParams(
        taskId: taskId,
        completionNote: completionNote,
        roadmapId: roadmapId,
      ),
    );
    _completingTaskIds.remove(taskId);
    if (isClosed) return;
    final remaining = Set<int>.unmodifiable(_completingTaskIds);
    Failure? failure;
    RoadmapTask? completedTask;
    result.fold((left) => failure = left, (right) => completedTask = right);
    final currentFailure = failure;
    final confirmedTask = completedTask;
    if (currentFailure != null) {
      // OfflineFailure from the repository means the mutation was
      // persisted locally and queued for sync — not a failed action.
      if (currentFailure is OfflineFailure) {
        emit(
          SkillTaskQueuedOffline(taskId: taskId, completingTaskIds: remaining),
        );
        return;
      }
      // Confirmed failure: roll back the optimistic mark so the UI
      // never shows a completion the backend rejected. Best effort:
      // the next authoritative fetch self-heals the cache regardless.
      if (roadmapId != null) {
        try {
          await repository.revertLocalCompletion(
            roadmapId: roadmapId,
            taskId: taskId,
          );
        } catch (_) {
          // Ignore rollback errors; the failure below still surfaces.
        }
      }
      if (isClosed) return;
      emit(
        SkillTaskCompleteFailure(
          taskId: taskId,
          message: currentFailure.message,
          fieldErrors: currentFailure is ServerFailure
              ? currentFailure.fieldErrors
              : const {},
          completingTaskIds: remaining,
        ),
      );
      return;
    }
    final task = confirmedTask!;
    emit(
      SkillTaskCompleteSuccess(
        taskId: task.id,
        completedAt: task.completedAt,
        completingTaskIds: remaining,
      ),
    );
  }
}
