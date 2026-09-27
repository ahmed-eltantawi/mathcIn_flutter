import 'package:MatchIn/features/splash/presentation/widgets/logo_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/core/utils/app_constants.dart';
import 'package:MatchIn/core/utils/app_text_styles.dart';

//gsi lpjh[i hrsl hg;,] h;jv
class AnimatedLogoWidget extends StatefulWidget {
  final VoidCallback? onAnimationCompleted;

  const AnimatedLogoWidget({super.key, this.onAnimationCompleted});

  @override
  State<AnimatedLogoWidget> createState() => _AnimatedLogoWidgetState();
}

class _AnimatedLogoWidgetState extends State<AnimatedLogoWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _lineAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.8, curve: Curves.easeIn),
      ),
    );

    _lineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeInOut),
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
            child: AnimatedBuilder(
              animation: _logoAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(150.w, 150.w),
                  painter: LogoPainter(progress: _logoAnimation.value),
                );
              },
            ),
          ),
          SizedBox(height: 16.h),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              AppConstants.appName,
              style: AppTextStyles.semiBold20.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          AnimatedBuilder(
            animation: _lineAnimation,
            builder: (context, child) {
              return SizedBox(
                width: 120.w,
                height: 4.h,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 120.w * _lineAnimation.value,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(2.r),
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
