import 'package:MatchIn/core/utils/app_colors.dart';
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
    final Color iconColor = isMet ? AppColors.success : const Color(0xFF74777F);
    final Color textColor = isMet
        ? AppColors.textPrimary
        : const Color(0xFF44474E);

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
                  ? AppColors.success.withValues(alpha: 0.15)
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
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.sp,
                fontWeight: isMet ? FontWeight.w500 : FontWeight.w400,
                color: textColor,
                height: 16 / 12,
              ),
              child: Text(text),
            ),
          ),
        ],
      ),
    );
  }
}
