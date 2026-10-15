import 'package:MatchIn/features/home/domain/entities/home_dashboard_entity.dart';

abstract interface class HomeLocalDataSource {
  Future<HomeDashboardEntity?> getCachedHomeDashboard();

  Future<void> cacheHomeDashboard(HomeDashboardEntity dashboard);

  Future<String?> getCachedUserName();

  Future<void> clearCachedHomeDashboard();
}
