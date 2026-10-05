import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SkillChip extends StatelessWidget {
  const SkillChip({required this.label, this.onRemove, super.key});

  final String label;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      padding: EdgeInsetsDirectional.only(
        start: 14.w,
        end: onRemove == null ? 14.w : 8.w,
        top: 9.h,
        bottom: 9.h,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: context.theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (onRemove != null) ...[
            SizedBox(width: 5.w),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(100.r),
              child: Padding(
                padding: EdgeInsets.all(2.r),
                child: Icon(
                  Icons.close_rounded,
                  size: 18.r,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
