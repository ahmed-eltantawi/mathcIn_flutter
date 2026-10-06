import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExperienceFormActions extends StatelessWidget {
  const ExperienceFormActions({
    required this.onCancel,
    required this.onSave,
    super.key,
  });

  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52.h,
            child: OutlinedButton(
              onPressed: onCancel,
              child: Text(locale.cancel),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: SizedBox(
            height: 52.h,
            child: FilledButton(
              onPressed: onSave,
              child: Text(locale.saveExperience),
            ),
          ),
        ),
      ],
    );
  }
}
