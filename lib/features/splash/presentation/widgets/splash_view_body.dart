import 'package:MatchIn/features/splash/presentation/widgets/animated_logo_widget.dart';
import 'package:flutter/material.dart';

class SplashViewBody extends StatelessWidget {
  const SplashViewBody({super.key, required this.onAnimationCompleted});

  final VoidCallback onAnimationCompleted;

  @override
  Widget build(BuildContext context) {
    return AnimatedLogoWidget(onAnimationCompleted: onAnimationCompleted);
  }
}
