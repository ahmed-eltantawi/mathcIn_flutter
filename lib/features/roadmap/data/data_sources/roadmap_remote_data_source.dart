import 'package:MatchIn/features/roadmap/data/models/award_xp_response_model.dart';
import 'package:MatchIn/features/roadmap/data/models/candidate_xp_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_pagination_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_task_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_xp_metrics_model.dart';
import 'package:MatchIn/features/roadmap/domain/entities/award_xp_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/complete_roadmap_task_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/generate_roadmap_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/refresh_roadmap_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmaps_params.dart';

abstract class RoadmapRemoteDataSource {
  Future<({List<RoadmapModel> roadmaps, RoadmapPaginationModel pagination})>
  getRoadmaps({RoadmapsParams? params});

  Future<RoadmapModel> getRoadmapDetails(int roadmapId);

  /// POST /roadmaps. The response envelope matches roadmap details,
  /// so [RoadmapModel] parses it. AI generation may take longer than
  /// normal requests; no custom timeout is applied (global Dio
  /// configuration is intentionally untouched).
  Future<RoadmapModel> generateRoadmap(GenerateRoadmapParams params);

  /// PATCH /roadmap-tasks/{id}/complete. The response envelope carries a
  /// single task, so [RoadmapTaskModel] parses it. `completion_note` is
  /// omitted when absent.
  Future<RoadmapTaskModel> completeRoadmapTask(
    CompleteRoadmapTaskParams params,
  );

  /// POST /roadmaps/{id}/refresh. Returns the updated roadmap in the
  /// same envelope as details/generate, so [RoadmapModel] parses it.
  /// `reason` is sent only when present and non-blank.
  Future<RoadmapModel> refreshRoadmap(RefreshRoadmapParams params);

  /// GET /roadmaps/xp — canonical candidate-wide XP summary.
  /// The alternate `/candidate/xp` route is intentionally never called
  /// for the same action (single canonical route per operation).
  Future<CandidateXpModel> getCandidateXp({int? roadmapId});

  /// GET /roadmaps/{roadmap}/xp — XP/completion metrics for one roadmap.
  Future<RoadmapXpMetricsModel> getRoadmapXp(int roadmapId);

  /// PATCH /roadmaps/xp — canonical award route for roadmap achievements
  /// (e.g. treasure-box +50 XP). The alternate `/candidate/xp` route and
  /// the per-roadmap `PATCH /roadmaps/{roadmap}/xp` route are intentionally
  /// never called for the same action, so one reward produces one request.
  Future<AwardXpResponseModel> awardXp(AwardXpParams params);
}
