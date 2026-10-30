import 'dart:async';
import 'dart:typed_data';

import 'package:MatchIn/core/services/picked_file.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/core/services/profile_image_picker_service.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/avatar_file_validator.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/avatar_preview_dialog.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/avatar_source_sheet.dart';
import 'package:MatchIn/core/widgets/error/app_error.dart';
import 'package:MatchIn/core/utils/profile_formatters.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_profile_entity.dart';
import 'package:MatchIn/features/profile/data/data_sources/location/location_catalog.dart';
import 'package:MatchIn/features/profile/presentation/cubits/profile_cubit/edit_profile_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/profile_cubit/edit_profile_state.dart';
import 'package:MatchIn/features/profile/presentation/cubits/profile_cubit/profile_cubit.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/edit_profile_patch_mapper.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/military_status_options.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/profile_form_validator.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/edit_profile_actions.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/personal_information_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/professional_information_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/professional_links_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/profile_location_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/profile_photo_editor.dart';
import 'package:MatchIn/features/profile/presentation/utils/profile_avatar_url.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/profile_skeleton.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditProfileViewBody extends StatelessWidget {
  const EditProfileViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditProfileCubit, EditProfileState>(
      listenWhen: (previous, current) =>
          current is EditProfileActionFailure || current is EditProfileSuccess,
      listener: (context, state) {
        final locale = S.of(context);
        final messenger = ScaffoldMessenger.of(context);
        switch (state) {
          case EditProfileActionFailure():
            final message = state.message.trim().isEmpty
                ? locale.somethingWentWrong
                : state.message;
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          case EditProfileSuccess():
            context.read<ProfileCubit>().publishProfile(state.profile);
            final message = state.hasUnpersistedChanges
                ? locale.unsupportedProfileFieldsNotSaved
                : locale.profileSynced;
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
            Navigator.of(context).pop(true);
          default:
            break;
        }
      },
      // The form stays mounted for Ready/Saving/ActionFailure/Success:
      // the builder always returns the same _EditProfileForm widget type,
      // so its State (and all controllers) is preserved across transitions.
      // Only initial-load states replace the form with loading/error UI.
      builder: (context, state) {
        switch (state) {
          case EditProfileInitial():
          case EditProfileLoading():
            return const ProfileFormSkeleton();
          case EditProfileLoadFailure():
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              children: [
                AppErrorWidget(
                  message: state.message,
                  onRetry: () => context.read<EditProfileCubit>().loadProfile(),
                ),
              ],
            );
          case EditProfileReady():
            return _EditProfileForm(
              initialProfile: state.profile,
              isSaving: false,
            );
          case EditProfileSaving():
            return _EditProfileForm(
              initialProfile: state.profile,
              isSaving: true,
            );
          case EditProfileActionFailure():
            final baseline = state.profile;
            if (baseline == null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                children: [
                  AppErrorWidget(
                    message: state.message,
                    onRetry: () =>
                        context.read<EditProfileCubit>().loadProfile(),
                  ),
                ],
              );
            }
            return _EditProfileForm(initialProfile: baseline, isSaving: false);
          case EditProfileAvatarStaged():
            return _EditProfileForm(
              initialProfile: state.profile,
              isSaving: false,
              avatarBytes: state.avatarBytes,
              avatarFileName: state.fileName,
            );
          case EditProfileSuccess():
            return _EditProfileForm(
              initialProfile: state.profile,
              isSaving: false,
            );
        }
      },
    );
  }
}

class _EditProfileForm extends StatefulWidget {
  const _EditProfileForm({
    required this.initialProfile,
    this.isSaving = false,
    this.avatarBytes,
    this.avatarFileName,
  });

  final CandidateProfileEntity initialProfile;
  final bool isSaving;

  /// Staged in-memory avatar preview from [EditProfileAvatarStaged].
  /// Display only; never persisted by this form.
  final Uint8List? avatarBytes;
  final String? avatarFileName;

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  final GlobalKey<FormFieldState<String>> _fullNameFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _githubFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _linkedinFieldKey =
      GlobalKey<FormFieldState<String>>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _dateOfBirthController;
  late final TextEditingController _phoneController;
  late final TextEditingController _jobTitleController;
  late final TextEditingController _githubController;
  late final TextEditingController _linkedinController;
  late final TextEditingController _locationController;

  late final ValueNotifier<String?> _gender;
  late final ValueNotifier<String?> _countryCode;
  late final ValueNotifier<String?> _militaryStatus;

