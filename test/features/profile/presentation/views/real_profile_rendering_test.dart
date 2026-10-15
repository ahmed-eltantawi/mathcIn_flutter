import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/services/file_picker_service.dart';
import 'package:MatchIn/core/services/picked_file.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_profile_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_local_file.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_pending_upload.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_upload_input.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_upload_receipt.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_cached_candidate_profile_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_candidate_profile_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_local_cv_file_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_pending_cv_upload_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/retry_pending_cv_upload_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/upload_cv_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/cv_cubit/cv_upload_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/profile_cubit/profile_cubit.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/profile_view_body.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/models/real_profile_response_test.dart'
    as real_profile_fixture;

class FakeRenderingRepository extends Fake implements ProfileRepository {
  @override
  Future<Either<Failure, CandidateProfileEntity>> getCandidateProfile() async {
    return Right(real_profile_fixture.parseRealProfile());
  }

  @override
  Future<Either<Failure, CandidateProfileEntity?>>
  getCachedCandidateProfile() async {
    return Right(real_profile_fixture.parseRealProfile());
  }

  @override
  Future<Either<Failure, CvUploadReceipt?>> uploadCv(
    CvUploadInput input,
  ) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, CvPendingUpload?>> getPendingCvUpload() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, CvUploadReceipt?>> retryPendingCvUpload() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, CvLocalFile?>> getLocalCvFile() async {
    return const Right(null);
  }
}

class _StubPicker implements FilePickerService {
  @override
  Future<PlatformFile?> pickCv() async => null;

  @override
  Future<PickedFile?> pickCvBytes() async => null;
}

Future<void> _pumpMainProfile(WidgetTester tester) async {
  final repo = FakeRenderingRepository();
  final cubit = ProfileCubit(
    getCandidateProfileUseCase: GetCandidateProfileUseCase(repository: repo),
    getCachedCandidateProfileUseCase: GetCachedCandidateProfileUseCase(
      repository: repo,
    ),
  );
  addTearDown(cubit.close);
  getIt.registerFactory<CvUploadCubit>(
    () => CvUploadCubit(
      uploadCvUseCase: UploadCvUseCase(repository: repo),
      getPendingCvUploadUseCase: GetPendingCvUploadUseCase(repository: repo),
      retryPendingCvUploadUseCase: RetryPendingCvUploadUseCase(
        repository: repo,
      ),
      getLocalCvFileUseCase: GetLocalCvFileUseCase(repository: repo),
    ),
  );
  getIt.registerSingleton<FilePickerService>(_StubPicker());
  addTearDown(getIt.reset);

  await cubit.getCandidateProfile();

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 845),
      builder: (_, _) => MaterialApp(
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: const ProfileViewBody(),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Real profile Main Profile rendering', () {
    testWidgets('shows every saved relation record', (tester) async {
      await _pumpMainProfile(tester);

      expect(find.text('Cairo University'), findsOneWidget);
      expect(find.text('NileTech'), findsOneWidget);
      expect(find.text('Order Engine'), findsOneWidget);
      expect(find.text('Dart'), findsWidgets);
      expect(find.text('Senior Backend Engineer'), findsOneWidget);
    });

    testWidgets('shows the current CV without requiring file_url', (
      tester,
    ) async {
      await _pumpMainProfile(tester);

      expect(find.text('cv.pdf'), findsOneWidget);
      expect(find.text('Analyzing'), findsOneWidget);
      expect(find.text('Upload your CV'), findsNothing);
    });

    testWidgets('displays clean calendar dates', (tester) async {
      await _pumpMainProfile(tester);

      expect(find.text('2020-09-01 – 2024-06-01'), findsOneWidget);
      expect(find.text('2024-01-01 – Present'), findsOneWidget);
      expect(find.text('2026-09-01'), findsOneWidget);
      expect(find.textContaining('T00:00:00'), findsNothing);
    });
  });
}
