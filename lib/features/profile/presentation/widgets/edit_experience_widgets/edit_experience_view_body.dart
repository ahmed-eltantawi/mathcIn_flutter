import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/experience_current_records.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/experience_form.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/experience_management_header.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/experience_record_data.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/experience_summary_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditExperienceViewBody extends StatelessWidget {
  const EditExperienceViewBody({
    super.key,
    this.experiences = const [],
    this.qualityLabel,
    this.completionPercentage,
  });

  final List<ExperienceRecordData> experiences;
  final String? qualityLabel;
  final int? completionPercentage;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
      children: [
        ExperienceManagementHeader(
          onBack: () => Navigator.of(context).pop(),
        ),

        SizedBox(height: 20.h),

        ExperienceSummaryCard(
          qualityLabel: qualityLabel,
          completionPercentage: completionPercentage,
        ),

        SizedBox(height: 22.h),

        ExperienceCurrentRecords(
          experiences: experiences,
          onEdit: (experience) {},
          onDelete: (experience) {},
        ),

        SizedBox(height: 16.h),

        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: FilledButton.icon(
            onPressed: () {},
            icon: Icon(Icons.add_rounded, size: 20.r),
            label: Text(locale.addExperience),
          ),
        ),

        SizedBox(height: 18.h),

        const ExperienceForm(),
      ],
    );
  }
}