  LocationCatalog get _locationCatalog => getIt<LocationCatalog>();

  @override
  void initState() {
    super.initState();

    final user = widget.initialProfile.user;
    final details = widget.initialProfile.profile;

    _fullNameController = TextEditingController(text: user.name);

    _dateOfBirthController = TextEditingController(
      text: ProfileFormValidator.normalizeDateForDisplay(details?.dateOfBirth),
    );

    _phoneController = TextEditingController(text: user.phone ?? '');

    _jobTitleController = TextEditingController(text: details?.jobTitle ?? '');

    _githubController = TextEditingController(text: details?.githubUrl ?? '');

    _linkedinController = TextEditingController(
      text: details?.linkedinUrl ?? '',
    );
    _locationController = TextEditingController(
      text: details?.location ?? ProfileFormatters.location(details),
    );

    _gender = ValueNotifier<String?>(details?.gender);

    _countryCode = ValueNotifier<String?>(null);

    _militaryStatus = ValueNotifier<String?>(details?.militaryStatus);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dateOfBirthController.dispose();
    _phoneController.dispose();
    _jobTitleController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _locationController.dispose();

    _gender.dispose();
    _countryCode.dispose();
    _militaryStatus.dispose();

    super.dispose();
  }

  void _handleSave() {
    if (widget.isSaving) return;
    final fullNameIsValid = _fullNameFieldKey.currentState?.validate() ?? false;
    final githubIsValid = _githubFieldKey.currentState?.validate() ?? false;
    final linkedInIsValid = _linkedinFieldKey.currentState?.validate() ?? false;
    final isValid = fullNameIsValid && githubIsValid && linkedInIsValid;
    if (!isValid) return;

    final params = EditProfilePatchMapper.fromDiff(
      baseline: widget.initialProfile,
      fullName: _fullNameController.text,
      phone: _phoneController.text,
      dateOfBirth: _dateOfBirthController.text,
      gender: _gender.value,
      jobTitle: _jobTitleController.text,
      country: null,
      state: null,
      city: null,
      location: _locationController.text,
      githubUrl: _githubController.text,
      linkedinUrl: _linkedinController.text,
      militaryStatus: _militaryStatus.value,
    );

    final hasUnsupportedProfileEdits = params.hasUnsupportedChanges;
    if (hasUnsupportedProfileEdits) {
      _showUnsupportedProfileEditsNotice();
    }

    // No API-supported field changed: skip the PATCH and stay on screen if
    // any unsupported values were edited.
    if (!params.hasApiSupportedChanges) {
      if (!hasUnsupportedProfileEdits) {
        Navigator.of(context).pop(false);
      }
      return;
    }

    context.read<EditProfileCubit>().updateProfile(
      params,
      hasUnpersistedChanges: hasUnsupportedProfileEdits,
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showUnsupportedProfileEditsNotice() {
    _showMessage(S.of(context).unsupportedProfileFieldsNotSaved);
  }

  /// Change Photo flow: source sheet → platform pick → validation →
  /// cubit staging → preview dialog. Cancellation at any step keeps
  /// the existing avatar; nothing is persisted here.
  Future<void> _pickAndStageAvatar() async {
    if (widget.isSaving) return;
    final locale = S.of(context);

    final source = await AvatarSourceSheet.show(context);
    if (source == null || !mounted) return;

    final PickedFile? picked;
    try {
      picked = await getIt<ProfileImagePickerService>().pickProfileImage(
        source,
      );
    } catch (_) {
      if (mounted) _showMessage(locale.somethingWentWrong);
      return;
    }
    if (!mounted) return;
    if (picked == null) return;

    final error = AvatarFileValidator.validate(
      fileName: picked.name,
      sizeBytes: picked.bytes.length,
      hasContent: picked.bytes.isNotEmpty,
      unsupportedMessage: locale.invalidImageType,
      tooLargeMessage: locale.imageTooLarge,
      emptyMessage: locale.cvEmptyFile,
    );
    if (error != null) {
      _showMessage(error);
      return;
    }
    if (!mounted) return;

    final cubit = context.read<EditProfileCubit>();
    await cubit.stageAvatar(avatarBytes: picked.bytes, fileName: picked.name);
    if (!mounted) return;

    final staged = cubit.state;
    if (staged is! EditProfileAvatarStaged) return;

    final action = await AvatarPreviewDialog.show(
      context,
      bytes: staged.avatarBytes,
      fileName: staged.fileName,
    );
    if (!mounted) return;

    switch (action) {
      case AvatarPreviewAction.confirm:
        await context.read<EditProfileCubit>().confirmAvatarUpload();
      case AvatarPreviewAction.retake:
        context.read<EditProfileCubit>().clearStagedAvatar();
        // Fire-and-forget restart so retakes don't nest awaits.
        unawaited(_pickAndStageAvatar());
      case AvatarPreviewAction.cancel:
      case null:
        if (mounted) context.read<EditProfileCubit>().clearStagedAvatar();
    }
  }

  Future<void> _pickDateOfBirth() async {
    if (widget.isSaving) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initialDate =
        ProfileFormValidator.parseDisplayDate(
          _dateOfBirthController.text.trim(),
        ) ??
        today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(today) ? today : initialDate,
      firstDate: DateTime(1950),
      lastDate: today,
    );
    if (picked == null) return;
    _dateOfBirthController.text = ProfileFormValidator.formatDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final theme = Theme.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final callingCodes = _locationCatalog.callingCodes(arabic: arabic);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
      children: [
        // Header
        Row(
          children: [
            IconButton(
              onPressed: widget.isSaving
                  ? null
                  : () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                locale.editProfile,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        if (widget.isSaving) ...[
          SizedBox(height: 12.h),
          const LinearProgressIndicator(),
        ],

        SizedBox(height: 24.h),

        // Profile picture: staged preview takes precedence while
        // picking; Change Photo and the camera badge share one flow.
        ProfilePhotoEditor(
          avatarUrl: ProfileAvatarUrl.resolve(
            widget.initialProfile.user.avatar,
          ),
          previewBytes: widget.avatarBytes,
          onChangePhoto: widget.isSaving ? null : _pickAndStageAvatar,
        ),

        SizedBox(height: 24.h),

        // Personal Information
        ValueListenableBuilder<String?>(
          valueListenable: _gender,
          builder: (context, gender, child) {
            return ValueListenableBuilder<String?>(
              valueListenable: _countryCode,
              builder: (context, countryCode, child) {
                return PersonalInformationCard(
                  fullNameController: _fullNameController,
                  dateOfBirthController: _dateOfBirthController,
                  phoneController: _phoneController,
                  gender: gender,
                  countryCode: countryCode,

                  countryCodes: callingCodes,

                  onGenderChanged: (value) {
                    _gender.value = value;
                  },
                  onCountryCodeChanged: (value) {
                    _countryCode.value = value;
                  },
                  onDateOfBirthTap: _pickDateOfBirth,
                  fullNameFieldKey: _fullNameFieldKey,
                  fullNameValidator: (value) =>
                      ProfileFormValidator.requiredValue(
                        value,
                        requiredMessage: locale.required,
                      ),
                );
              },
            );
          },
        ),

        SizedBox(height: 16.h),

        // Professional Information
        ValueListenableBuilder<String?>(
          valueListenable: _militaryStatus,
          builder: (context, militaryStatus, child) {
            return ProfessionalInformationCard(
              jobTitleController: _jobTitleController,
              militaryStatus: militaryStatus,
              militaryStatusItems: MilitaryStatusOptions.items(locale),
              militaryStatusDisabledValues:
                  MilitaryStatusOptions.disabledValues,
              onMilitaryStatusChanged: (value) {
                _militaryStatus.value = value;
              },
            );
          },
        ),

        SizedBox(height: 16.h),

        // Location
        ProfileLocationCard(controller: _locationController),

        SizedBox(height: 16.h),

        // Professional Links
        ProfessionalLinksCard(
          githubController: _githubController,
          linkedinController: _linkedinController,
          githubFieldKey: _githubFieldKey,
          linkedinFieldKey: _linkedinFieldKey,
          githubValidator: (value) => ProfileFormValidator.optionalWebUrl(
            value,
            invalidMessage: locale.invalidProfileUrl,
          ),
          linkedinValidator: (value) => ProfileFormValidator.optionalWebUrl(
            value,
            invalidMessage: locale.invalidProfileUrl,
          ),
        ),

        SizedBox(height: 28.h),

        // Actions
        EditProfileActions(
          isSaving: widget.isSaving,
          onSave: _handleSave,
          onCancel: () => Navigator.of(context).pop(),
        ),

        SizedBox(height: 24.h),
      ],
    );
  }
}
