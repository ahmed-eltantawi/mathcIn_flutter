import 'package:flutter/material.dart';

import 'package:MatchIn/features/splash/presentation/widgets/animated_logo_widget.dart';

class SplashViewBody extends StatelessWidget {
  final VoidCallback onAnimationCompleted;

  const SplashViewBody({super.key, required this.onAnimationCompleted});

  @override
  Widget build(BuildContext context) {
    return AnimatedLogoWidget(onAnimationCompleted: onAnimationCompleted);
  }
}
