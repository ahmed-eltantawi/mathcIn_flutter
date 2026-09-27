part of 'roadmap_cubit.dart';

@immutable
sealed class RoadmapState {}

final class RoadmapInitial extends RoadmapState {}

final class RoadmapLoading extends RoadmapState {}

final class RoadmapSuccess extends RoadmapState {
  RoadmapSuccess({
    required this.nodes,
    this.rewardedAdXp = 0,
  });

  final List<RoadmapNode> nodes;
  final int rewardedAdXp;
}

final class RoadmapFailure extends RoadmapState {
  RoadmapFailure({required this.errorMessage});

  final String errorMessage;
}
