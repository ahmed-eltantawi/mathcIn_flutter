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

abstract interface class ProfileRemoteDataSource {
  Future<CandidateProfileModel> getCandidateProfile();

  Future<CandidateProfileModel> updateCandidateProfile(
    UpdateCandidateProfileParams params,
  );

  Future<UserProfileModel> getUserProfile();

  // Candidate Skills
  Future<List<CandidateSkillModel>> getCandidateSkills();

  Future<CandidateSkillModel> addCandidateSkill(AddCandidateSkillParams params);

  Future<void> removeCandidateSkill(int candidateSkillId);
  Future<List<SkillSearchResultModel>> searchSkills(String query);

  // Candidate Projects
  Future<List<CandidateProjectModel>> getProjects();

  Future<CandidateProjectModel> getProject(int projectId);

  /// Returns null when the mutation succeeded (2xx) but the response
  /// payload is not a complete record. Callers must refresh from GET
  /// instead of using defaults.
  Future<CandidateProjectModel?> addCandidateProject(
    AddCandidateProjectParams params,
  );

  /// Same incomplete-payload contract as [addCandidateProject].
  Future<CandidateProjectModel?> updateCandidateProject(
    UpdateCandidateProjectParams params,
  );

  Future<void> deleteCandidateProject(int projectId);

  // Candidate Educations
  Future<List<EducationModel>> getEducations();

  /// Returns null when the mutation succeeded (2xx) but the response
  /// payload is not a complete record. Callers must refresh from GET
  /// instead of using defaults.
  Future<EducationModel?> addEducation(AddEducationParams params);

  /// Same incomplete-payload contract as [addEducation].
  Future<EducationModel?> updateEducation(UpdateEducationParams params);

  Future<void> deleteEducation(int educationId);

  // Candidate Experiences
  Future<List<ExperienceModel>> getExperiences();

  /// Returns null when the mutation succeeded (2xx) but the response
  /// payload is not a complete record. Callers must refresh from GET
  /// instead of using defaults.
  Future<ExperienceModel?> addExperience(AddExperienceParams params);

  /// Same incomplete-payload contract as [addExperience].
  Future<ExperienceModel?> updateExperience(UpdateExperienceParams params);

  Future<void> deleteExperience(int experienceId);

  // CV Upload
  /// Returns null when the upload succeeded (2xx) but the response
  /// carries no usable receipt. Callers must refresh the Main Profile
  /// from GET instead of fabricating document data.
  Future<CvUploadReceiptModel?> uploadCv(
    CvUploadInput input, {
    void Function(int sentBytes, int totalBytes)? onSendProgress,
  });

  /// Background extraction status for one CV document
  /// (`GET /cv/status/{cvDocument}`). Never throws for unknown status
  /// tokens: they map to [CvProcessingStatus.unknown].
  Future<CvExtractionStatusModel> getCvStatus(int cvDocumentId);

  /// CV upload history (`GET /cv/history`), newest first when the
  /// backend orders it. Empty when the backend reports no documents.
  Future<List<CvDocumentModel>> getCvHistory();

  /// Retries extraction for a failed document
  /// (`POST /cv/retry/{cvDocument}`). Acceptance is not completion:
  /// callers must poll [getCvStatus] afterwards.
  Future<CvExtractionStatusModel> retryCvExtraction(int cvDocumentId);

  /// Confirms reviewed extraction data
  /// (`POST /cv/extractions/{extraction}/verify`). Uses the real
  /// backend extraction id carried by [params]; never invents one.
  Future<void> verifyExtraction(CvVerifyParams params);

  /// Authenticated binary CV fetch (never JSON-decoded). Prefers the
  /// inline preview endpoint and falls back to the native file endpoint
  /// when the backend answers 404.
  Future<CvFileDownload> downloadCv({int? cvDocumentId});

  // Avatar Upload
  /// Uploads the candidate avatar image.
  ///
  /// TODO(avatar-backend): the endpoint, HTTP method, multipart field,
  /// and response schema are pending backend documentation. Nothing
  /// may call this until the contract lands.
  Future<void> uploadAvatar(AvatarUploadInput input);

  // Career Preferences
  Future<CareerPreferenceModel?> getCareerPreferences();

  Future<CareerPreferenceModel> saveCareerPreferences(
    SaveCareerPreferencesParams params,
  );
}
