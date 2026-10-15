import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_entity.dart';
import 'package:MatchIn/features/roadmap/domain/repositories/roadmap_repository.dart';
import 'package:dartz/dartz.dart';

class GetRoadmapDetailsUseCase {
  const GetRoadmapDetailsUseCase({required this.repository});

  final RoadmapRepository repository;

  Future<Either<Failure, RoadmapEntity>> call(int roadmapId) {
    return repository.getRoadmapDetails(roadmapId);
  }
}
