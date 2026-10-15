import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/home/data/data_sources/home_local_data_source.dart';
import 'package:MatchIn/features/home/data/data_sources/home_remote_data_source.dart';
import 'package:MatchIn/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:MatchIn/features/home/domain/repositories/home_repository.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:MatchIn/features/profile/data/models/user_profile_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.profileLocalDataSource,
  });

  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;
  final ProfileLocalDataSource profileLocalDataSource;

  @override
  Future<Either<Failure, HomeDashboardEntity?>> getCachedHomeDashboard() async {
    try {
      final cached = await localDataSource.getCachedHomeDashboard();
      return Right(cached);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, HomeDashboardEntity>> getHomeDashboard() async {
    try {
      final remoteDashboard = await remoteDataSource.getHomeDashboard();

      String effectiveUserName = remoteDashboard.userName;
      if (effectiveUserName.isNotEmpty) {
        // Cache the newly fetched user name into profile cache if present
        final cachedUser = await profileLocalDataSource.getCachedUserProfile();
        await profileLocalDataSource.cacheUserProfile(
          UserProfileModel(
            id: cachedUser?.id ?? 0,
            name: effectiveUserName,
            email: cachedUser?.email ?? '',
            jobTitle: cachedUser?.jobTitle ?? '',
            location: cachedUser?.location ?? '',
          ),
        );
      } else {
        // Preserve locally cached user name if remote name was empty
        final cachedUserName = await localDataSource.getCachedUserName();
        if (cachedUserName != null && cachedUserName.isNotEmpty) {
          effectiveUserName = cachedUserName;
        } else {
          effectiveUserName = 'User';
        }
      }

      final finalDashboard = HomeDashboardEntity(
        userName: effectiveUserName,
        matchesCount: remoteDashboard.matchesCount,
      );

      await localDataSource.cacheHomeDashboard(finalDashboard);
      return Right(finalDashboard);
    } catch (e) {
      final cached = await localDataSource.getCachedHomeDashboard();
      if (cached != null) {
        return Right(cached);
      }
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
