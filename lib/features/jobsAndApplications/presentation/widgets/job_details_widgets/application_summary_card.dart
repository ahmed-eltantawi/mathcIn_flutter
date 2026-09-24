import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ApplicationSummaryCard extends StatelessWidget {
  const ApplicationSummaryCard({
    super.key,
    this.onViewApplication,
  });

  final VoidCallback? onViewApplication;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    s.alreadySubmitted,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                  Text(
                    '${s.application} #SM-2849',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onViewApplication ?? () {},
              style: ElevatedButton.styleFrom(
                minimumSize: Size(0, 44.h),
                padding: EdgeInsets.symmetric(
                  horizontal: 18.w,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s.viewApplication),
                  SizedBox(width: 5.w),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
