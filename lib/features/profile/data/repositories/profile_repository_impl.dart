import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_remote_data_source.dart';
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
        return Left(ServerFailure(message: e.errorModel.errorMessage));
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
