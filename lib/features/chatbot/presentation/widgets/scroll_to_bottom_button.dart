import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/generated/l10n.dart';

class ScrollToBottomButton extends StatelessWidget {
  const ScrollToBottomButton({
    super.key,
    required this.isVisible,
    required this.onPressed,
    this.hasNewMessages = false,
  });

  final bool isVisible;
  final VoidCallback onPressed;
  final bool hasNewMessages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedAnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isVisible ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !isVisible,
        child: Material(
          elevation: 4,
          shadowColor: Colors.black26,
          borderRadius: BorderRadius.circular(20.r),
          color: theme.primaryColor,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(20.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_downward_rounded,
                    size: 16.r,
                    color: Colors.white,
                  ),
                  if (hasNewMessages) ...[
                    SizedBox(width: 6.w),
                    Text(
                      S.of(context).newMessages,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedAnimatedOpacity extends StatelessWidget {
  const AnimatedAnimatedOpacity({
    super.key,
    required this.duration,
    required this.opacity,
    required this.child,
  });

  final Duration duration;
  final double opacity;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: duration,
      opacity: opacity,
      child: AnimatedScale(
        duration: duration,
        scale: opacity == 1.0 ? 1.0 : 0.8,
        child: child,
      ),
    );
  }
}
