import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/roadmap/domain/entities/complete_roadmap_task_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/generate_roadmap_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/paginated_roadmaps_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/refresh_roadmap_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_task.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmaps_params.dart';
import 'package:dartz/dartz.dart';

abstract class RoadmapRepository {
  Future<Either<Failure, PaginatedRoadmapsEntity>> getRoadmaps({
    RoadmapsParams? params,
  });

  Future<Either<Failure, RoadmapEntity>> getRoadmapDetails(int roadmapId);

  /// Generates a personalized AI roadmap (HTTP 201). Remote-only.
  /// Validation (422) and rate-limit (429) failures surface through
  /// [Failure] with the server message preserved.
  Future<Either<Failure, RoadmapEntity>> generateRoadmap(
    GenerateRoadmapParams params,
  );

  /// Marks a roadmap task completed (HTTP 200). Remote-only.
  /// [CompleteRoadmapTaskParams.taskId] is the backend task id.
  /// Validation (422) and duplicate-completion failures surface through
  /// [Failure] with the server message preserved.
  Future<Either<Failure, RoadmapTask>> completeRoadmapTask(
    CompleteRoadmapTaskParams params,
  );

  /// Refreshes a roadmap with AI (HTTP 200). Remote-only.
  /// [RefreshRoadmapParams.roadmapId] selects the roadmap; the returned
  /// roadmap is authoritative and may carry a different id.
  Future<Either<Failure, RoadmapEntity>> refreshRoadmap(
    RefreshRoadmapParams params,
  );
}
