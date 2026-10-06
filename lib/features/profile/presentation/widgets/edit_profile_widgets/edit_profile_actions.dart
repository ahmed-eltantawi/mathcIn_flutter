import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditProfileActions extends StatelessWidget {
  const EditProfileActions({
    required this.onSave,
    required this.onCancel,
    super.key,
  });

  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54.h,
          child: FilledButton(
            onPressed: onSave,
            child: Text(locale.saveChanges),
          ),
        ),
        SizedBox(height: 8.h),
        TextButton(
          onPressed: onCancel,
          child: Text(locale.cancel),
        ),
      ],
    );
  }
}
