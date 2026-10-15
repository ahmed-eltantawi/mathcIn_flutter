import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/roadmap/domain/entities/complete_roadmap_task_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_task.dart';
import 'package:MatchIn/features/roadmap/domain/repositories/roadmap_repository.dart';
import 'package:dartz/dartz.dart';

class CompleteRoadmapTaskUseCase {
  const CompleteRoadmapTaskUseCase({required this.repository});

  final RoadmapRepository repository;

  Future<Either<Failure, RoadmapTask>> call(CompleteRoadmapTaskParams params) {
    return repository.completeRoadmapTask(params);
  }
}
