import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/profile/data/data_sources/location/location_catalog.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_profile_details_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_profile_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/profile_user_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_candidate_profile_params.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_candidate_profile_for_edit_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/update_candidate_profile_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/upload_avatar_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/profile_cubit/edit_profile_cubit.dart';
import 'package:MatchIn/features/profile/presentation/views/edit_profile_view.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/edit_profile_field.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeDobRepository extends Fake implements ProfileRepository {
  @override
  Future<Either<Failure, CandidateProfileEntity>>
  getCandidateProfileForEdit() async {
    return const Right(
      CandidateProfileEntity(
        profileExists: true,
        user: ProfileUserEntity(
          id: 7,
          name: 'Layla Hassan',
          email: 'layla@example.com',
          role: 'candidate',
          isActive: true,
        ),
        profile: CandidateProfileDetailsEntity(
          id: 9,
          dateOfBirth: '2010-10-05T00:00:00.000000Z',
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, CandidateProfileEntity>> updateCandidateProfile(
    UpdateCandidateProfileParams params,
  ) async {
    throw UnimplementedError();
  }
}

Future<void> _pumpEditProfile(WidgetTester tester) async {
  final repo = FakeDobRepository();
  getIt.registerFactory<EditProfileCubit>(
    () => EditProfileCubit(
      getCandidateProfileForEditUseCase: GetCandidateProfileForEditUseCase(
        repo,
      ),
      updateCandidateProfileUseCase: UpdateCandidateProfileUseCase(repo),
      uploadAvatarUseCase: UploadAvatarUseCase(repository: repo),
    ),
  );
  getIt.registerLazySingleton<LocationCatalog>(() => const LocationCatalog());
  addTearDown(getIt.reset);

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
        home: const EditProfileView(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _dobField() => find.descendant(
  of: find.ancestor(
    of: find.text('Date of birth'),
    matching: find.byType(EditProfileField),
  ),
  matching: find.byType(TextFormField),
);

void main() {
  group('EditProfile date of birth display', () {
    testWidgets('shows YYYY-MM-DD for ISO-8601 backend values', (tester) async {
      await _pumpEditProfile(tester);

      final field = tester.widget<TextFormField>(_dobField());
      expect(field.controller!.text, '2010-10-05');
    });

    testWidgets('tapping the field keeps the date picker working', (
      tester,
    ) async {
      await _pumpEditProfile(tester);

      await tester.ensureVisible(_dobField());
      await tester.pumpAndSettle();
      await tester.tap(_dobField());
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
    });
  });
}
