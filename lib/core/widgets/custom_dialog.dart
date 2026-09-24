import 'package:MatchIn/core/utils/app_text_styles.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  final String title;
  final String message;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);
    final locale = S.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Text(
        title,
        style: AppTextStyles.heading18Bold(isArabic: isArabic),
      ),
      content: Text(
        message,
        style: AppTextStyles.body14Regular(
          isArabic: isArabic,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(locale.cancel, style: TextStyle(color: theme.colorScheme.error)),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          child: Text(locale.confirm),
        ),
      ],
    );
  }
}