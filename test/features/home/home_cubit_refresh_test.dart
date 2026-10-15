import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:MatchIn/features/home/domain/repositories/home_repository.dart';
import 'package:MatchIn/features/home/domain/use_cases/get_cached_home_dashboard_use_case.dart';
import 'package:MatchIn/features/home/domain/use_cases/get_home_dashboard_use_case.dart';
import 'package:MatchIn/features/home/presentation/cubit/home_cubit.dart';
import 'package:MatchIn/features/home/presentation/cubit/home_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeHomeRepository implements HomeRepository {
  int remoteCalls = 0;

  @override
  Future<Either<Failure, HomeDashboardEntity?>> getCachedHomeDashboard() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, HomeDashboardEntity>> getHomeDashboard() async {
    remoteCalls++;
    await Future.delayed(const Duration(milliseconds: 50));
    return const Right(
      HomeDashboardEntity(userName: 'User', matchesCount: 3),
    );
  }
}

void main() {
  group('HomeCubit refresh guard', () {
    test('overlapping getHomeDashboard calls share a single fetch', () async {
      final repository = FakeHomeRepository();
      final cubit = HomeCubit(
        getHomeDashboardUseCase: GetHomeDashboardUseCase(
          repository: repository,
        ),
        getCachedHomeDashboardUseCase: GetCachedHomeDashboardUseCase(
          repository: repository,
        ),
      );

      await Future.wait([cubit.getHomeDashboard(), cubit.getHomeDashboard()]);

      expect(repository.remoteCalls, 1);
      expect(cubit.state, isA<HomeLoaded>());
      await cubit.close();
    });
  });
}
