import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_xp_metrics_entity.dart';
import 'package:MatchIn/features/roadmap/domain/repositories/roadmap_repository.dart';
import 'package:dartz/dartz.dart';

class GetRoadmapXpUseCase {
  const GetRoadmapXpUseCase({required this.repository});

  final RoadmapRepository repository;

  Future<Either<Failure, RoadmapXpMetricsEntity>> call(int roadmapId) {
    return repository.getRoadmapXp(roadmapId);
  }
}
