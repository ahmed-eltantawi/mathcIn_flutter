import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/home/presentation/widgets/home_view_widgets/view_matches_card_header.dart';
import 'package:MatchIn/features/home/presentation/widgets/home_view_widgets/view_matches_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeCardViewMatchesJobs extends StatelessWidget {
  const HomeCardViewMatchesJobs({
    super.key,
    required this.matchesCount,
  });

  final int matchesCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 16.w,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: context.theme.dividerColor.withAlpha(50),
          ),
        ),
        child: Column(
          children: [
            // Top midnightBlue line
            Container(
              height: 4.h,
              width: 350.w,
              decoration: BoxDecoration(
                color: context.colors.primary,
                borderRadius: BorderRadiusDirectional.only(
                  topStart: Radius.circular(16.r),
                  topEnd: Radius.circular(16.r),
                ),
              ),
            ),

            // Card content
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // View Matches header
                  ViewMatchesCardHeader(
                    matchesCount: matchesCount,
                  ),

                  SizedBox(height: 14.h),

                  Text(
                    context.l10n.jobsMatchYourProfile,
                    style: context.textTheme.titleMedium,
                  ),

                  SizedBox(height: 6.h),

                  Text(
                    context.l10n.jobsMatchDescription,
                    style: context.textTheme.bodySmall
                        ?.copyWith(
                          color: context.colors.onSurface
                              .withValues(alpha: 0.60),
                        ),
                  ),

                  SizedBox(height: 18.h),

                  // View Matches button
                  const ViewMatchesButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
