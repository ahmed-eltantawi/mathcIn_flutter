import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:MatchIn/features/profile/data/models/candidate_profile_model.dart';
import 'package:MatchIn/features/profile/data/models/candidate_project_model.dart';
import 'package:MatchIn/features/profile/data/models/candidate_skill_model.dart';
import 'package:MatchIn/features/profile/data/models/career_preference_model.dart';
import 'package:MatchIn/features/profile/data/models/cv_document_model.dart';
import 'package:MatchIn/features/profile/data/models/cv_extraction_status_model.dart';
import 'package:MatchIn/features/profile/data/models/cv_file_download.dart';
import 'package:MatchIn/features/profile/data/models/cv_upload_receipt_model.dart';
import 'package:MatchIn/features/profile/data/models/education_model.dart';
import 'package:MatchIn/features/profile/data/models/experience_model.dart';
import 'package:MatchIn/features/profile/data/models/cv_upload_payload.dart';
import 'package:MatchIn/features/profile/data/models/skill_search_result_model.dart';
import 'package:MatchIn/features/profile/data/models/user_profile_model.dart';
import 'package:MatchIn/features/profile/domain/entities/add_candidate_project_params.dart';
import 'package:MatchIn/features/profile/domain/entities/add_candidate_skill_params.dart';
import 'package:MatchIn/features/profile/domain/entities/add_education_params.dart';
import 'package:MatchIn/features/profile/domain/entities/add_experience_params.dart';
import 'package:MatchIn/features/profile/domain/entities/avatar_upload_input.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_upload_input.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_verify_params.dart';
import 'package:MatchIn/features/profile/domain/entities/save_career_preferences_params.dart';
import 'package:MatchIn/features/profile/domain/entities/update_candidate_profile_params.dart';
import 'package:MatchIn/features/profile/domain/entities/update_candidate_project_params.dart';
import 'package:MatchIn/features/profile/domain/entities/update_education_params.dart';
import 'package:MatchIn/features/profile/domain/entities/update_experience_params.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  @override
  Future<CandidateProfileModel> getCandidateProfile() async {
    final response = await apiConsumer.get(EndPoint.candidateProfile);

    return _parseCandidateProfileResponse(response);
  }

  @override
  Future<CandidateProfileModel> updateCandidateProfile(
    UpdateCandidateProfileParams params,
  ) async {
    final response = await apiConsumer.patch(
      EndPoint.candidateProfile,
      data: {
        if (UpdateCandidateProfileParams.isSet(params.dateOfBirth))
          'date_of_birth': params.dateOfBirth as String?,
        if (UpdateCandidateProfileParams.isSet(params.gender))
          'gender': params.gender as String?,
        if (UpdateCandidateProfileParams.isSet(params.jobTitle))
          'job_title': params.jobTitle as String?,
        if (UpdateCandidateProfileParams.isSet(params.country))
          'country': params.country as String?,
        if (UpdateCandidateProfileParams.isSet(params.state))
          'state': params.state as String?,
        if (UpdateCandidateProfileParams.isSet(params.city))
          'city': params.city as String?,
        if (UpdateCandidateProfileParams.isSet(params.githubUrl))
          'github_url': params.githubUrl as String?,
        if (UpdateCandidateProfileParams.isSet(params.linkedinUrl))
          'linkedin_url': params.linkedinUrl as String?,
        if (UpdateCandidateProfileParams.isSet(params.militaryStatus))
          'military_status': params.militaryStatus as String?,
        if (UpdateCandidateProfileParams.isSet(params.professionalSummary))
          'professional_summary': params.professionalSummary as String?,
      },
    );

    return _parseCandidateProfileResponse(response);
  }

  CandidateProfileModel _parseCandidateProfileResponse(dynamic response) {
    if (response is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid response format for candidate profile',
      );
    }

    final data = response['data'];

    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid candidate profile data format');
    }

    return CandidateProfileModel.fromJson(data);
  }

  // Skills
  @override
  Future<List<CandidateSkillModel>> getCandidateSkills() async {
    final response = await apiConsumer.get(EndPoint.candidateSkills);

    if (response is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid response format for candidate skills',
      );
    }

    final data = response['data'];

    if (data is! List) {
      throw const FormatException('Invalid candidate skills data format');
    }

    return data
        .map(
          (skill) =>
              CandidateSkillModel.fromJson(skill as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<CandidateSkillModel> addCandidateSkill(
    AddCandidateSkillParams params,
  ) async {
    // NOTE(swagger): the documented example also shows
    // proficiency_level and years_of_experience, but the confirmed
    // request shape used here stays name-only until live backend
    // verification. Do not add fields on assumption.
    final response = await apiConsumer.post(
      EndPoint.candidateSkills,
      data: {'name': params.name},
    );

    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid response format for added skill');
    }

    final data = response['data'];

    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid added skill data format');
    }

    return CandidateSkillModel.fromJson(data);
  }

  @override
  Future<void> removeCandidateSkill(int candidateSkillId) async {
    await apiConsumer.delete(EndPoint.candidateSkill(candidateSkillId));
  }

  @override
  Future<List<SkillSearchResultModel>> searchSkills(String query) async {
    final response = await apiConsumer.get(
      EndPoint.searchSkills,
      queryParameters: {ApiKey.skillsQuery: query},
    );

    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid response format for skill search');
    }

    final data = response['data'];

    if (data is! List) {
      throw const FormatException('Invalid skill search data format');
    }

    return data
        .map(
          (item) =>
              SkillSearchResultModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  // Projects
  @override
  Future<List<CandidateProjectModel>> getProjects() async {
    final response = await apiConsumer.get(EndPoint.candidateProjects);

    if (response is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid response format for candidate projects',
      );
    }

    final data = response['data'];

    if (data is! List) {
      throw const FormatException('Invalid candidate projects data format');
    }

    return data
        .map(
          (project) =>
              CandidateProjectModel.fromJson(project as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<CandidateProjectModel> getProject(int projectId) async {
    final response = await apiConsumer.get(
      EndPoint.candidateProject(projectId),
    );

    final project = _parseProjectResponse(response);
    if (project == null) {
      throw const FormatException('Invalid candidate project data format');
    }
    return project;
  }

  CandidateProjectModel? _parseProjectResponse(dynamic response) {
    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid candidate project response format');
    }

    final data = response['data'];

    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid candidate project data format');
    }

    return CandidateProjectModel.tryParseMutation(data);
  }

  @override
  Future<CandidateProjectModel?> addCandidateProject(
    AddCandidateProjectParams params,
  ) async {
    final response = await apiConsumer.post(
      EndPoint.candidateProjects,
      data: {
        'name': params.name,
        if (params.description != null) 'description': params.description,
        if (params.technologies.isNotEmpty) 'technologies': params.technologies,
        if (params.projectUrl != null) 'project_url': params.projectUrl,
        if (params.githubUrl != null) 'github_url': params.githubUrl,
        if (params.startDate != null) 'start_date': params.startDate,
        if (params.endDate != null) 'end_date': params.endDate,
      },
    );

    return _parseProjectResponse(response);
  }

  @override
  Future<CandidateProjectModel?> updateCandidateProject(
    UpdateCandidateProjectParams params,
  ) async {
    final response = await apiConsumer.patch(
      EndPoint.candidateProject(params.projectId),
      data: {
        if (UpdateCandidateProjectParams.isSet(params.name))
          'name': params.name as String?,
        if (UpdateCandidateProjectParams.isSet(params.description))
          'description': params.description as String?,
        if (UpdateCandidateProjectParams.isSet(params.technologies))
          'technologies': params.technologies as List<String>?,
        if (UpdateCandidateProjectParams.isSet(params.projectUrl))
          'project_url': params.projectUrl as String?,
        if (UpdateCandidateProjectParams.isSet(params.githubUrl))
          'github_url': params.githubUrl as String?,
        if (UpdateCandidateProjectParams.isSet(params.startDate))
          'start_date': params.startDate as String?,
        if (UpdateCandidateProjectParams.isSet(params.endDate))
          'end_date': params.endDate as String?,
      },
    );

    return _parseProjectResponse(response);
  }

  @override
  Future<void> deleteCandidateProject(int projectId) async {
    await apiConsumer.delete(EndPoint.candidateProject(projectId));
  }

  // Candidate Educations

  @override
  Future<List<EducationModel>> getEducations() async {
    final response = await apiConsumer.get(EndPoint.candidateEducations);

    if (response is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid response format for candidate educations',
      );
    }

    final data = response['data'];

    if (data is! List) {
      throw const FormatException('Invalid candidate educations data format');
    }

    return data
        .map(
          (education) =>
              EducationModel.fromJson(education as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<EducationModel?> addEducation(AddEducationParams params) async {
    final response = await apiConsumer.post(
      EndPoint.candidateEducations,
      data: {
        'institution': params.institution,
        if (params.degree != null) 'degree': params.degree,
        if (params.fieldOfStudy != null) 'field_of_study': params.fieldOfStudy,
        if (params.educationLevel != null)
          'education_level': params.educationLevel,
        if (params.grade != null) 'grade': params.grade,
        if (params.description != null) 'description': params.description,
        'is_current': params.isCurrent,
        if (params.startDate != null) 'start_date': params.startDate,
        if (params.endDate != null) 'end_date': params.endDate,
      },
    );

    return _parseEducationResponse(response);
  }

  @override
  Future<EducationModel?> updateEducation(UpdateEducationParams params) async {
    final response = await apiConsumer.patch(
      EndPoint.candidateEducation(params.educationId),
      data: {
        if (UpdateEducationParams.isSet(params.institution))
          'institution': params.institution as String?,
        if (UpdateEducationParams.isSet(params.degree))
          'degree': params.degree as String?,
        if (UpdateEducationParams.isSet(params.fieldOfStudy))
          'field_of_study': params.fieldOfStudy as String?,
        if (UpdateEducationParams.isSet(params.educationLevel))
          'education_level': params.educationLevel as String?,
        if (UpdateEducationParams.isSet(params.grade))
          'grade': params.grade as String?,
        if (UpdateEducationParams.isSet(params.description))
          'description': params.description as String?,
        if (UpdateEducationParams.isSet(params.isCurrent))
          'is_current': params.isCurrent as bool?,
        if (UpdateEducationParams.isSet(params.startDate))
          'start_date': params.startDate as String?,
        if (UpdateEducationParams.isSet(params.endDate))
          'end_date': params.endDate as String?,
      },
    );

    return _parseEducationResponse(response);
  }

  @override
  Future<void> deleteEducation(int educationId) async {
    await apiConsumer.delete(EndPoint.candidateEducation(educationId));
  }

  EducationModel? _parseEducationResponse(dynamic response) {
    if (response is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid candidate education response format',
      );
    }

    final data = response['data'];

    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid candidate education data format');
    }

    return EducationModel.tryParseMutation(data);
  }

  // Candidate Experiences

  @override
  Future<List<ExperienceModel>> getExperiences() async {
    final response = await apiConsumer.get(EndPoint.candidateExperiences);

    if (response is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid response format for candidate experiences',
      );
    }

    final data = response['data'];

    if (data is! List) {
      throw const FormatException('Invalid candidate experiences data format');
    }

    return data
        .map(
          (experience) =>
              ExperienceModel.fromJson(experience as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<ExperienceModel?> addExperience(AddExperienceParams params) async {
    final response = await apiConsumer.post(
      EndPoint.candidateExperiences,
      data: {
        'job_title': params.jobTitle,
        'company_name': params.companyName,
        if (params.employmentType != null)
          'employment_type': params.employmentType,
        if (params.country != null) 'country': params.country,
        if (params.city != null) 'city': params.city,
        if (params.description != null) 'description': params.description,
        if (params.technologies.isNotEmpty) 'technologies': params.technologies,
        'is_current': params.isCurrent,
        if (params.startDate != null) 'start_date': params.startDate,
        if (params.endDate != null) 'end_date': params.endDate,
      },
    );

    return _parseExperienceResponse(response);
  }

  @override
  Future<ExperienceModel?> updateExperience(
    UpdateExperienceParams params,
  ) async {
    final response = await apiConsumer.patch(
      EndPoint.candidateExperience(params.experienceId),
      data: {
        if (UpdateExperienceParams.isSet(params.jobTitle))
          'job_title': params.jobTitle as String?,
        if (UpdateExperienceParams.isSet(params.companyName))
          'company_name': params.companyName as String?,
        if (UpdateExperienceParams.isSet(params.employmentType))
          'employment_type': params.employmentType as String?,
        if (UpdateExperienceParams.isSet(params.country))
          'country': params.country as String?,
        if (UpdateExperienceParams.isSet(params.city))
          'city': params.city as String?,
        if (UpdateExperienceParams.isSet(params.description))
          'description': params.description as String?,
        if (UpdateExperienceParams.isSet(params.technologies))
          'technologies': params.technologies as List<String>?,
        if (UpdateExperienceParams.isSet(params.isCurrent))
          'is_current': params.isCurrent as bool?,
        if (UpdateExperienceParams.isSet(params.startDate))
          'start_date': params.startDate as String?,
        if (UpdateExperienceParams.isSet(params.endDate))
          'end_date': params.endDate as String?,
      },
    );

    return _parseExperienceResponse(response);
  }

  @override
  Future<void> deleteExperience(int experienceId) async {
    await apiConsumer.delete(EndPoint.candidateExperience(experienceId));
  }

  ExperienceModel? _parseExperienceResponse(dynamic response) {
    if (response is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid candidate experience response format',
      );
    }

    final data = response['data'];

    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid candidate experience data format');
    }

    return ExperienceModel.tryParseMutation(data);
  }

  // CV Upload

  @override
  Future<CvUploadReceiptModel?> uploadCv(
    CvUploadInput input, {
    void Function(int sentBytes, int totalBytes)? onSendProgress,
  }) async {
    final response = await apiConsumer.post(
      EndPoint.cvUpload,
      data: CvUploadPayload.formData(input),
      isFormData: true,
      onSendProgress: onSendProgress,
    );

    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid CV upload response format');
    }

    return CvUploadReceiptModel.tryParseReceipt(response);
  }

  @override
  Future<CvExtractionStatusModel> getCvStatus(int cvDocumentId) async {
    final response = await apiConsumer.get(EndPoint.cvStatus(cvDocumentId));

    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid CV status response format');
    }

    return CvExtractionStatusModel.fromJson(response);
  }

  @override
  Future<List<CvDocumentModel>> getCvHistory() async {
    final response = await apiConsumer.get(EndPoint.cvHistory);

    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid CV history response format');
    }

    final data = response['data'];
    final List<dynamic> rawItems;
    if (data is List) {
      rawItems = data;
    } else if (data is Map<String, dynamic>) {
      final nested =
          data['items'] ?? data['documents'] ?? data['data'] ?? const [];
      rawItems = nested is List ? nested : const [];
    } else {
      rawItems = const [];
    }
    final documents = <CvDocumentModel>[];
    for (final entry in rawItems) {
      if (entry is! Map<String, dynamic>) continue;
      try {
        documents.add(CvDocumentModel.fromJson(entry));
      } catch (_) {
        continue;
      }
    }
    return documents;
  }

  @override
  Future<CvExtractionStatusModel> retryCvExtraction(int cvDocumentId) async {
    final response = await apiConsumer.post(EndPoint.cvRetry(cvDocumentId));

    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid CV retry response format');
    }

    return CvExtractionStatusModel.fromJson(response);
  }

  @override
  Future<void> verifyExtraction(CvVerifyParams params) async {
    await apiConsumer.post(
      EndPoint.cvVerifyExtraction(params.extractionId),
      data: params.toJson(),
    );
  }

  @override
  Future<CvFileDownload> downloadCv({int? cvDocumentId}) async {
    // Prefer the inline preview endpoint, then the native file endpoint
    // when the backend answers 404 for the preview route.
    try {
      final preview = await apiConsumer.downloadBytes(
        cvDocumentId == null
            ? EndPoint.cvPreview
            : EndPoint.cvPreviewDocument(cvDocumentId),
      );
      if (preview.bytes.isNotEmpty) {
        return CvFileDownload(
          bytes: preview.bytes,
          fileName: preview.fileName,
          mimeType: preview.mimeType,
        );
      }
    } on ServerException catch (e) {
      if (e.errorModel.statusCode != 404) rethrow;
    }
    final file = await apiConsumer.downloadBytes(
      cvDocumentId == null
          ? EndPoint.cvFile
          : EndPoint.cvFileDocument(cvDocumentId),
    );
    if (file.bytes.isEmpty) {
      throw const FormatException('Empty CV file response');
    }
    return CvFileDownload(
      bytes: file.bytes,
      fileName: file.fileName,
      mimeType: file.mimeType,
    );
  }

  // Avatar Upload
  @override
  Future<void> uploadAvatar(AvatarUploadInput input) async {
    // TODO(avatar-backend): implement the multipart upload once the
    // endpoint, HTTP method, field name, and response schema are
    // documented. Do NOT invent them here. This throw intentionally
    // fires before any network operation.
    throw UnimplementedError(
      'Avatar upload API contract is pending backend support.',
    );
  }

  // career preferences

  @override
  Future<CareerPreferenceModel?> getCareerPreferences() async {
    final response = await apiConsumer.get(EndPoint.careerPreferences);

    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid career preferences response format');
    }

    final data = response['data'];

    if (data == null) {
      return null;
    }

    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid career preferences data format');
    }

    return CareerPreferenceModel.fromJson(data);
  }

  @override
  Future<CareerPreferenceModel> saveCareerPreferences(
    SaveCareerPreferencesParams params,
  ) async {
    final response = await apiConsumer.patch(
      EndPoint.careerPreferences,
      data: {
        if (SaveCareerPreferencesParams.isSet(params.targetRole))
          'target_role': params.targetRole as String?,

        if (SaveCareerPreferencesParams.isSet(params.jobType))
          'job_type': params.jobType as String?,

        if (SaveCareerPreferencesParams.isSet(params.workMode))
          'work_mode': params.workMode as String?,

        if (SaveCareerPreferencesParams.isSet(params.preferredCountry))
          'preferred_country': params.preferredCountry as String?,

        if (SaveCareerPreferencesParams.isSet(params.preferredCity))
          'preferred_city': params.preferredCity as String?,

        if (SaveCareerPreferencesParams.isSet(params.experienceLevel))
          'experience_level': params.experienceLevel as String?,

        if (SaveCareerPreferencesParams.isSet(params.careerGoal))
          'career_goal': params.careerGoal as String?,

        if (SaveCareerPreferencesParams.isSet(params.openToRelocation))
          'open_to_relocation': params.openToRelocation as bool?,

        if (SaveCareerPreferencesParams.isSet(params.targetRoles))
          'target_roles': params.targetRoles as List<String>?,

        if (SaveCareerPreferencesParams.isSet(params.preferredIndustries))
          'preferred_industries': params.preferredIndustries as List<String>?,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid career preferences response format');
    }

    final data = response['data'];

    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid career preferences data format');
    }

    return CareerPreferenceModel.fromJson(data);
  }

  @override
  Future<UserProfileModel> getUserProfile() async {
    final response = await apiConsumer.get(EndPoint.currentUser);
    return UserProfileModel.fromJson(response as Map<String, dynamic>);
  }
}
