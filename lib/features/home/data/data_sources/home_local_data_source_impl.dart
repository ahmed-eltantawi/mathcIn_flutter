import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/features/home/data/data_sources/home_local_data_source.dart';
import 'package:MatchIn/features/home/domain/entities/home_dashboard_entity.dart';

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  const HomeLocalDataSourceImpl({
    required this.sharedPreferencesHelper,
  });

  final SharedPreferencesHelper sharedPreferencesHelper;

  static const String _matchesCountKey = 'home_matches_count';
  static const String _userNameKey = 'home_user_name';

  @override
  Future<String?> getCachedUserName() async =>
      sharedPreferencesHelper.getString(key: _userNameKey);

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
      key: _userNameKey,
      value: dashboard.userName,
    );
    await sharedPreferencesHelper.saveData(
      key: _matchesCountKey,
      value: dashboard.matchesCount,
    );
  }

  @override
  Future<void> clearCachedHomeDashboard() async {
    await sharedPreferencesHelper.deleteData(key: _matchesCountKey);
    await sharedPreferencesHelper.deleteData(key: _userNameKey);
  }
}
