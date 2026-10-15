import 'package:MatchIn/features/roadmap/domain/entities/roadmap_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_pagination_entity.dart';
import 'package:equatable/equatable.dart';

class PaginatedRoadmapsEntity extends Equatable {
  const PaginatedRoadmapsEntity({
    required this.roadmaps,
    required this.pagination,
  });

  final List<RoadmapEntity> roadmaps;
  final RoadmapPaginationEntity pagination;

  @override
  List<Object?> get props => [roadmaps, pagination];
}
