import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/features/home/data/data_sources/home_remote_data_source.dart';
import 'package:MatchIn/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:MatchIn/features/profile/data/models/user_profile_model.dart';

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  const HomeRemoteDataSourceImpl({
    required this.apiConsumer,
  });

  final ApiConsumer apiConsumer;

  @override
  Future<HomeDashboardEntity> getHomeDashboard() async {
    String userName = '';
    try {
      final userResponse = await apiConsumer.get(EndPoint.currentUser);
      if (userResponse is Map<String, dynamic>) {
        final userProfile = UserProfileModel.fromJson(userResponse);
        userName = userProfile.name;
      }
    } catch (_) {
      userName = '';
    }

    int matchesCount = 0;
    try {
      final jobsResponse = await apiConsumer.get(EndPoint.jobs);
      if (jobsResponse is Map<String, dynamic>) {
        final meta = jobsResponse[ApiKey.meta] as Map<String, dynamic>?;
        if (meta != null && meta.containsKey('total')) {
          matchesCount = (meta['total'] as num).toInt();
        } else if (jobsResponse[ApiKey.data] is List) {
          matchesCount = (jobsResponse[ApiKey.data] as List).length;
        }
      }
    } catch (_) {
      matchesCount = 0;
    }

    return HomeDashboardEntity(
      userName: userName,
      matchesCount: matchesCount,
    );
  }
}
