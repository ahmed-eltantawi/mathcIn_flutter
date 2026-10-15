import 'package:equatable/equatable.dart';

class RoadmapPaginationEntity extends Equatable {
  const RoadmapPaginationEntity({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  bool get hasNextPage => currentPage < lastPage;

  @override
  List<Object?> get props => [currentPage, lastPage, perPage, total];
}
