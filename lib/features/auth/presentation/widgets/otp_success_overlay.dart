import 'package:MatchIn/core/utils/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class OtpSuccessOverlay extends StatelessWidget {
  const OtpSuccessOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      alignment: Alignment.center,
      child: Container(
        width: 160.w,
        height: 160.w,
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Lottie.asset(
          Assets.lottieCorrect,
          repeat: false,
        ),
      ),
    );
  }
}
