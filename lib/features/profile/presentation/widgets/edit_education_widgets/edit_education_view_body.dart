import 'package:MatchIn/features/profile/presentation/widgets/edit_education_widgets/education_academic_history_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_education_widgets/education_form.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_education_widgets/education_management_header.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_education_widgets/education_recruiter_visibility_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditEducationViewBody extends StatelessWidget {
  const EditEducationViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final theme = Theme.of(context);

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
      children: [
        EducationManagementHeader(onBack: () => Navigator.of(context).pop()),
        SizedBox(height: 24.h),
        const EducationAcademicHistoryCard(),
        SizedBox(height: 28.h),
        Row(
          children: [
            Expanded(
              child: Text(
                locale.verifiedQualifications,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        // Records will be rendered here after Education domain integration.
        const EducationForm(),
        SizedBox(height: 24.h),
        const EducationRecruiterVisibilityCard(),
      ],
    );
  }
}
