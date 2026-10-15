import 'package:MatchIn/features/roadmap/domain/entities/roadmap_pagination_entity.dart';

class RoadmapPaginationModel extends RoadmapPaginationEntity {
  const RoadmapPaginationModel({
    required super.currentPage,
    required super.lastPage,
    required super.perPage,
    required super.total,
  });

  factory RoadmapPaginationModel.fromJson(Map<String, dynamic> json) {
    return RoadmapPaginationModel(
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? 15,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  RoadmapPaginationEntity toEntity() {
    return RoadmapPaginationEntity(
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: perPage,
      total: total,
    );
  }
}
