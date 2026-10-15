import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/features/auth/data/data_sources/auth_mock_remote_data_source_impl.dart';
import 'package:MatchIn/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:MatchIn/features/auth/domain/use_cases/forgot_password_use_case.dart';
import 'package:MatchIn/features/auth/domain/use_cases/resend_otp_use_case.dart';
import 'package:MatchIn/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:MatchIn/features/auth/domain/use_cases/verify_otp_use_case.dart';
import 'package:MatchIn/features/auth/domain/use_cases/verify_password_reset_otp_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}

void main() {
  late AuthMockRemoteDataSourceImpl mockDataSource;
  late AuthRepositoryImpl repository;
  late VerifyOtpUseCase verifyOtpUseCase;
  late ResendOtpUseCase resendOtpUseCase;
  late ResetPasswordUseCase resetPasswordUseCase;
  late ForgotPasswordUseCase forgotPasswordUseCase;
  late VerifyPasswordResetOtpUseCase verifyPasswordResetOtpUseCase;

  setUp(() {
    mockDataSource = AuthMockRemoteDataSourceImpl();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockDataSource,
      networkInfo: FakeNetworkInfo(),
    );
    verifyOtpUseCase = VerifyOtpUseCase(repository: repository);
    resendOtpUseCase = ResendOtpUseCase(repository: repository);
    resetPasswordUseCase = ResetPasswordUseCase(repository: repository);
    forgotPasswordUseCase = ForgotPasswordUseCase(repository: repository);
    verifyPasswordResetOtpUseCase = VerifyPasswordResetOtpUseCase(
      repository: repository,
    );
  });

  group('Auth Unit Tests with Mock DataSource', () {
    test('verifyOtp returns Right(unit) on valid OTP', () async {
      final result = await verifyOtpUseCase(
        email: 'test@example.com',
        otp: '123456',
      );

      expect(result.isRight(), isTrue);
    });

    test('verifyOtp returns Left(ServerFailure) on 000000 OTP', () async {
      final result = await verifyOtpUseCase(
        email: 'test@example.com',
        otp: '000000',
      );

      expect(result.isLeft(), isTrue);
    });

    test('resendOtp returns Right(unit)', () async {
      final result = await resendOtpUseCase(email: 'test@example.com');

      expect(result.isRight(), isTrue);
    });

    test('resetPassword returns Right(unit) with valid password', () async {
      final result = await resetPasswordUseCase(
        email: 'test@example.com',
        newPassword: 'Password123!',
      );

      expect(result.isRight(), isTrue);
    });

    test(
      'resetPassword returns Left(ServerFailure) when password is short',
      () async {
        final result = await resetPasswordUseCase(
          email: 'test@example.com',
          newPassword: 'short',
        );

        expect(result.isLeft(), isTrue);
      },
    );

    test('forgotPassword returns Right(unit)', () async {
      final result = await forgotPasswordUseCase(email: 'test@example.com');

      expect(result.isRight(), isTrue);
    });

    test('verifyPasswordResetOtp returns Right(unit) on valid OTP', () async {
      final result = await verifyPasswordResetOtpUseCase(
        email: 'test@example.com',
        otp: '123456',
      );

      expect(result.isRight(), isTrue);
    });

    test(
      'verifyPasswordResetOtp returns Left(ServerFailure) on 000000 OTP',
      () async {
        final result = await verifyPasswordResetOtpUseCase(
          email: 'test@example.com',
          otp: '000000',
        );

        expect(result.isLeft(), isTrue);
      },
    );
  });
}
