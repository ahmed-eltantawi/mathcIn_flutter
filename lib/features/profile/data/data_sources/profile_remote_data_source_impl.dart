import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:MatchIn/features/profile/data/models/candidate_profile_model.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  @override
  Future<CandidateProfileModel> getCandidateProfile() async {
    final response = await apiConsumer.get(EndPoint.candidateProfile);

    if (response is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid response format for candidate profile',
      );
    }

    final data = response['data'];

    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid candidate profile data format');
    }

    return CandidateProfileModel.fromJson(data);
  }
}
