import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/applications_local_data_source.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/applications_remote_data_source.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/application_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/paginated_applications_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/repositories/applications_repository.dart';
import 'package:dartz/dartz.dart';

class ApplicationsRepositoryImpl implements ApplicationsRepository {
  const ApplicationsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  final ApplicationsRemoteDataSource remoteDataSource;
  final ApplicationsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  String _buildCacheKey(String? status, String? search, int page) {
    return 'status_${status ?? "all"}_search_${search ?? "none"}_page_$page';
  }

  @override
  Future<Either<Failure, PaginatedApplicationsEntity>> getApplications({
    String? status,
    String? search,
    int page = 1,
  }) async {
    final cacheKey = _buildCacheKey(status, search, page);

    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getApplications(
          status: status,
          search: search,
          page: page,
        );
        await localDataSource.cacheApplications(cacheKey, result);
        return Right(result.toEntity());
      } on ServerException catch (e) {
        final cached = await localDataSource.getCachedApplications(cacheKey);
        if (cached != null && cached.applications.isNotEmpty) {
          return Right(cached.toEntity());
        }
        return Left(ServerFailure(message: e.errorModel.errorMessage));
      } catch (e) {
        final cached = await localDataSource.getCachedApplications(cacheKey);
        if (cached != null && cached.applications.isNotEmpty) {
          return Right(cached.toEntity());
        }
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      final cached = await localDataSource.getCachedApplications(cacheKey);
      if (cached != null) {
        return Right(cached.toEntity());
      }
      return const Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, PaginatedApplicationsEntity?>> getCachedApplications({
    String? status,
    String? search,
  }) async {
    try {
      final cacheKey = _buildCacheKey(status, search, 1);
      final cached = await localDataSource.getCachedApplications(cacheKey);
      if (cached != null) {
        return Right(cached.toEntity());
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ApplicationEntity>> getApplicationDetails(
    String applicationId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getApplicationDetails(
          applicationId,
        );
        await localDataSource.cacheApplicationDetails(applicationId, result);
        return Right(result.toEntity());
      } on ServerException catch (e) {
        final cached = await localDataSource.getCachedApplicationDetails(
          applicationId,
        );
        if (cached != null) {
          return Right(cached.toEntity());
        }
        return Left(ServerFailure(message: e.errorModel.errorMessage));
      } catch (e) {
        final cached = await localDataSource.getCachedApplicationDetails(
          applicationId,
        );
        if (cached != null) {
          return Right(cached.toEntity());
        }
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      final cached = await localDataSource.getCachedApplicationDetails(
        applicationId,
      );
      if (cached != null) {
        return Right(cached.toEntity());
      }
      return const Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, ApplicationEntity>> applyToJob({
    required int jobId,
    String? coverLetter,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.applyToJob(
          jobId: jobId,
          coverLetter: coverLetter,
        );
        await localDataSource.cacheApplicationDetails(result.id, result);
        return Right(result.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.errorModel.errorMessage));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, ApplicationEntity>> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? notes,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.updateApplicationStatus(
          applicationId: applicationId,
          status: status,
          notes: notes,
        );
        await localDataSource.cacheApplicationDetails(applicationId, result);
        return Right(result.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.errorModel.errorMessage));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, ApplicationEntity>> withdrawApplication(
    String applicationId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.withdrawApplication(
          applicationId,
        );
        await localDataSource.cacheApplicationDetails(applicationId, result);
        return Right(result.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.errorModel.errorMessage));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(OfflineFailure());
    }
  }
}
