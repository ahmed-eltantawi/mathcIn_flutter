import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/errors/error_message_resolver.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';

class JobsOfflineBanner extends StatelessWidget {
  const JobsOfflineBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final effectiveMessage = ErrorMessageResolver.resolve(context, message);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 18.sp,
            color: context.colors.primary,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              effectiveMessage,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
