import 'package:MatchIn/features/splash/presentation/widgets/splash_view-body.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/utils/app_colors.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SplashViewBody(
        onAnimationCompleted: () {
          context.go(AppRoutes.kOnboardingView);
        },
      ),
    );
  }
}
