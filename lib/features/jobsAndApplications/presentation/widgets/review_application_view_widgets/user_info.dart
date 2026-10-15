import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/review_application_view_widgets/user_info_row.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_profile_entity.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_cached_candidate_profile_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_candidate_profile_use_case.dart';
import 'package:MatchIn/generated/l10n.dart';

class UserInformation extends StatefulWidget {
  const UserInformation({super.key});

  @override
  State<UserInformation> createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
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
      children: [
        InfoRow(label: s.fullName, value: name),
        SizedBox(height: 12.h),
        InfoRow(
          label: s.emailAddress,
          value: email,
        ),
        SizedBox(height: 12.h),
        InfoRow(
          label: s.phoneNumber,
          value: phone,
        ),
      ],
    );
  }
}
