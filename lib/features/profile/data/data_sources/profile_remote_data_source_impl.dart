import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:MatchIn/features/profile/data/models/user_profile_model.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<UserProfileModel> getUserProfile() async {
    final response = await _apiConsumer.get(EndPoint.currentUser);
    return UserProfileModel.fromJson(response as Map<String, dynamic>);
  }
}
