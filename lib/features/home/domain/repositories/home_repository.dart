import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/home/domain/entities/home_dashboard_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, HomeDashboardEntity>>
  getHomeDashboard();
}
