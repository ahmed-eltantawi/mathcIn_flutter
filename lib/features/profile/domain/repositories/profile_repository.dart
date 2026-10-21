import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/add_candidate_project_params.dart';
import 'package:MatchIn/features/profile/domain/entities/add_candidate_skill_params.dart';
import 'package:MatchIn/features/profile/domain/entities/add_education_params.dart';
import 'package:MatchIn/features/profile/domain/entities/add_experience_params.dart';
import 'package:MatchIn/features/profile/domain/entities/avatar_upload_input.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_profile_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_project_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_skill_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/career_preference_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_document_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_extraction_status_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_file_download_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_local_file.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_verify_params.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_pending_upload.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_upload_input.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_upload_receipt.dart';
import 'package:MatchIn/features/profile/domain/entities/education_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/experience_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/save_career_preferences_params.dart';
import 'package:MatchIn/features/profile/domain/entities/skill_search_result_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_candidate_profile_params.dart';
import 'package:MatchIn/features/profile/domain/entities/update_candidate_project_params.dart';
import 'package:MatchIn/features/profile/domain/entities/update_education_params.dart';
import 'package:MatchIn/features/profile/domain/entities/update_experience_params.dart';
import 'package:MatchIn/features/profile/domain/entities/user_profile_entity.dart';

abstract class ProfileRepository {
  // Candidate Profile
  Future<Either<Failure, CandidateProfileEntity>> getCandidateProfile();

  Future<Either<Failure, CandidateProfileEntity?>> getCachedCandidateProfile();

  Future<Either<Failure, CandidateProfileEntity>> getCandidateProfileForEdit();

  Future<Either<Failure, UserProfileEntity>> getUserProfile();

  // Candidate Skills
  Future<Either<Failure, List<CandidateSkillEntity>>> getCandidateSkills();

  Future<Either<Failure, CandidateSkillEntity>> addCandidateSkill(
    AddCandidateSkillParams params,
  );

  Future<Either<Failure, Unit>> removeCandidateSkill(int candidateSkillId);
  Future<Either<Failure, List<SkillSearchResultEntity>>> searchSkills(
    String query,
  );

  // Candidate Projects
  Future<Either<Failure, List<CandidateProjectEntity>>> getProjects();

  Future<Either<Failure, CandidateProjectEntity>> getProject(int projectId);

  /// Returns a null entity when the mutation succeeded but the response
  /// payload was incomplete. Callers must refresh from GET in that case.
  Future<Either<Failure, CandidateProjectEntity?>> addCandidateProject(
    AddCandidateProjectParams params,
  );

  /// Same incomplete-payload contract as [addCandidateProject].
  Future<Either<Failure, CandidateProjectEntity?>> updateCandidateProject(
    UpdateCandidateProjectParams params,
  );

  Future<Either<Failure, Unit>> deleteCandidateProject(int projectId);

  // Candidate Educations
  Future<Either<Failure, List<EducationEntity>>> getEducations();

  /// Returns a null entity when the mutation succeeded but the response
  /// payload was incomplete. Callers must refresh from GET in that case.
  Future<Either<Failure, EducationEntity?>> addEducation(
    AddEducationParams params,
  );

  /// Same incomplete-payload contract as [addEducation].
  Future<Either<Failure, EducationEntity?>> updateEducation(
    UpdateEducationParams params,
  );

  Future<Either<Failure, Unit>> deleteEducation(int educationId);

  // Candidate Experiences
  Future<Either<Failure, List<ExperienceEntity>>> getExperiences();

  /// Returns a null entity when the mutation succeeded but the response
  /// payload was incomplete. Callers must refresh from GET in that case.
  Future<Either<Failure, ExperienceEntity?>> addExperience(
    AddExperienceParams params,
  );

  /// Same incomplete-payload contract as [addExperience].
  Future<Either<Failure, ExperienceEntity?>> updateExperience(
    UpdateExperienceParams params,
  );

  Future<Either<Failure, Unit>> deleteExperience(int experienceId);

  // CV Upload
  /// Returns a null receipt when the upload succeeded but the response
  /// carries no usable receipt. The repository records an upload
  /// marker with the local filename, so callers refreshing the Main
  /// Profile from GET still resolve the uploaded document.
  /// Offline selections are stored as pending uploads and reported
  /// as [OfflineFailure].
  Future<Either<Failure, CvUploadReceipt?>> uploadCv(
    CvUploadInput input, {
    void Function(int sentBytes, int totalBytes)? onSendProgress,
  });

  /// Returns the locally stored pending CV upload, if any.
  Future<Either<Failure, CvPendingUpload?>> getPendingCvUpload();

  /// Uploads the stored pending CV. Clears it on success and records
  /// an upload marker; keeps it on failure. Offline reports
  /// [OfflineFailure] without touching the stored file.
  Future<Either<Failure, CvUploadReceipt?>> retryPendingCvUpload();

  /// Returns the CV file bytes kept on this device (pending file
  /// first, otherwise the last uploaded/attempted file), if any.
  Future<Either<Failure, CvLocalFile?>> getLocalCvFile();

  /// Background extraction status for one CV document. Offline reports
  /// [OfflineFailure]; unknown backend status tokens map to
  /// [CvProcessingStatus.unknown] instead of failing.
  Future<Either<Failure, CvExtractionStatusEntity>> getCvStatus(
    int cvDocumentId,
  );

  /// CV upload history, newest first when the backend orders it.
  /// Offline falls back to locally known metadata when available.
  Future<Either<Failure, List<CvDocumentEntity>>> getCvHistory();

  /// Retries extraction for a failed document. Acceptance is not
  /// completion: callers must poll [getCvStatus] afterwards.
  Future<Either<Failure, CvExtractionStatusEntity>> retryCvExtraction(
    int cvDocumentId,
  );

  /// Confirms reviewed extraction data using the real backend
  /// extraction id in [params]. Validation failures surface with the
  /// server message preserved.
  Future<Either<Failure, Unit>> verifyExtraction(CvVerifyParams params);

  /// Authenticated binary CV fetch (never JSON-decoded). Offline
  /// reports [OfflineFailure]; empty payloads report [ServerFailure].
  Future<Either<Failure, CvFileDownloadEntity>> downloadCv({int? cvDocumentId});

  // Avatar Upload
  /// Uploads the candidate avatar image. Remote-only.
  ///
  /// TODO(avatar-backend): the endpoint, HTTP method, multipart field,
  /// and response schema are pending backend documentation. Nothing
  /// may call this until the contract lands.
  Future<Either<Failure, Unit>> uploadAvatar(AvatarUploadInput input);

  // Career Preferences
  Future<Either<Failure, CareerPreferenceEntity?>> getCareerPreferences();

  Future<Either<Failure, CareerPreferenceEntity>> saveCareerPreferences(
    SaveCareerPreferencesParams params,
  );

  // Candidate Profile Update
  Future<Either<Failure, CandidateProfileEntity>> updateCandidateProfile(
    UpdateCandidateProfileParams params,
  );
}
