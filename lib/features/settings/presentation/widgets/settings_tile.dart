import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailingText,
    this.onTap,
    this.trailing,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String? trailingText;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.colors;

    final foregroundColor = isDestructive
        ? colors.error
        : colors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 14.h,
          ),
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: foregroundColor.withValues(
                    alpha: isDestructive ? 0.1 : 0.08,
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  color: foregroundColor,
                  size: 22.sp,
                ),
              ),

              SizedBox(width: 14.w),

              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDestructive
                        ? colors.error
                        : colors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              if (trailing != null)
                trailing!
              else ...[
                if (trailingText != null) ...[
                  Text(
                    trailingText!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(width: 6.w),
                ],
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20.sp,
                  color: isDestructive
                      ? colors.error.withValues(alpha: 0.7)
                      : colors.onSurface.withValues(alpha: 0.3),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
