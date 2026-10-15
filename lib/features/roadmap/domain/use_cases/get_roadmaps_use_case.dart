import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/roadmap/domain/entities/paginated_roadmaps_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmaps_params.dart';
import 'package:MatchIn/features/roadmap/domain/repositories/roadmap_repository.dart';
import 'package:dartz/dartz.dart';

class GetRoadmapsUseCase {
  const GetRoadmapsUseCase({required this.repository});

  final RoadmapRepository repository;

  Future<Either<Failure, PaginatedRoadmapsEntity>> call({
    RoadmapsParams? params,
  }) {
    return repository.getRoadmaps(params: params);
  }
}
