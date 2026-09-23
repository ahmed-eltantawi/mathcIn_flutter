import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatusRow extends StatelessWidget {
  const StatusRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.showDot = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 20.sp,
            color: theme.colorScheme.onSurface.withValues(
              alpha: 0.6,
            ),
          ),
          SizedBox(width: 8.w),
        ],
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(
                alpha: 0.6,
              ),
            ),
          ),
        ),
        if (showDot)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 6.h,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(
                alpha: 0.08,
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '● $value',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Flexible(
            child: Align(
              alignment: .centerEnd,
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
