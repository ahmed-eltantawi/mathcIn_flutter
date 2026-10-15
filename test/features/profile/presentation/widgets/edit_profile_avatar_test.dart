import 'dart:typed_data';

import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/services/picked_file.dart';
import 'package:MatchIn/core/services/profile_image_picker_service.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/profile/data/data_sources/location/location_catalog.dart';
import 'package:MatchIn/features/profile/domain/entities/avatar_upload_input.dart';
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
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/profile_photo_editor.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart' hide PickedFile;

class FakeAvatarRepository extends Fake implements ProfileRepository {
  int avatarCalls = 0;

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
        profile: CandidateProfileDetailsEntity(id: 9),
      ),
    );
  }

  @override
  Future<Either<Failure, CandidateProfileEntity>> updateCandidateProfile(
    UpdateCandidateProfileParams params,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> uploadAvatar(AvatarUploadInput input) async {
    avatarCalls++;
    return const Left(
      ServerFailure(message: 'Avatar upload is not available yet.'),
    );
  }
}

class FakeImagePicker extends ImagePicker {
  PickedFile? nextFile;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    final file = nextFile;
    if (file == null) return null;
    return XFile.fromData(file.bytes, name: file.name, path: file.name);
  }
}

Future<void> _pumpEditProfile(
  WidgetTester tester, {
  required FakeImagePicker picker,
}) async {
  final repo = FakeAvatarRepository();
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
  getIt.registerLazySingleton<ProfileImagePickerService>(
    () => ProfileImagePickerService(imagePicker: picker),
  );
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

Finder _dialogButton(String label) =>
    find.descendant(of: find.byType(AlertDialog), matching: find.text(label));

void main() {
  final jpg = PickedFile(
    name: 'photo.jpg',
    bytes: Uint8List.fromList(List.filled(100, 7)),
  );

  group('EditProfile avatar flow', () {
    testWidgets('Change Photo is enabled and opens the source sheet', (
      tester,
    ) async {
      await _pumpEditProfile(tester, picker: FakeImagePicker());

      final button = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Change photo'),
      );
      expect(button.onPressed, isNotNull);

      await tester.ensureVisible(find.byType(ProfilePhotoEditor));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Change photo'));
      await tester.pumpAndSettle();

      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Choose from Gallery'), findsOneWidget);
    });

    testWidgets('confirm reports pending without saving or uploading', (
      tester,
    ) async {
      final picker = FakeImagePicker()..nextFile = jpg;
      await _pumpEditProfile(tester, picker: picker);

      await tester.ensureVisible(find.byType(ProfilePhotoEditor));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Change photo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from Gallery'));
      await tester.pumpAndSettle();

      expect(find.text('Preview Photo'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);

      await tester.tap(_dialogButton('Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Avatar upload is not available yet.'), findsOneWidget);
      // Still on the Edit screen with the staged preview, no success claim.
      expect(find.byType(ProfilePhotoEditor), findsOneWidget);
      expect(find.text('Profile synced'), findsNothing);
    });

    testWidgets('cancel discards the preview and keeps the avatar', (
      tester,
    ) async {
      final picker = FakeImagePicker()..nextFile = jpg;
      await _pumpEditProfile(tester, picker: picker);

      await tester.ensureVisible(find.byType(ProfilePhotoEditor));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Change photo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from Gallery'));
      await tester.pumpAndSettle();
      await tester.tap(_dialogButton('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Preview Photo'), findsNothing);
      expect(find.byType(ProfilePhotoEditor), findsOneWidget);
    });

    testWidgets('picker cancellation stays silent on the form', (tester) async {
      await _pumpEditProfile(tester, picker: FakeImagePicker());

      await tester.ensureVisible(find.byType(ProfilePhotoEditor));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Change photo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from Gallery'));
      await tester.pumpAndSettle();

      expect(find.text('Preview Photo'), findsNothing);
      expect(find.byType(ProfilePhotoEditor), findsOneWidget);
    });
  });
}
