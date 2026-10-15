import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditProfileActions extends StatelessWidget {
  const EditProfileActions({
    required this.onSave,
    required this.onCancel,
    this.isSaving = false,
    super.key,
  });

  final VoidCallback onSave;
  final VoidCallback onCancel;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: FilledButton(
            onPressed: isSaving ? null : onSave,
            child: isSaving
                ? SizedBox(
                    width: 24.r,
                    height: 24.r,
                    child: const CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : Text(locale.saveChanges),
          ),
        ),
        SizedBox(height: 10.h),
        TextButton(
          onPressed: isSaving ? null : onCancel,
          child: Text(locale.cancel),
        ),
      ],
    );
  }
}
