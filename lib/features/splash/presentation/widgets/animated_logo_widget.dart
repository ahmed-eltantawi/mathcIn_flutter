import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:MatchIn/core/utils/app_assets.dart';
import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/core/utils/app_constants.dart';
import 'package:MatchIn/core/utils/app_text_styles.dart';

class AnimatedLogoWidget extends StatefulWidget {
  const AnimatedLogoWidget({super.key, this.onAnimationCompleted});

  final VoidCallback? onAnimationCompleted;

  @override
  State<AnimatedLogoWidget> createState() => _AnimatedLogoWidgetState();
}

class _AnimatedLogoWidgetState extends State<AnimatedLogoWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _textOpacity;
  late final Animation<double> _lineProgress;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 0.86, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _textOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.75, curve: Curves.easeIn),
    );

    _lineProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.addStatusListener(_handleAnimationStatus);

    _controller.forward();
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onAnimationCompleted?.call();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 150.w,
            height: 150.w,
            child: FadeTransition(
              opacity: _logoOpacity,
              child: ScaleTransition(
                scale: _logoScale,
                child: Image.asset(
                  Assets.appIcon,
                  width: 150.w,
                  height: 150.w,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          FadeTransition(
            opacity: _textOpacity,
            child: Text(
              AppConstants.appName,
              style: AppTextStyles.semiBold20.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          AnimatedBuilder(
            animation: _lineProgress,
            builder: (context, child) {
              return SizedBox(
                width: 120.w,
                height: 4.h,
                child: Center(
                  child: SizedBox(
                    width: 120.w * _lineProgress.value,
                    height: 4.h,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
