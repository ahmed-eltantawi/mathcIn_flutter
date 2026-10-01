import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/extensions/snack_bar_extensions.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/core/widgets/ads/rewarded_ad_manager.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/roadmap_cubit/roadmap_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RewardedAdCard extends StatefulWidget {
  const RewardedAdCard({super.key});

  @override
  State<RewardedAdCard> createState() =>
      _RewardedAdCardState();
}

class _RewardedAdCardState extends State<RewardedAdCard> {
  late final RewardedAdManager _rewardedAdManager;
  bool _isShowingAd = false;
  bool _hasEarnedReward = false;

  @override
  void initState() {
    super.initState();
    _rewardedAdManager = getIt<RewardedAdManager>();
    _rewardedAdManager.loadAd();
  }

  void _onWatchAdPressed() {
    if (_isShowingAd) return;

    if (!_rewardedAdManager.isAdReady) {
      context.showWarningSnackBar(
        context.l10n.adNotAvailable,
      );
      _rewardedAdManager.loadAd();
      setState(() {});
      return;
    }

    setState(() {
      _isShowingAd = true;
      _hasEarnedReward = false;
    });

    _rewardedAdManager.showAd(
      onUserEarnedReward: (reward) {
        if (!mounted) return;
        _hasEarnedReward = true;
        context.read<RoadmapCubit>().addRewardedAdXp(50);
        context.showSuccessSnackBar(
          context.l10n.adRewardSuccess,
        );
      },
      onAdClosed: () {
        if (!mounted) return;
        setState(() {
          _isShowingAd = false;
        });
        if (!_hasEarnedReward) {
          context.showWarningSnackBar(
            context.l10n.adDismissedNoReward,
          );
        }
        _hasEarnedReward = false;
      },
      onAdFailedToShow: (error) {
        if (!mounted) return;
        setState(() {
          _isShowingAd = false;
        });
        context.showErrorSnackBar(
          context.l10n.failedToLoadAd,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isReady = _rewardedAdManager.isAdReady;
    final bool isLoading =
        _rewardedAdManager.isLoading && !_isShowingAd;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: context.colors.primary.withValues(
            alpha: 0.3,
          ),
          width: 1.2.w,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(
              alpha: 0.06,
            ),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left 3D Icon & XP Badge
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colors.primary,
                  context.colors.primary.withValues(
                    alpha: 0.8,
                  ),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: context.colors.primary.withValues(
                    alpha: 0.3,
                  ),
                  blurRadius: 8.r,
                  offset: Offset(0, 3.h),
                ),
              ],
            ),
            child: Icon(
              Icons.play_circle_fill_rounded,
              color: Colors.white,
              size: 26.r,
            ),
          ),

          SizedBox(width: 12.w),

          // Title & XP Tag
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      context.l10n.watchAdEarnXp,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: context.colors.onSurface,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 2.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(
                      alpha: 0.15,
                    ),
                    borderRadius: BorderRadius.circular(
                      6.r,
                    ),
                  ),
                  child: Text(
                    context.l10n.plus50Xp,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),

          // Action Button (Watch Ad / Loading / Retry)
          Flexible(
            child: ElevatedButton(
              onPressed: (_isShowingAd || isLoading)
                  ? null
                  : _onWatchAdPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                elevation: 2,
                padding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 10.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                disabledBackgroundColor: context
                    .colors
                    .primary
                    .withValues(alpha: 0.4),
              ),
              child: _buildButtonContent(
                context,
                isReady: isReady,
                isLoading: isLoading,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonContent(
    BuildContext context, {
    required bool isReady,
    required bool isLoading,
  }) {
    if (_isShowingAd) {
      return SizedBox(
        width: 16.r,
        height: 16.r,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      );
    }

    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14.r,
            height: 14.r,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            context.l10n.loadingAd,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      isReady ? context.l10n.watchAd : context.l10n.watchAd,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
