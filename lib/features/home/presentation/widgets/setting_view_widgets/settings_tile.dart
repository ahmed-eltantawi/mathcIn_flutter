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
    final theme = Theme.of(context);

    final foregroundColor = isDestructive
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

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
                    alpha: 0.08,
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  color: foregroundColor,
                  size: 24.sp,
                ),
              ),

              SizedBox(width: 14.w),

              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(
                        color: isDestructive
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurface,
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
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                  SizedBox(width: 6.w),
                ],
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDestructive
                      ? theme.colorScheme.error.withValues(
                          alpha: 0.7,
                        )
                      : theme.colorScheme.onSurface
                            .withValues(alpha: 0.25),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
