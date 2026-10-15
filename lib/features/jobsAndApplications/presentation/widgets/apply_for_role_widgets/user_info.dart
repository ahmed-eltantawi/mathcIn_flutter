import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/apply_for_role_widgets/user_info_field.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_profile_entity.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_cached_candidate_profile_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_candidate_profile_use_case.dart';
import 'package:MatchIn/generated/l10n.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  CandidateProfileEntity? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final cachedResult = await getIt<GetCachedCandidateProfileUseCase>()();
      if (!mounted) return;
      cachedResult.fold(
        (_) => _fetchRemoteProfile(),
        (profile) {
          if (profile != null) {
            setState(() => _profile = profile);
          } else {
            _fetchRemoteProfile();
          }
        },
      );
    } catch (_) {
      _fetchRemoteProfile();
    }
  }

  Future<void> _fetchRemoteProfile() async {
    try {
      final result = await getIt<GetCandidateProfileUseCase>()();
      if (!mounted) return;
      result.fold(
        (_) {},
        (profile) => setState(() => _profile = profile),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    final name = _profile?.user.name.trim().isNotEmpty == true
        ? _profile!.user.name.trim()
        : '—';
    final email = _profile?.user.email.trim().isNotEmpty == true
        ? _profile!.user.email.trim()
        : '—';
    final phone = _profile?.user.phone?.trim().isNotEmpty == true
        ? _profile!.user.phone!.trim()
        : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                s.yourInformation,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(Icons.lock_outline_rounded, size: 21.sp),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          s.reviewInformationBeforeContinuing,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(
              alpha: 0.6,
            ),
          ),
        ),
        SizedBox(height: 14.h),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                UserInfoField(
                  label: s.fullName,
                  value: name,
                ),
                SizedBox(height: 16.h),
                UserInfoField(
                  label: s.emailAddress,
                  value: email,
                ),
                SizedBox(height: 16.h),
                UserInfoField(
                  label: s.phoneNumber,
                  value: phone,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
