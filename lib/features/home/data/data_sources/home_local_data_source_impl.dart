import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/features/home/data/data_sources/home_local_data_source.dart';
import 'package:MatchIn/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source.dart';

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  const HomeLocalDataSourceImpl({
    required this.profileLocalDataSource,
    required this.sharedPreferencesHelper,
  });

  final ProfileLocalDataSource profileLocalDataSource;
  final SharedPreferencesHelper sharedPreferencesHelper;

  static const String _matchesCountKey = 'home_matches_count';

  @override
  Future<String?> getCachedUserName() async {
    return profileLocalDataSource.getCachedUserName();
  }

  @override
  Future<HomeDashboardEntity?> getCachedHomeDashboard() async {
    final userName = await getCachedUserName();
    if (userName == null || userName.isEmpty) {
      return null;
    }

    final matchesCount = sharedPreferencesHelper.getInt(key: _matchesCountKey) ?? 0;

    return HomeDashboardEntity(
      userName: userName,
      matchesCount: matchesCount,
    );
  }

  @override
  Future<void> cacheHomeDashboard(HomeDashboardEntity dashboard) async {
    await sharedPreferencesHelper.saveData(
      key: _matchesCountKey,
      value: dashboard.matchesCount,
    );
  }

  @override
  Future<void> clearCachedHomeDashboard() async {
    await sharedPreferencesHelper.deleteData(key: _matchesCountKey);
  }
}
