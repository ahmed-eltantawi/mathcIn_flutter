import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  final String text;
  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.onSurface,
        backgroundColor: isDark
            ? colors.surfaceContainerHighest.withValues(alpha: 0.35)
            : Colors.transparent,
        side: BorderSide(color: colors.outline),
        minimumSize: Size(double.infinity, 56.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconTheme(
            data: IconThemeData(
              color: colors.onSurface,
            ),
            child: icon,
          ),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}