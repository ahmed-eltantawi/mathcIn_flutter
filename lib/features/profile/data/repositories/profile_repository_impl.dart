import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:MatchIn/features/profile/domain/entities/add_candidate_skill_params.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_profile_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_skill_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/career_preference_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/save_career_preferences_params.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:MatchIn/features/profile/domain/entities/skill_search_result_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_project_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/add_candidate_project_params.dart';
import 'package:MatchIn/features/profile/domain/entities/update_candidate_project_params.dart';

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

        return Right(profile);
      } on ServerException catch (e) {
        final cached = await localDataSource.getCachedCandidateProfile();

        if (cached != null) {
          return Right(cached);
        }

        return Left(ServerFailure(message: e.errorModel.errorMessage));
      } catch (e) {
        final cached = await localDataSource.getCachedCandidateProfile();

        if (cached != null) {
          return Right(cached);
        }

        return Left(ServerFailure(message: e.toString()));
      }
    }

    final cached = await localDataSource.getCachedCandidateProfile();

    if (cached != null) {
      return Right(cached);
    }

    return const Left(OfflineFailure());
  }

  @override
  Future<Either<Failure, CandidateProfileEntity?>>
  getCachedCandidateProfile() async {
    try {
      final cached = await localDataSource.getCachedCandidateProfile();

      return Right(cached);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
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
      return Left(ServerFailure(message: e.errorModel.errorMessage));
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
      return Left(ServerFailure(message: e.errorModel.errorMessage));
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
      return Left(ServerFailure(message: e.errorModel.errorMessage));
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
      return Left(ServerFailure(message: e.errorModel.errorMessage));
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
      return Left(ServerFailure(message: e.errorModel.errorMessage));
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
      return Left(ServerFailure(message: e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CandidateProjectEntity>> addCandidateProject(
    AddCandidateProjectParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      final project = await remoteDataSource.addCandidateProject(params);

      return Right(project);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CandidateProjectEntity>> updateCandidateProject(
    UpdateCandidateProjectParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      final project = await remoteDataSource.updateCandidateProject(params);

      return Right(project);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.errorModel.errorMessage));
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
      return Left(ServerFailure(message: e.errorModel.errorMessage));
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
      return Left(ServerFailure(message: e.errorModel.errorMessage));
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
      return Left(ServerFailure(message: e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
