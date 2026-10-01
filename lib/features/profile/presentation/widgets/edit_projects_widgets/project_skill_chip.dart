import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProjectSkillChip extends StatelessWidget {
  const ProjectSkillChip({
    required this.label,
    this.onRemove,
    super.key,
  });

  final String label;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: EdgeInsetsDirectional.only(
        start: 11.w,
        end: onRemove == null ? 11.w : 7.w,
        top: 6.h,
        bottom: 6.h,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(
          color: context.theme.dividerColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (onRemove != null) ...[
            SizedBox(width: 3.w),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(50.r),
              child: Icon(
                Icons.close_rounded,
                size: 16.r,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
