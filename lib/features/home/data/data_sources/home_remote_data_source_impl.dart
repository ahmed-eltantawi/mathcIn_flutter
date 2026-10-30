import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/features/home/data/data_sources/home_remote_data_source.dart';
import 'package:MatchIn/features/home/domain/entities/home_dashboard_entity.dart';

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  const HomeRemoteDataSourceImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  @override
  Future<HomeDashboardEntity> getHomeDashboard() async {
    // These requests are independent; run them together so the dashboard
    // latency is bounded by the slowest request rather than their sum.
    final results = await Future.wait<dynamic>([
      _getRemoteUserName(),
      _getMatchesCount(),
    ]);
    return HomeDashboardEntity(
      userName: results[0] as String,
      matchesCount: results[1] as int,
    );
  }

  Future<String> _getRemoteUserName() async {
    String userName = '';
    try {
      final userResponse = await apiConsumer.get(EndPoint.currentUser);
      if (userResponse is Map<String, dynamic>) {
        final user = _unwrapUser(userResponse);
        userName = (user['name'] ?? user['full_name'])?.toString().trim() ?? '';
      }
    } catch (_) {
      userName = '';
    }

    if (userName.isEmpty) {
      try {
        final candidateResponse = await apiConsumer.get(
          EndPoint.candidateProfile,
        );
        if (candidateResponse is Map<String, dynamic> &&
            candidateResponse[ApiKey.data] is Map<String, dynamic>) {
          final data = candidateResponse[ApiKey.data] as Map<String, dynamic>;
          final userJson = data['user'] as Map<String, dynamic>?;
          if (userJson != null &&
              userJson['name'] != null &&
              userJson['name'].toString().trim().isNotEmpty) {
            userName = userJson['name'].toString().trim();
          } else if (data['full_name'] != null &&
              data['full_name'].toString().trim().isNotEmpty) {
            userName = data['full_name'].toString().trim();
          }
        }
      } catch (_) {
        // Ignored
      }
    }

    return userName;
  }

  Map<String, dynamic> _unwrapUser(Map<String, dynamic> response) {
    final user = response['user'];
    if (user is Map<String, dynamic>) return user;

    final data = response[ApiKey.data];
    if (data is Map<String, dynamic>) {
      final nestedUser = data['user'];
      if (nestedUser is Map<String, dynamic>) return nestedUser;
      return data;
    }
    return response;
  }

  Future<int> _getMatchesCount() async {
    var matchesCount = 0;
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

    return matchesCount;
  }
}
