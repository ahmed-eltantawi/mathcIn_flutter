import 'package:MatchIn/features/profile/data/models/user_profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<void> cacheUserProfile(UserProfileModel profile);
  Future<UserProfileModel?> getCachedUserProfile();
}
