import 'package:MatchIn/features/roadmap/domain/entities/roadmap_entity.dart';
import 'package:MatchIn/features/roadmap/domain/repositories/roadmap_repository.dart';

/// Synchronous-feel durable cache reads for instant first paint.
/// Never fails: returns null when nothing (usable) was cached.
class GetCachedRoadmapUseCase {
  const GetCachedRoadmapUseCase({required this.repository});

  final RoadmapRepository repository;

  Future<List<RoadmapEntity>?> cachedRoadmaps() {
    return repository.getCachedRoadmaps();
  }

  Future<RoadmapEntity?> cachedRoadmapDetails(int roadmapId) {
    return repository.getCachedRoadmapDetails(roadmapId);
  }
}
