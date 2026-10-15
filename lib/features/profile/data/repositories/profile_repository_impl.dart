import 'dart:typed_data';

import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:MatchIn/features/profile/data/models/candidate_profile_model.dart';
import 'package:MatchIn/features/profile/data/models/cv_document_model.dart';
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
import 'package:MatchIn/features/profile/domain/entities/cv_local_file.dart';
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
        final profile = await remoteDataSource.getCandidateProfile();

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
      final profile = await remoteDataSource.updateCandidateProfile(params);

      await localDataSource.cacheCandidateProfile(profile);

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
    CvUploadInput input,
  ) async {
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
      final receipt = await remoteDataSource.uploadCv(input);

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
    } on UnimplementedError {
      // TODO(avatar-backend): remove this branch once the remote avatar
      // upload is implemented against the documented contract.
      return const Left(
        ServerFailure(message: 'Avatar upload is not available yet.'),
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
