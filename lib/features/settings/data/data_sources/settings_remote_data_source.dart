abstract class SettingsRemoteDataSource {
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });

  /// Invalidates the server-side session. Failures are tolerated by the
  /// repository so local sign-out still completes offline.
  Future<void> logout();
}
