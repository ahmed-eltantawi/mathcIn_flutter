part of 'xp_cubit.dart';

@immutable
sealed class RoadmapXpState extends Equatable {
  const RoadmapXpState();
}

final class XpInitial extends RoadmapXpState {
  const XpInitial();

  @override
  List<Object?> get props => [];
}

final class XpLoading extends RoadmapXpState {
  const XpLoading();
  @override
  List<Object?> get props => [];
}

final class XpLoaded extends RoadmapXpState {
  const XpLoaded({
    required this.candidateXp,
    this.roadmapXp,
    this.justLeveledUp = false,
  });

  final CandidateXpEntity candidateXp;
  final RoadmapXpMetricsEntity? roadmapXp;
  final bool justLeveledUp;
  @override
  List<Object?> get props => [candidateXp, roadmapXp, justLeveledUp];
}

final class XpFailure extends RoadmapXpState {
  const XpFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
