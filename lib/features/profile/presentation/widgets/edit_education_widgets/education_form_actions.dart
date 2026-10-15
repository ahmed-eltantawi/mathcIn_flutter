import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EducationFormActions extends StatelessWidget {
  const EducationFormActions({
    required this.onCancel,
    required this.onSave,
    this.isSaving = false,
    super.key,
  });

  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 54.h,
            child: OutlinedButton(
              onPressed: isSaving ? null : onCancel,
              child: Text(locale.cancel),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: SizedBox(
            height: 54.h,
            child: FilledButton(
              onPressed: isSaving ? null : onSave,
              child: isSaving
                  ? SizedBox(
                      width: 24.r,
                      height: 24.r,
                      child: const CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Text(locale.saveEducation),
            ),
          ),
        ),
      ],
    );
  }
}
