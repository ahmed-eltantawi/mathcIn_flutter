import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CareerPreferencesActions extends StatelessWidget {
  const CareerPreferencesActions({
    required this.onSavePressed,
    required this.onCancelPressed,
    this.isSaving = false,
    super.key,
  });

  final VoidCallback onSavePressed;
  final VoidCallback onCancelPressed;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final locale = S.of(context);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: FilledButton(
            onPressed: isSaving ? null : onSavePressed,
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: isSaving
                ? SizedBox(
                    width: 24.r,
                    height: 24.r,
                    child: const CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : Text(
                    locale.savePreferences,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 10.h),
        TextButton(
          onPressed: isSaving ? null : onCancelPressed,
          child: Text(
            locale.cancel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
