import 'package:MatchIn/core/utils/app_text_styles.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreatePasswordHeader extends StatelessWidget {
  const CreatePasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).createNewPassword,
          style: AppTextStyles.heading24Bold(
            isArabic: false,
            color: colorScheme.primary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          S.of(context).chooseStrongPassword,
          style: AppTextStyles.body14Regular(
            isArabic: false,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
