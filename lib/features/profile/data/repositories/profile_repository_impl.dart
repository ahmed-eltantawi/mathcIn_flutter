import 'dart:typed_data';

import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:MatchIn/features/profile/data/models/candidate_profile_model.dart';
import 'package:MatchIn/features/profile/data/models/candidate_skill_model.dart';
import 'package:MatchIn/features/profile/data/models/candidate_profile_details_model.dart';
import 'package:MatchIn/features/profile/data/models/profile_user_model.dart';
import 'package:MatchIn/features/profile/data/models/career_preference_model.dart';
import 'package:MatchIn/features/profile/data/models/cv_document_model.dart';
import 'package:MatchIn/features/profile/data/models/candidate_project_model.dart';
import 'package:MatchIn/features/profile/data/models/education_model.dart';
import 'package:MatchIn/features/profile/data/models/experience_model.dart';
import 'package:MatchIn/features/profile/data/models/cv_local_file_model.dart';
import 'package:MatchIn/features/profile/data/models/cv_pending_upload_model.dart';
import 'package:MatchIn/features/profile/data/models/cv_upload_marker_model.dart';
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
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, CandidateProfileEntity>> getCandidateProfile() async {
    if (await networkInfo.isConnected) {
      try {
        final profile = await _loadCompleteCandidateProfile();

        await localDataSource.cacheCandidateProfile(profile);

        final reconciled = await _applyLocalCvOverrides(profile);
        await _cacheReconciledCv(reconciled, profile);

        return Right(reconciled);
      } on ServerException catch (e) {
        final cached = await localDataSource.getCachedCandidateProfile();

        if (cached != null) {
          return Right(await _applyLocalCvOverrides(cached));
        }

        return Left(
          ServerFailure(
            message: e.errorModel.errorMessage,
            fieldErrors: e.errorModel.fieldErrors,
          ),
        );
      } catch (e) {
        final cached = await localDataSource.getCachedCandidateProfile();

        if (cached != null) {
          return Right(await _applyLocalCvOverrides(cached));
        }

        return Left(ServerFailure(message: e.toString()));
      }
    }

    final cached = await localDataSource.getCachedCandidateProfile();

    if (cached != null) {
      return Right(await _applyLocalCvOverrides(cached));
    }

    return const Left(OfflineFailure());
  }

  /// The published GET /candidate/profile contract only includes the base
  /// profile fields. The six profile cards are backed by separate resources,
  /// so load those resources together and compose one complete profile model
  /// before caching or emitting it to the UI.
  Future<CandidateProfileModel> _loadCompleteCandidateProfile() async {
    final base = await remoteDataSource.getCandidateProfile();
    if (!base.profileExists) return base;

    final skillsFallback = base.skills
        .whereType<CandidateSkillModel>()
        .toList();
    final projectsFallback = base.projects
        .whereType<CandidateProjectModel>()
        .toList();
    final educationFallback = base.education
        .whereType<EducationModel>()
        .toList();
    final experienceFallback = base.experience
        .whereType<ExperienceModel>()
        .toList();
    final preferencesFallback = base.careerPreferences is CareerPreferenceModel
        ? base.careerPreferences as CareerPreferenceModel
        : null;
    final cvFallback = base.cvDocument is CvDocumentModel
        ? <CvDocumentModel>[base.cvDocument as CvDocumentModel]
        : <CvDocumentModel>[];

    final sections = await Future.wait<Object?>([
      _loadSection(remoteDataSource.getCandidateSkills, skillsFallback),
      _loadSection(remoteDataSource.getProjects, projectsFallback),
      _loadSection(remoteDataSource.getEducations, educationFallback),
      _loadSection(remoteDataSource.getExperiences, experienceFallback),
      _loadSection(remoteDataSource.getCareerPreferences, preferencesFallback),
      _loadSection(remoteDataSource.getCvHistory, cvFallback),
    ]);

    final cvDocuments = sections[5] as List<CvDocumentModel>;
    CvDocumentModel? currentCv;
    for (final document in cvDocuments) {
      if (document.isCurrent == true) {
        currentCv = document;
        break;
      }
    }
    currentCv ??= cvDocuments.isNotEmpty ? cvDocuments.first : null;

    return CandidateProfileModel(
      profileExists: base.profileExists,
      user: base.user as ProfileUserModel,
      profile: base.profile as CandidateProfileDetailsModel?,
      skills: sections[0] as List<CandidateSkillModel>,
      projects: sections[1] as List<CandidateProjectModel>,
      education: sections[2] as List<EducationModel>,
      experience: sections[3] as List<ExperienceModel>,
      careerPreferences: sections[4] as CareerPreferenceModel?,
      cvDocument: currentCv,
    );
  }

  Future<T> _loadSection<T>(Future<T> Function() load, T fallback) async {
    try {
      return await load();
    } catch (_) {
      // One unavailable section must not hide the other profile data.
      return fallback;
    }
  }

  /// Refreshes one independently stored profile section into the durable
  /// aggregate cache after a successful child-resource mutation. This lets
  /// the app-scoped ProfileCubit render fresh cached data as soon as the user
  /// returns to the profile, while its normal background fetch reconciles it.
  Future<void> _refreshCachedSection<T>(
    Future<T> Function() load,
    CandidateProfileModel Function(CandidateProfileModel, T) update,
  ) async {
    try {
      final cached = await localDataSource.getCachedCandidateProfile();
      if (cached == null) return;
      final section = await load();
      await localDataSource.cacheCandidateProfile(update(cached, section));
    } catch (_) {
      // The server mutation already succeeded. A cache refresh failure must
      // not turn that successful write into a reported failure.
    }
  }

  CandidateProfileModel _copyProfileWithSections(
    CandidateProfileModel base, {
    List<CandidateSkillModel>? skills,
    List<CandidateProjectModel>? projects,
    List<EducationModel>? education,
    List<ExperienceModel>? experience,
    CareerPreferenceModel? careerPreferences,
    bool replaceCareerPreferences = false,
  }) {
    return CandidateProfileModel(
      profileExists: base.profileExists,
      user: base.user as ProfileUserModel,
      profile: base.profile as CandidateProfileDetailsModel?,
      skills: skills ?? base.skills,
      projects: projects ?? base.projects,
      education: education ?? base.education,
      experience: experience ?? base.experience,
      careerPreferences: replaceCareerPreferences
          ? careerPreferences
          : base.careerPreferences as CareerPreferenceModel?,
      cvDocument: base.cvDocument as CvDocumentModel?,
    );
  }

  @override
  Future<Either<Failure, CandidateProfileEntity?>>
  getCachedCandidateProfile() async {
    try {
      final cached = await localDataSource.getCachedCandidateProfile();
      if (cached == null) return const Right(null);

      return Right(await _applyLocalCvOverrides(cached));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CandidateProfileEntity>> updateCandidateProfile(
    UpdateCandidateProfileParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      // The PATCH response may be valid but incomplete (some deployments
      // return only changed/root fields). Never replace the complete cached
      // profile with that partial representation. Read the canonical GET
      // response after the write, then cache and publish that snapshot.
      final patchedProfile = await remoteDataSource.updateCandidateProfile(
        params,
      );

      try {
        final refreshedProfile = await _loadCompleteCandidateProfile();
        await localDataSource.cacheCandidateProfile(refreshedProfile);
        final reconciled = await _applyLocalCvOverrides(refreshedProfile);
        await _cacheReconciledCv(reconciled, refreshedProfile);
        return Right(reconciled);
      } catch (_) {
        // PATCH already succeeded. Merge its supported fields into the
        // complete cached snapshot so an offline reload cannot resurrect
        // values from before the save. Never cache a partial response alone.
        final cached = await localDataSource.getCachedCandidateProfile();
        if (cached != null) {
          final merged = _mergePatchedProfile(cached, patchedProfile, params);
          await localDataSource.cacheCandidateProfile(merged);
          return Right(await _applyLocalCvOverrides(merged));
        }
        return Right(patchedProfile);
      }
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  CandidateProfileModel _mergePatchedProfile(
    CandidateProfileModel cached,
    CandidateProfileModel patchResponse,
    UpdateCandidateProfileParams params,
  ) {
    String? patchOrCurrent(String? current, Object? patchValue) =>
        UpdateCandidateProfileParams.isSet(patchValue)
        ? patchValue as String?
        : current;

    final cachedUser = cached.user as ProfileUserModel;
    final oldDetails =
        (cached.profile ?? patchResponse.profile)
            as CandidateProfileDetailsModel?;
    final updatedUser = ProfileUserModel(
      id: cachedUser.id,
      name: UpdateCandidateProfileParams.isSet(params.fullName)
          ? (params.fullName as String? ?? '')
          : patchResponse.user.name.isNotEmpty
          ? patchResponse.user.name
          : cachedUser.name,
      email: patchResponse.user.email.isNotEmpty
          ? patchResponse.user.email
          : cachedUser.email,
      role: cachedUser.role,
      isActive: cachedUser.isActive,
      phone: patchOrCurrent(cachedUser.phone, params.phone),
      avatar: patchResponse.user.avatar ?? cachedUser.avatar,
    );
    final hasDetailsPatch =
        UpdateCandidateProfileParams.isSet(params.jobTitle) ||
        UpdateCandidateProfileParams.isSet(params.location) ||
        UpdateCandidateProfileParams.isSet(params.githubUrl) ||
        UpdateCandidateProfileParams.isSet(params.linkedinUrl) ||
        UpdateCandidateProfileParams.isSet(params.professionalSummary);
    final updatedDetails = oldDetails == null && !hasDetailsPatch
        ? null
        : CandidateProfileDetailsModel(
            id: oldDetails?.id ?? patchResponse.profile?.id ?? cachedUser.id,
            dateOfBirth: oldDetails?.dateOfBirth,
            gender: oldDetails?.gender,
            jobTitle: patchOrCurrent(oldDetails?.jobTitle, params.jobTitle),
            location: patchOrCurrent(oldDetails?.location, params.location),
            country: UpdateCandidateProfileParams.isSet(params.location)
                ? null
                : oldDetails?.country,
            state: UpdateCandidateProfileParams.isSet(params.location)
                ? null
                : oldDetails?.state,
            city: UpdateCandidateProfileParams.isSet(params.location)
                ? null
                : oldDetails?.city,
            githubUrl: patchOrCurrent(oldDetails?.githubUrl, params.githubUrl),
            linkedinUrl: patchOrCurrent(
              oldDetails?.linkedinUrl,
              params.linkedinUrl,
            ),
            militaryStatus: oldDetails?.militaryStatus,
            professionalSummary: patchOrCurrent(
              oldDetails?.professionalSummary,
              params.professionalSummary,
            ),
          );

    return CandidateProfileModel(
      profileExists: cached.profileExists || patchResponse.profileExists,
      user: updatedUser,
      profile: updatedDetails,
      skills: cached.skills,
      projects: cached.projects,
      careerPreferences:
          (cached.careerPreferences ?? patchResponse.careerPreferences)
              as CareerPreferenceModel?,
      education: cached.education,
      experience: cached.experience,
      cvDocument: cached.cvDocument == null
          ? null
          : CvDocumentModel(
              id: cached.cvDocument!.id,
              fileName: cached.cvDocument!.fileName,
              originalFilename: cached.cvDocument!.originalFilename,
              fileUrl: cached.cvDocument!.fileUrl,
              status: cached.cvDocument!.status,
              version: cached.cvDocument!.version,
              isCurrent: cached.cvDocument!.isCurrent,
              processedAt: cached.cvDocument!.processedAt,
              updatedAt: cached.cvDocument!.updatedAt,
              failureReason: cached.cvDocument!.failureReason,
            ),
    );
  }

  @override
  Future<Either<Failure, CandidateProfileEntity>>
  getCandidateProfileForEdit() async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      final profile = await remoteDataSource.getCandidateProfile();

      return Right(profile);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // Candidate Skills
  @override
  Future<Either<Failure, List<CandidateSkillEntity>>>
  getCandidateSkills() async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      final skills = await remoteDataSource.getCandidateSkills();

      return Right(skills);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CandidateSkillEntity>> addCandidateSkill(
    AddCandidateSkillParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      final skill = await remoteDataSource.addCandidateSkill(params);
      await _refreshCachedSection(
        remoteDataSource.getCandidateSkills,
        (cached, skills) => _copyProfileWithSections(cached, skills: skills),
      );

      return Right(skill);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeCandidateSkill(
    int candidateSkillId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      await remoteDataSource.removeCandidateSkill(candidateSkillId);
      await _refreshCachedSection(
        remoteDataSource.getCandidateSkills,
        (cached, skills) => _copyProfileWithSections(cached, skills: skills),
      );

      return const Right(unit);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SkillSearchResultEntity>>> searchSkills(
    String query,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      final skills = await remoteDataSource.searchSkills(query);

      return Right(skills);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // Candidate Projects
  @override
  Future<Either<Failure, List<CandidateProjectEntity>>> getProjects() async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      final projects = await remoteDataSource.getProjects();

      return Right(projects);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CandidateProjectEntity>> getProject(
    int projectId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      final project = await remoteDataSource.getProject(projectId);

      return Right(project);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CandidateProjectEntity?>> addCandidateProject(
    AddCandidateProjectParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      final project = await remoteDataSource.addCandidateProject(params);
      await _refreshCachedSection(
        remoteDataSource.getProjects,
        (cached, projects) =>
            _copyProfileWithSections(cached, projects: projects),
      );

      return Right(project);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CandidateProjectEntity?>> updateCandidateProject(
    UpdateCandidateProjectParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      final project = await remoteDataSource.updateCandidateProject(params);
      await _refreshCachedSection(
        remoteDataSource.getProjects,
        (cached, projects) =>
            _copyProfileWithSections(cached, projects: projects),
      );

      return Right(project);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCandidateProject(int projectId) async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      await remoteDataSource.deleteCandidateProject(projectId);
      await _refreshCachedSection(
        remoteDataSource.getProjects,
        (cached, projects) =>
            _copyProfileWithSections(cached, projects: projects),
      );

      return const Right(unit);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // career preferences
  @override
  Future<Either<Failure, List<EducationEntity>>> getEducations() async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      final educations = await remoteDataSource.getEducations();

      return Right(educations);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EducationEntity?>> addEducation(
    AddEducationParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      final education = await remoteDataSource.addEducation(params);
      await _refreshCachedSection(
        remoteDataSource.getEducations,
        (cached, items) => _copyProfileWithSections(cached, education: items),
      );

      return Right(education);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EducationEntity?>> updateEducation(
    UpdateEducationParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      final education = await remoteDataSource.updateEducation(params);
      await _refreshCachedSection(
        remoteDataSource.getEducations,
        (cached, items) => _copyProfileWithSections(cached, education: items),
      );

      return Right(education);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteEducation(int educationId) async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      await remoteDataSource.deleteEducation(educationId);
      await _refreshCachedSection(
        remoteDataSource.getEducations,
        (cached, items) => _copyProfileWithSections(cached, education: items),
      );

      return const Right(unit);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // Candidate Experiences
  @override
  Future<Either<Failure, List<ExperienceEntity>>> getExperiences() async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      final experiences = await remoteDataSource.getExperiences();

      return Right(experiences);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExperienceEntity?>> addExperience(
    AddExperienceParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      final experience = await remoteDataSource.addExperience(params);
      await _refreshCachedSection(
        remoteDataSource.getExperiences,
        (cached, items) => _copyProfileWithSections(cached, experience: items),
      );

      return Right(experience);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExperienceEntity?>> updateExperience(
    UpdateExperienceParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      final experience = await remoteDataSource.updateExperience(params);
      await _refreshCachedSection(
        remoteDataSource.getExperiences,
        (cached, items) => _copyProfileWithSections(cached, experience: items),
      );

      return Right(experience);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteExperience(int experienceId) async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      await remoteDataSource.deleteExperience(experienceId);
      await _refreshCachedSection(
        remoteDataSource.getExperiences,
        (cached, items) => _copyProfileWithSections(cached, experience: items),
      );

      return const Right(unit);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // CV Upload
  @override
  Future<Either<Failure, CvUploadReceipt?>> uploadCv(
    CvUploadInput input, {
    void Function(int sentBytes, int totalBytes)? onSendProgress,
  }) async {
    final userId = localDataSource.currentUserScopeId();
    final now = DateTime.now().millisecondsSinceEpoch;

    if (!await networkInfo.isConnected) {
      // --- Offline: preserve the file locally for later retry and
      // --- report offline. The cubit surfaces the pending state. ---
      await _savePendingCv(input, userId: userId, at: now);
      await _saveCachedCvFile(
        input.fileName,
        input.bytes,
        userId: userId,
        at: now,
      );
      return const Left(OfflineFailure());
    }

    try {
      final receipt = await remoteDataSource.uploadCv(
        input,
        onSendProgress: onSendProgress,
      );

      await _saveCachedCvFile(
        input.fileName,
        input.bytes,
        userId: userId,
        at: now,
      );
      // --- The upload response carries no filename, so the marker
      // --- keeps it next to the receipt until the profile read
      // --- catches up with the new document. ---
      await localDataSource.saveUploadedCvMarker(
        CvUploadMarkerModel(
          id: receipt?.id,
          fileName: input.fileName,
          version: receipt?.version,
          status: receipt?.status,
          uploadedAt: now,
          userId: userId,
        ),
      );
      await localDataSource.clearPendingCvUpload();

      return Right(receipt);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CvPendingUpload?>> getPendingCvUpload() async {
    try {
      return Right(await localDataSource.getPendingCvUpload());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CvUploadReceipt?>> retryPendingCvUpload() async {
    final CvPendingUploadModel? pending;
    try {
      pending = await localDataSource.getPendingCvUpload();
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
    if (pending == null || pending.bytes.isEmpty) {
      return const Left(CacheFailure(message: 'No pending CV upload'));
    }
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      final receipt = await remoteDataSource.uploadCv(
        CvUploadInput(
          fileName: pending.fileName,
          extension: pending.extension,
          sizeBytes: pending.sizeBytes,
          bytes: pending.bytes,
        ),
      );

      final now = DateTime.now().millisecondsSinceEpoch;
      await _saveCachedCvFile(
        pending.fileName,
        pending.bytes,
        userId: pending.userId,
        at: now,
      );
      await localDataSource.saveUploadedCvMarker(
        CvUploadMarkerModel(
          id: receipt?.id,
          fileName: pending.fileName,
          version: receipt?.version,
          status: receipt?.status,
          uploadedAt: now,
          userId: pending.userId,
        ),
      );
      await localDataSource.clearPendingCvUpload();

      return Right(receipt);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CvLocalFile?>> getLocalCvFile() async {
    try {
      // --- The pending file is the newest local intent. ---
      final pending = await localDataSource.getPendingCvUpload();
      if (pending != null && pending.bytes.isNotEmpty) {
        return Right(
          CvLocalFile(
            fileName: pending.fileName,
            bytes: pending.bytes,
            userId: pending.userId,
            savedAt: pending.savedAt,
          ),
        );
      }
      final cached = await localDataSource.getCachedCvFile();
      if (cached != null && cached.bytes.isNotEmpty) {
        return Right(
          CvLocalFile(
            fileName: cached.fileName,
            bytes: cached.bytes,
            userId: cached.userId,
            savedAt: cached.savedAt,
          ),
        );
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CvExtractionStatusEntity>> getCvStatus(
    int cvDocumentId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }
    try {
      final status = await remoteDataSource.getCvStatus(cvDocumentId);
      return Right(status);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CvDocumentEntity>>> getCvHistory() async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }
    try {
      final documents = await remoteDataSource.getCvHistory();
      return Right(documents);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CvExtractionStatusEntity>> retryCvExtraction(
    int cvDocumentId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }
    try {
      final status = await remoteDataSource.retryCvExtraction(cvDocumentId);
      return Right(status);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> verifyExtraction(CvVerifyParams params) async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }
    try {
      await remoteDataSource.verifyExtraction(params);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CvFileDownloadEntity>> downloadCv({
    int? cvDocumentId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }
    try {
      final file = await remoteDataSource.downloadCv(
        cvDocumentId: cvDocumentId,
      );
      if (file.bytes.isEmpty) {
        return const Left(ServerFailure(message: 'Empty CV file response'));
      }
      return Right(file);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  //! ===== CV reconciliation (offline-first) =====

  // --- Merges newer local CV knowledge over a profile read so a
  // --- lagging backend response never wipes a just-uploaded or
  // --- pending CV back to the empty state. Pure reads otherwise. ---
  Future<CandidateProfileEntity> _applyLocalCvOverrides(
    CandidateProfileEntity profile,
  ) async {
    final model = profile is CandidateProfileModel ? profile : null;
    if (model == null) return profile;

    // --- 1. A pending offline upload is the newest local intent. ---
    final CvPendingUploadModel? pending = await _safePendingCv();
    if (pending != null) {
      return model.copyWithCvDocument(_pendingDocument(pending));
    }

    // --- 2. A successful upload the backend read has not caught up with. ---
    final CvUploadMarkerModel? marker = await _safeUploadMarker();
    if (marker == null) return profile;

    final remoteDoc = model.cvDocument;
    if (remoteDoc != null) {
      if (marker.id != null && remoteDoc.id == marker.id) {
        // --- Backend caught up: the marker served its purpose. ---
        await _safeClearUploadMarker();
        return profile;
      }
      if (marker.id == null) {
        // --- Receipt-less upload: clear only when the served CV
        // --- already carries the uploaded filename; otherwise the
        // --- marker is a newer replacement the read has not caught
        // --- up with yet, so keep serving it. ---
        if (_sameFileName(remoteDoc.fileName, marker.fileName) ||
            _sameFileName(remoteDoc.originalFilename, marker.fileName)) {
          await _safeClearUploadMarker();
          return profile;
        }
        return model.copyWithCvDocument(_markerDocument(marker));
      }
      // --- Backend still serves the older document: keep serving
      // --- the marker-derived document and keep the marker. ---
      return model.copyWithCvDocument(_markerDocument(marker));
    }
    return model.copyWithCvDocument(_markerDocument(marker));
  }

  // --- Persists a reconciled profile only when its CV document can
  // --- survive a cache round-trip (identity-less documents are
  // --- skipped by the parser and live on through the marker). ---
  Future<void> _cacheReconciledCv(
    CandidateProfileEntity reconciled,
    CandidateProfileEntity original,
  ) async {
    if (identical(reconciled, original)) return;
    final model = reconciled is CandidateProfileModel ? reconciled : null;
    if (model == null) return;
    if (model.cvDocument?.id == null) return;
    try {
      await localDataSource.cacheCandidateProfile(model);
    } catch (_) {
      // --- Cache write failures must never fail the profile read. ---
    }
  }

  CvDocumentModel _pendingDocument(CvPendingUploadModel pending) {
    return CvDocumentModel.fromJson({
      'file_name': pending.fileName,
      'original_filename': pending.fileName,
      'is_current': true,
      'updated_at': DateTime.fromMillisecondsSinceEpoch(pending.savedAt)
          .toIso8601String(),
    });
  }

  bool _sameFileName(String? a, String b) {
    if (a == null) return false;
    if (b.trim().isEmpty) return false;
    return a.trim().toLowerCase() == b.trim().toLowerCase();
  }

  CvDocumentModel _markerDocument(CvUploadMarkerModel marker) {
    return CvDocumentModel.fromJson({
      'id': marker.id,
      'file_name': marker.fileName,
      'original_filename': marker.fileName,
      'status': marker.status,
      'version': marker.version,
      'is_current': true,
      'updated_at': DateTime.fromMillisecondsSinceEpoch(marker.uploadedAt)
          .toIso8601String(),
    });
  }

  Future<void> _savePendingCv(
    CvUploadInput input, {
    required String userId,
    required int at,
  }) async {
    try {
      await localDataSource.savePendingCvUpload(
        CvPendingUploadModel(
          fileName: input.fileName,
          extension: input.extension,
          sizeBytes: input.sizeBytes,
          bytes: input.bytes,
          userId: userId,
          savedAt: at,
        ),
      );
    } catch (_) {
      // --- Local persistence failures must not mask the network result. ---
    }
  }

  Future<void> _saveCachedCvFile(
    String fileName,
    Uint8List bytes, {
    required String userId,
    required int at,
  }) async {
    if (bytes.isEmpty) return;
    try {
      await localDataSource.saveCachedCvFile(
        CvLocalFileModel(
          fileName: fileName,
          bytes: bytes,
          userId: userId,
          savedAt: at,
        ),
      );
    } catch (_) {
      // --- Local persistence failures must not mask the network result. ---
    }
  }

  Future<CvPendingUploadModel?> _safePendingCv() async {
    try {
      return await localDataSource.getPendingCvUpload();
    } catch (_) {
      return null;
    }
  }

  Future<CvUploadMarkerModel?> _safeUploadMarker() async {
    try {
      return await localDataSource.getUploadedCvMarker();
    } catch (_) {
      return null;
    }
  }

  Future<void> _safeClearUploadMarker() async {
    try {
      await localDataSource.clearUploadedCvMarker();
    } catch (_) {
      // --- Best effort; the next reconciled read retries. ---
    }
  }

  // Avatar Upload
  @override
  Future<Either<Failure, Unit>> uploadAvatar(AvatarUploadInput input) async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      await remoteDataSource.uploadAvatar(input);

      return const Right(unit);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // career preferences
  @override
  Future<Either<Failure, CareerPreferenceEntity?>>
  getCareerPreferences() async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      final preferences = await remoteDataSource.getCareerPreferences();

      return Right(preferences);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CareerPreferenceEntity>> saveCareerPreferences(
    SaveCareerPreferencesParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      final preferences = await remoteDataSource.saveCareerPreferences(params);
      await _refreshCachedSection(
        remoteDataSource.getCareerPreferences,
        (cached, preferences) => _copyProfileWithSections(
          cached,
          careerPreferences: preferences,
          replaceCareerPreferences: true,
        ),
      );

      return Right(preferences);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> getUserProfile() async {
    final isConnected = await networkInfo.isConnected;
    if (isConnected) {
      try {
        final remoteProfile = await remoteDataSource.getUserProfile();
        await localDataSource.cacheUserProfile(remoteProfile);
        return Right(remoteProfile.toEntity());
      } on ServerException catch (e) {
        final cached = await localDataSource.getCachedUserProfile();
        if (cached != null) {
          return Right(cached.toEntity());
        }
        return Left(
          ServerFailure(
            message: e.errorModel.errorMessage,
            fieldErrors: e.errorModel.fieldErrors,
          ),
        );
      } catch (e) {
        final cached = await localDataSource.getCachedUserProfile();
        if (cached != null) {
          return Right(cached.toEntity());
        }
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      final cached = await localDataSource.getCachedUserProfile();
      if (cached != null) {
        return Right(cached.toEntity());
      }
      return const Left(OfflineFailure());
    }
  }
}
