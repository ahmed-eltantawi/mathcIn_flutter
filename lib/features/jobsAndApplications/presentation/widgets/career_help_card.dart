import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CareerHelpCard extends StatelessWidget {
  const CareerHelpCard({super.key, this.onAskChatBot});

  final VoidCallback? onAskChatBot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(9.r),
                border: Border.all(
                  color: theme.colorScheme.secondary
                      .withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                Icons.smart_toy_outlined,
                color: theme.colorScheme.secondary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    s.needHelpWithNextSteps,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    s.askCareerMentorDescription,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                  ),
                  SizedBox(height: 12.h),
                  ElevatedButton.icon(
                    onPressed: onAskChatBot ?? () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          theme.colorScheme.secondary,
                      minimumSize: Size(0, 44.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                      ),
                    ),
                    icon: const Icon(Icons.chat_outlined),
                    label: Text(s.askChatBot),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
