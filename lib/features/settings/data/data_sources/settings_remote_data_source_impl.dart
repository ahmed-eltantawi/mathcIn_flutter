import 'package:MatchIn/core/errors/error_model.dart';
import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/features/settings/data/data_sources/settings_remote_data_source.dart';

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  const SettingsRemoteDataSourceImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // Note: The backend API currently does not provide an authenticated
    // change-password endpoint (EndPoint only provides forgot-password/reset-password).
    // In accordance with project instructions, we do not invent endpoints.
    throw ServerException(
      errorModel: ErrorModel(
        statusCode: 501,
        errorMessage: 'Change password endpoint is not provided by the backend.',
      ),
    );
  }
}
