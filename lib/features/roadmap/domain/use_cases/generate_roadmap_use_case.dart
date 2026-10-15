import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/roadmap/domain/entities/generate_roadmap_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_entity.dart';
import 'package:MatchIn/features/roadmap/domain/repositories/roadmap_repository.dart';
import 'package:dartz/dartz.dart';

class GenerateRoadmapUseCase {
  const GenerateRoadmapUseCase({required this.repository});

  final RoadmapRepository repository;

  Future<Either<Failure, RoadmapEntity>> call(GenerateRoadmapParams params) {
    return repository.generateRoadmap(params);
  }
}
