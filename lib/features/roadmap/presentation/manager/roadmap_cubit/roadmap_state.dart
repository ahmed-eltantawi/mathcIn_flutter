part of 'roadmap_cubit.dart';

@immutable
sealed class RoadmapState {}

final class RoadmapInitial extends RoadmapState {}

/// Roadmap details loading (initial selection, selection change, retry).
final class RoadmapLoading extends RoadmapState {}

/// Roadmap list loading (first page, retry).
final class RoadmapsLoading extends RoadmapState {}

/// Paginated roadmap list. The node path is NOT rendered from this
/// state: after the first load the cubit chains into details loading
/// for the selected roadmap. The selector sheet reads this state to
/// refresh its rows after Load More.
final class RoadmapsSuccess extends RoadmapState {
  RoadmapsSuccess({
    required this.roadmaps,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    this.isOffline = false,
    this.pendingOpsCount = 0,
  });

  final List<RoadmapEntity> roadmaps;
  final int currentPage;
  final int lastPage;
  final int total;

  /// True when served from the durable cache while offline.
  final bool isOffline;

  /// Durably queued mutations awaiting background sync.
  final int pendingOpsCount;
}

/// Selected roadmap details. The node path maps [details] to visual
/// nodes in the view layer.
final class RoadmapDetailsSuccess extends RoadmapState {
  RoadmapDetailsSuccess({
    required this.details,
    this.rewardedAdXp = 0,
    this.isOffline = false,
    this.pendingOpsCount = 0,
  });

  final RoadmapEntity details;
  final int rewardedAdXp;

  /// True when served from the durable cache while offline or after a
  /// failed refresh (valid cached data stays visible).
  final bool isOffline;

  /// Durably queued mutations awaiting background sync.
  final int pendingOpsCount;
}

/// AI generation in progress. Carries the currently displayed content
/// so the main view never flashes loading over it; the form sheet
/// shows its own progress indicator.
final class RoadmapGenerating extends RoadmapState {
  RoadmapGenerating({this.details, this.rewardedAdXp = 0});

  final RoadmapEntity? details;
  final int rewardedAdXp;
}

/// Generation failed. Carries the content to keep showing plus
/// server feedback for inline display in the form sheet. Never
/// replaces loaded content with a full-screen error.
final class RoadmapGenerateFailure extends RoadmapState {
  RoadmapGenerateFailure({
    required this.message,
    this.fieldErrors = const {},
    this.details,
    this.rewardedAdXp = 0,
  });

  final String message;
  final Map<String, List<String>> fieldErrors;
  final RoadmapEntity? details;
  final int rewardedAdXp;
}

/// AI refresh in progress. Carries the currently displayed content so
/// the main view never flashes loading over it; the refresh sheet
/// shows its own progress indicator. Distinct from [RoadmapGenerating]
/// (create-new) and from GET synchronization.
final class RoadmapAiRefreshing extends RoadmapState {
  RoadmapAiRefreshing({this.details, this.rewardedAdXp = 0});

  final RoadmapEntity? details;
  final int rewardedAdXp;
}

/// AI refresh failed. Carries the content to keep showing plus server
/// feedback for inline display in the refresh sheet. Never replaces
/// loaded content with a full-screen error.
final class RoadmapAiRefreshFailure extends RoadmapState {
  RoadmapAiRefreshFailure({
    required this.message,
    this.fieldErrors = const {},
    this.details,
    this.rewardedAdXp = 0,
  });

  final String message;
  final Map<String, List<String>> fieldErrors;
  final RoadmapEntity? details;
  final int rewardedAdXp;
}

final class RoadmapFailure extends RoadmapState {
  RoadmapFailure({required this.errorMessage});

  final String errorMessage;
}
