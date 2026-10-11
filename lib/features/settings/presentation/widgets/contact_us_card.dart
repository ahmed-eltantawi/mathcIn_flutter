import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/extensions/snack_bar_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContactUsCard extends StatelessWidget {
  const ContactUsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.canCopy = false,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool canCopy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = context.theme;
    final l10n = context.l10n;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 0,
      color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: BorderSide(
          color: colors.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: colors.primary,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    value,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            if (canCopy)
              IconButton(
                icon: Icon(
                  Icons.copy_rounded,
                  size: 18.sp,
                  color: colors.primary,
                ),
                tooltip: l10n.copiedToClipboard,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  context.showSuccessSnackBar(l10n.copiedToClipboard);
                },
              ),
          ],
        ),
      ),
    );
  }
}
