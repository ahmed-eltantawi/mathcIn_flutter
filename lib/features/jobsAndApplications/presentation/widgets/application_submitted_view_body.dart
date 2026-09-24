import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/core/widgets/ads/interstitial_ad_manager.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/submitted_status_card.dart';
import 'package:MatchIn/generated/l10n.dart';

class ApplicationSubmittedViewBody extends StatefulWidget {
  const ApplicationSubmittedViewBody({super.key});

  @override
  State<ApplicationSubmittedViewBody> createState() =>
      _ApplicationSubmittedViewBodyState();
}

class _ApplicationSubmittedViewBodyState
    extends State<ApplicationSubmittedViewBody> {
  final _adManager = InterstitialAdManager();

  @override
  void initState() {
    super.initState();
    _adManager.loadAd();
  }

  @override
  void dispose() {
    _adManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.center,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Text(
                s.stepFourConfirmation,
                style: theme.textTheme.labelLarge?.copyWith(
                  letterSpacing: 1.5,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),

          const Spacer(),

          Container(
            width: 96.r,
            height: 96.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.forestGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.forestGreen.withValues(alpha: 0.25),
              ),
            ),
            child: Icon(
              Icons.check_rounded,
              size: 52.sp,
              color: AppColors.forestGreen,
            ),
          ),

          SizedBox(height: 28.h),

          Text(
            s.applicationSubmitted,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 12.h),

          Text.rich(
            TextSpan(
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              children: [
                TextSpan(text: '${s.yourApplicationFor} '),
                TextSpan(
                  text: s.juniorFlutterDeveloper,
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
                TextSpan(text: ' ${s.at} '),
                TextSpan(
                  text: 'TechNova',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
                TextSpan(text: ' ${s.submittedSuccessfully}'),
              ],
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 30.h),

          const SubmittedStatusCard(),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _adManager.showAd(
                  onAdClosed: () => _customNavigatorWithGoogleAd(
                    AppRoutes.ktrackingApplication,
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s.trackApplication),
                  SizedBox(width: 8.w),
                  const Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),

          SizedBox(height: 10.h),

          TextButton(
            onPressed: () => _customNavigatorWithGoogleAd(AppRoutes.kHomeView),
            child: Text(
              s.backToJobs,
              style: TextStyle(color: theme.colorScheme.secondary),
            ),
          ),

          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  void _customNavigatorWithGoogleAd(String route) {
    _adManager.showAd(
      onAdClosed: () {
        if (!mounted) {
          return;
        }
        context.push(route);
      },
    );
  }
}
