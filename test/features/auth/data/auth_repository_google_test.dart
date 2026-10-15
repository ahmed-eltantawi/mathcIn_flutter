import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/features/auth/data/data_sources/auth_mock_remote_data_source_impl.dart';
import 'package:MatchIn/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:MatchIn/features/auth/domain/use_cases/login_with_google_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}

void main() {
  group('loginWithGoogle backend contract', () {
    test('returns Left(ServerFailure) with 501 backend-missing message',
        () async {
      final repository = AuthRepositoryImpl(
        remoteDataSource: AuthMockRemoteDataSourceImpl(),
        networkInfo: FakeNetworkInfo(),
      );
      final useCase = LoginWithGoogleUseCase(repository: repository);

      final result = await useCase(idToken: 'google-id-token');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Google sign-in'));
        },
        (_) => fail('Expected Left, got Right'),
      );
    });
  });
}
