import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/theme/app_semantic_colors.dart';
import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PasswordRequirementTile extends StatelessWidget {
  const PasswordRequirementTile({
    super.key,
    required this.text,
    required this.isMet,
  });

  final String text;
  final bool isMet;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final successColor =
        context.theme.extension<AppSemanticColors>()?.success ??
            AppColors.forestGreen;
    final Color iconColor = isMet
        ? successColor
        : colors.onSurfaceVariant.withValues(alpha: 0.6);
    final Color textColor = isMet
        ? colors.onSurface
        : colors.onSurfaceVariant;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              color: isMet
                  ? successColor.withValues(alpha: 0.15)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              isMet ? Icons.check_rounded : Icons.circle,
              size: isMet ? 12.sp : 5.sp,
              color: iconColor,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: isMet
                  ? AppTextStyles.body12SemiBold(
                      isArabic: false,
                      color: textColor,
                    )
                  : AppTextStyles.body12Regular(
                      isArabic: false,
                      color: textColor,
                    ),
              child: Text(text),
            ),
          ),
        ],
      ),
    );
  }
}
