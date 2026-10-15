import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/roadmap/domain/entities/refresh_roadmap_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_entity.dart';
import 'package:MatchIn/features/roadmap/domain/repositories/roadmap_repository.dart';
import 'package:dartz/dartz.dart';

class RefreshRoadmapUseCase {
  const RefreshRoadmapUseCase({required this.repository});

  final RoadmapRepository repository;

  Future<Either<Failure, RoadmapEntity>> call(RefreshRoadmapParams params) {
    return repository.refreshRoadmap(params);
  }
}
