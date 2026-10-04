import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:MatchIn/features/profile/data/models/candidate_profile_model.dart';

class ProfileCacheSeeder {
  const ProfileCacheSeeder({required this.localDataSource});

  final ProfileLocalDataSource localDataSource;

  Future<void> seed() async {
    final profile = CandidateProfileModel.fromJson(const {
      'profile_exists': true,
      'user': {
        'id': 1,
        'name': 'Ahmed Mohamed',
        'email': 'ahmed@example.com',
        'phone': '01012345678',
        'avatar': null,
        'role': 'candidate',
        'is_active': true,
      },
      'profile': {
        'id': 3,
        'date_of_birth': '2000-01-01',
        'gender': 'male',
        'job_title': 'Junior Flutter Developer',
        'country': 'Egypt',
        'state': 'Cairo',
        'city': 'Cairo',
        'github_url': 'https://github.com/ahmed',
        'linkedin_url': 'https://linkedin.com/in/ahmed',
        'military_status': 'exempted',
        'professional_summary':
            'Looking for Flutter and Mobile Development opportunities.',
      },
    });

    await localDataSource.cacheCandidateProfile(profile);
  }
}
