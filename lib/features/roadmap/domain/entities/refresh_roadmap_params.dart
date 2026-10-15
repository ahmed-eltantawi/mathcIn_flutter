import 'package:equatable/equatable.dart';

/// Parameters for an AI refresh of a roadmap.
///
/// [roadmapId] is the backend [RoadmapEntity.id] the refresh is
/// requested for. [reason] is optional free text; it is omitted from
/// the request when absent or blank. JSON serialization lives in the
/// Data Layer; this class carries values only.
class RefreshRoadmapParams extends Equatable {
  const RefreshRoadmapParams({required this.roadmapId, this.reason});

  final int roadmapId;
  final String? reason;

  @override
  List<Object?> get props => [roadmapId, reason];
}
