import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/home/data/data_sources/home_local_data_source.dart';
import 'package:MatchIn/features/home/data/data_sources/home_remote_data_source.dart';
import 'package:MatchIn/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:MatchIn/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;

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
      if (effectiveUserName.isEmpty) {
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
