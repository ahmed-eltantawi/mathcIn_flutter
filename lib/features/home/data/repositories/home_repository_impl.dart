import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/home/data/data_sources/home_remote_data_source.dart';
import 'package:MatchIn/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:MatchIn/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({
    required this.remoteDataSource,
  });

  final HomeRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, HomeDashboardEntity>>
  getHomeDashboard() async {
    try {
      final dashboard = await remoteDataSource
          .getHomeDashboard();
      return Right(dashboard);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
