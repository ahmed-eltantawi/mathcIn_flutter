import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/user_info_field.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserInfo extends StatelessWidget {
  const UserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

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
                  value: 'Ahmed Mohamed',
                ),
                SizedBox(height: 16.h),
                UserInfoField(
                  label: s.emailAddress,
                  value: 'ahmed@email.com',
                ),
                SizedBox(height: 16.h),
                UserInfoField(
                  label: s.phoneNumber,
                  value: '+20 100 000 0000',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
