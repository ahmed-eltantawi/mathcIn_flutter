import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:MatchIn/features/home/domain/repositories/home_repository.dart';

class GetHomeDashboardUseCase {
  const GetHomeDashboardUseCase({required this.repository});

  final HomeRepository repository;

  Future<Either<Failure, HomeDashboardEntity>> call() {
    return repository.getHomeDashboard();
  }
}
