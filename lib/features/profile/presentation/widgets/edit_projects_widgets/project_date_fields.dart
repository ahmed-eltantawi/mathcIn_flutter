import 'package:MatchIn/features/profile/presentation/widgets/edit_projects_widgets/project_text_field.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProjectDateFields extends StatelessWidget {
  const ProjectDateFields({
    this.startDateController,
    this.endDateController,
    super.key,
  });

  final TextEditingController? startDateController;
  final TextEditingController? endDateController;

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
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ProjectTextField(
            label: locale.endDate,
            hint: locale.monthYearHint,
            controller: endDateController,
          ),
        ),
      ],
    );
  }
}
