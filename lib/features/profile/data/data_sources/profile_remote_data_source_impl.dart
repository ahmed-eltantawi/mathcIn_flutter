import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:MatchIn/features/profile/data/models/candidate_profile_model.dart';
import 'package:MatchIn/features/profile/data/models/candidate_project_model.dart';
import 'package:MatchIn/features/profile/data/models/candidate_skill_model.dart';
import 'package:MatchIn/features/profile/data/models/skill_search_result_model.dart';
import 'package:MatchIn/features/profile/domain/entities/add_candidate_project_params.dart';
import 'package:MatchIn/features/profile/domain/entities/add_candidate_skill_params.dart';
import 'package:MatchIn/features/profile/domain/entities/update_candidate_project_params.dart';

class ProfileRemoteDataSourceImpl
    implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl({
    required this.apiConsumer,
  });

  final ApiConsumer apiConsumer;

  @override
  Future<CandidateProfileModel>
  getCandidateProfile() async {
    final response = await apiConsumer.get(
      EndPoint.candidateProfile,
    );

    if (response is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid response format for candidate profile',
      );
    }

    final data = response['data'];

    if (data is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid candidate profile data format',
      );
    }

    return CandidateProfileModel.fromJson(data);
  }

  // Skills
  @override
  Future<List<CandidateSkillModel>>
  getCandidateSkills() async {
    final response = await apiConsumer.get(
      EndPoint.candidateSkills,
    );

    if (response is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid response format for candidate skills',
      );
    }

    final data = response['data'];

    if (data is! List) {
      throw const FormatException(
        'Invalid candidate skills data format',
      );
    }

    return data
        .map(
          (skill) => CandidateSkillModel.fromJson(
            skill as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<CandidateSkillModel> addCandidateSkill(
    AddCandidateSkillParams params,
  ) async {
    final response = await apiConsumer.post(
      EndPoint.candidateSkills,
      data: {'name': params.name},
    );

    if (response is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid response format for added skill',
      );
    }

    final data = response['data'];

    if (data is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid added skill data format',
      );
    }

    return CandidateSkillModel.fromJson(data);
  }

  @override
  Future<void> removeCandidateSkill(
    int candidateSkillId,
  ) async {
    await apiConsumer.delete(
      EndPoint.candidateSkill(candidateSkillId),
    );
  }

  @override
  Future<List<SkillSearchResultModel>> searchSkills(
    String query,
  ) async {
    final response = await apiConsumer.get(
      EndPoint.searchSkills,
      queryParameters: {'q': query},
    );

    if (response is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid response format for skill search',
      );
    }

    final data = response['data'];

    if (data is! List) {
      throw const FormatException(
        'Invalid skill search data format',
      );
    }

    return data
        .map(
          (item) => SkillSearchResultModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // Projects
  @override
  Future<List<CandidateProjectModel>> getProjects() async {
    final response = await apiConsumer.get(
      EndPoint.candidateProjects,
    );

    if (response is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid response format for candidate projects',
      );
    }

    final data = response['data'];

    if (data is! List) {
      throw const FormatException(
        'Invalid candidate projects data format',
      );
    }

    return data
        .map(
          (project) => CandidateProjectModel.fromJson(
            project as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<CandidateProjectModel> getProject(
    int projectId,
  ) async {
    final response = await apiConsumer.get(
      EndPoint.candidateProject(projectId),
    );

    return _parseProjectResponse(response);
  }

  CandidateProjectModel _parseProjectResponse(
    dynamic response,
  ) {
    if (response is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid candidate project response format',
      );
    }

    final data = response['data'];

    if (data is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid candidate project data format',
      );
    }

    return CandidateProjectModel.fromJson(data);
  }

  @override
  Future<CandidateProjectModel> addCandidateProject(
    AddCandidateProjectParams params,
  ) async {
    final response = await apiConsumer.post(
      EndPoint.candidateProjects,
      data: {
        'name': params.name,
        if (params.description != null)
          'description': params.description,
        if (params.technologies.isNotEmpty)
          'technologies': params.technologies,
        if (params.projectUrl != null)
          'project_url': params.projectUrl,
        if (params.githubUrl != null)
          'github_url': params.githubUrl,
        if (params.startDate != null)
          'start_date': params.startDate,
        if (params.endDate != null)
          'end_date': params.endDate,
      },
    );

    return _parseProjectResponse(response);
  }

  @override
  Future<CandidateProjectModel> updateCandidateProject(
    UpdateCandidateProjectParams params,
  ) async {
    final response = await apiConsumer.patch(
      EndPoint.candidateProject(params.projectId),
      data: {
        if (params.name != null) 'name': params.name,
        if (params.description != null)
          'description': params.description,
        if (params.technologies != null)
          'technologies': params.technologies,
        if (params.projectUrl != null)
          'project_url': params.projectUrl,
        if (params.githubUrl != null)
          'github_url': params.githubUrl,
        if (params.startDate != null)
          'start_date': params.startDate,
        if (params.endDate != null)
          'end_date': params.endDate,
      },
    );

    return _parseProjectResponse(response);
  }

  @override
  Future<void> deleteCandidateProject(int projectId) async {
    await apiConsumer.delete(
      EndPoint.candidateProject(projectId),
    );
  }
}
