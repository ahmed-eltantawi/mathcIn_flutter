import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:MatchIn/features/profile/domain/entities/add_candidate_skill_params.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_profile_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_skill_entity.dart';
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
  Future<Either<Failure, CandidateProfileEntity>>
  getCandidateProfile() async {
    if (await networkInfo.isConnected) {
      try {
        final profile = await remoteDataSource
            .getCandidateProfile();

        await localDataSource.cacheCandidateProfile(
          profile,
        );

        return Right(profile);
      } on ServerException catch (e) {
        final cached = await localDataSource
            .getCachedCandidateProfile();

        if (cached != null) {
          return Right(cached);
        }

        return Left(
          ServerFailure(message: e.errorModel.errorMessage),
        );
      } catch (e) {
        final cached = await localDataSource
            .getCachedCandidateProfile();

        if (cached != null) {
          return Right(cached);
        }

        return Left(ServerFailure(message: e.toString()));
      }
    }

    final cached = await localDataSource
        .getCachedCandidateProfile();

    if (cached != null) {
      return Right(cached);
    }

    return const Left(OfflineFailure());
  }

  @override
  Future<Either<Failure, CandidateProfileEntity?>>
  getCachedCandidateProfile() async {
    try {
      final cached = await localDataSource
          .getCachedCandidateProfile();

      return Right(cached);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CandidateSkillEntity>>>
  getCandidateSkills() async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      final skills = await remoteDataSource
          .getCandidateSkills();

      return Right(skills);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.errorModel.errorMessage),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CandidateSkillEntity>>
  addCandidateSkill(AddCandidateSkillParams params) async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      final skill = await remoteDataSource
          .addCandidateSkill(params);

      return Right(skill);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.errorModel.errorMessage),
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
      await remoteDataSource.removeCandidateSkill(
        candidateSkillId,
      );

      return const Right(unit);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.errorModel.errorMessage),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
