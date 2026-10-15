import 'package:MatchIn/features/profile/presentation/widgets/edit_projects_widgets/project_text_field.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProjectDateFields extends StatelessWidget {
  const ProjectDateFields({
    this.startDateController,
    this.endDateController,
    this.onStartDateTap,
    this.onEndDateTap,
    super.key,
  });

  final TextEditingController? startDateController;
  final TextEditingController? endDateController;
  final VoidCallback? onStartDateTap;
  final VoidCallback? onEndDateTap;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ProjectTextField(
            label: locale.startDate,
            hint: locale.monthYearHint,
            controller: startDateController,
            readOnly: true,
            onTap: onStartDateTap,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ProjectTextField(
            label: locale.endDate,
            hint: locale.monthYearHint,
            controller: endDateController,
            readOnly: true,
            onTap: onEndDateTap,
          ),
        ),
      ],
    );
  }
}
