import 'package:MatchIn/features/home/domain/entities/home_dashboard_entity.dart';

abstract class HomeRemoteDataSource {
  Future<HomeDashboardEntity> getHomeDashboard();
}
