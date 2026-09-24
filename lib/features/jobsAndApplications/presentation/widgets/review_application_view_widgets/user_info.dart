import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/review_application_view_widgets/user_info_row.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserInformation extends StatelessWidget {
  const UserInformation({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Column(
      children: [
        InfoRow(label: s.fullName, value: 'Ahmed Mohamed'),
        SizedBox(height: 12.h),
        InfoRow(
          label: s.emailAddress,
          value: 'ahmed@email.com',
        ),
        SizedBox(height: 12.h),
        InfoRow(
          label: s.phoneNumber,
          value: '+20 100 000 0000',
        ),
      ],
    );
  }
}
