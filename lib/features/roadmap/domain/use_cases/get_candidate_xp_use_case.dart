import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/roadmap/domain/entities/candidate_xp_entity.dart';
import 'package:MatchIn/features/roadmap/domain/repositories/roadmap_repository.dart';
import 'package:dartz/dartz.dart';

class GetCandidateXpUseCase {
  const GetCandidateXpUseCase({required this.repository});

  final RoadmapRepository repository;

  Future<Either<Failure, CandidateXpEntity>> call({int? roadmapId}) {
    return repository.getCandidateXp(roadmapId: roadmapId);
  }
}
