import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/features/roadmap/data/data_sources/roadmap_remote_data_source.dart';
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

class RoadmapRemoteDataSourceImpl implements RoadmapRemoteDataSource {
  RoadmapRemoteDataSourceImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  @override
  Future<({List<RoadmapModel> roadmaps, RoadmapPaginationModel pagination})>
  getRoadmaps({RoadmapsParams? params}) async {
    final effectiveParams = params ?? const RoadmapsParams();
    final response = await apiConsumer.get(
      EndPoint.roadmaps,
      queryParameters: effectiveParams.toJson(),
    );

    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid roadmaps response format');
    }

    final data = response['data'];
    if (data is! List) {
      throw const FormatException('Invalid roadmaps data format');
    }

    final meta = response['meta'];
    if (meta is! Map<String, dynamic>) {
      throw const FormatException('Invalid roadmaps pagination format');
    }

    final roadmaps = data
        .whereType<Map<String, dynamic>>()
        .map(RoadmapModel.fromJson)
        .toList();
    return (
      roadmaps: roadmaps,
      pagination: RoadmapPaginationModel.fromJson(meta),
    );
  }

  @override
  Future<RoadmapModel> getRoadmapDetails(int roadmapId) async {
    final response = await apiConsumer.get(EndPoint.roadmapDetails(roadmapId));

    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid roadmap details response format');
    }

    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid roadmap details data format');
    }

    return RoadmapModel.fromJson(data);
  }

  @override
  Future<RoadmapModel> generateRoadmap(GenerateRoadmapParams params) async {
    final response = await apiConsumer.post(
      EndPoint.roadmaps,
      data: params.toJson(),
    );

    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid roadmap generation response');
    }

    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid roadmap generation data format');
    }

    return RoadmapModel.fromJson(data);
  }

  @override
  Future<RoadmapTaskModel> completeRoadmapTask(
    CompleteRoadmapTaskParams params,
  ) async {
    final response = await apiConsumer.patch(
      EndPoint.roadmapTaskComplete(params.taskId),
      data: {
        if (params.completionNote != null)
          'completion_note': params.completionNote,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid task completion response format');
    }

    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid task completion data format');
    }

    return RoadmapTaskModel.fromJson(data);
  }

  @override
  Future<RoadmapModel> refreshRoadmap(RefreshRoadmapParams params) async {
    final reason = params.reason?.trim();
    final response = await apiConsumer.post(
      EndPoint.roadmapRefresh(params.roadmapId),
      data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
    );

    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid roadmap refresh response format');
    }

    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid roadmap refresh data format');
    }

    return RoadmapModel.fromJson(data);
  }

  @override
  Future<CandidateXpModel> getCandidateXp({int? roadmapId}) async {
    final response = await apiConsumer.get(
      EndPoint.roadmapXp,
      queryParameters: roadmapId == null ? null : {'roadmap_id': roadmapId},
    );

    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid candidate XP response format');
    }

    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid candidate XP data format');
    }

    return CandidateXpModel.fromJson(data);
  }

  @override
  Future<RoadmapXpMetricsModel> getRoadmapXp(int roadmapId) async {
    final response = await apiConsumer.get(
      EndPoint.roadmapDetailsXp(roadmapId),
    );

    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid roadmap XP response format');
    }

    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid roadmap XP data format');
    }

    return RoadmapXpMetricsModel.fromJson(data);
  }

  @override
  Future<AwardXpResponseModel> awardXp(AwardXpParams params) async {
    final response = await apiConsumer.patch(
      EndPoint.roadmapXp,
      data: params.toJson(),
    );

    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid award XP response format');
    }

    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid award XP data format');
    }

    return AwardXpResponseModel.fromJson(data);
  }
}
