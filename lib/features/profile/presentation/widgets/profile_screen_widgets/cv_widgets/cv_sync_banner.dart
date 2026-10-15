import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Inline status banner for CV synchronization states.
///
/// Shown above the CV card for pending uploads (offline) and for
/// failed uploads without an existing document. Never replaces the
/// card itself, so a previously uploaded CV stays visible.
class CvSyncBanner extends StatelessWidget {
  const CvSyncBanner({
    required this.message,
    required this.icon,
    this.onRetry,
    super.key,
  });

  final String message;
  final IconData icon;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20.r, color: colors.onSurfaceVariant),

          SizedBox(width: 10.w),

          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),

          if (onRetry != null) ...[
            SizedBox(width: 8.w),
            TextButton(onPressed: onRetry, child: Text(S.of(context).retry)),
          ],
        ],
      ),
    );
  }
}
