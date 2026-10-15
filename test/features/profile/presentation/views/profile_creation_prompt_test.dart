import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/services/file_picker_service.dart';
import 'package:MatchIn/core/services/picked_file.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_profile_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_local_file.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_pending_upload.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_upload_input.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_upload_receipt.dart';
import 'package:MatchIn/features/profile/domain/entities/education_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/profile_user_entity.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_cached_candidate_profile_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_candidate_profile_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_local_cv_file_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_pending_cv_upload_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/retry_pending_cv_upload_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/upload_cv_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/cv_cubit/cv_upload_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/profile_cubit/profile_cubit.dart';
import 'package:MatchIn/features/profile/presentation/views/profile_view.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/education_widgets/education_profile_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class FakePromptRepository extends Fake implements ProfileRepository {
  FakePromptRepository({required this.profileExists});

  final bool profileExists;
  int educationsCalls = 0;
  int profileCalls = 0;

  CandidateProfileEntity _profileForFlag() {
    if (profileExists) {
      return const CandidateProfileEntity(
        profileExists: true,
        user: ProfileUserEntity(
          id: 7,
          name: 'New Candidate',
          email: 'new@example.com',
          role: 'candidate',
          isActive: true,
        ),
      );
    }
    return const CandidateProfileEntity(
      profileExists: false,
      user: ProfileUserEntity(
        id: 7,
        name: 'New Candidate',
        email: 'new@example.com',
        role: 'candidate',
        isActive: true,
      ),
    );
  }

  @override
  Future<Either<Failure, CandidateProfileEntity>> getCandidateProfile() async {
    profileCalls++;
    return Right(_profileForFlag());
  }

  @override
  Future<Either<Failure, CandidateProfileEntity?>>
  getCachedCandidateProfile() async {
    return Right(_profileForFlag());
  }

  @override
  Future<Either<Failure, List<EducationEntity>>> getEducations() async {
    educationsCalls++;
    return const Right([]);
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

class _AutoPopTrue extends StatelessWidget {
  const _AutoPopTrue({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.pop(true);
    });
    return Scaffold(body: Text(label));
  }
}

Future<void> _pumpProfile(
  WidgetTester tester,
  FakePromptRepository repo,
) async {
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      getCandidateProfileUseCase: GetCandidateProfileUseCase(repository: repo),
      getCachedCandidateProfileUseCase: GetCachedCandidateProfileUseCase(
        repository: repo,
      ),
    ),
  );
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

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, _) => const ProfileView()),
      GoRoute(
        path: '/profile/editProfile',
        builder: (_, _) => const Scaffold(body: Text('edit profile stub')),
      ),
      GoRoute(
        path: '/profile/editEducation',
        builder: (_, _) => const _AutoPopTrue(label: 'education stub'),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 845),
      builder: (_, _) => MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _educationEditButton() => find.descendant(
  of: find.byType(EducationProfileCard),
  matching: find.byType(IconButton),
);

Future<void> _tapEducationEdit(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    _educationEditButton(),
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(_educationEditButton());
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() async {
    await getIt.reset();
  });

  group('Profile creation prompt', () {
    testWidgets('management tap shows creation prompt without management GET '
        'when profile_exists is false', (tester) async {
      final repo = FakePromptRepository(profileExists: false);
      await _pumpProfile(tester, repo);

      await _tapEducationEdit(tester);

      expect(
        find.text(
          'Complete your profile to start adding your education, '
          'experience, skills, and more.',
        ),
        findsOneWidget,
      );
      expect(find.text('education stub'), findsNothing);
      expect(repo.educationsCalls, 0);
    });

    testWidgets('Create Profile button opens the Edit Profile screen', (
      tester,
    ) async {
      final repo = FakePromptRepository(profileExists: false);
      await _pumpProfile(tester, repo);

      await _tapEducationEdit(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Create Profile'));
      await tester.pumpAndSettle();

      expect(find.text('edit profile stub'), findsOneWidget);
    });

    testWidgets(
      'returning true from a management screen refreshes Main Profile',
      (tester) async {
        final repo = FakePromptRepository(profileExists: true);
        await _pumpProfile(tester, repo);
        expect(repo.profileCalls, 1);

        await _tapEducationEdit(tester);

        expect(repo.profileCalls, 2);
        expect(
          find.text(
            'Complete your profile to start adding your education, '
            'experience, skills, and more.',
          ),
          findsNothing,
        );
      },
    );
  });
}
