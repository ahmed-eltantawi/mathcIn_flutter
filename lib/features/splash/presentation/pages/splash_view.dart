import 'package:MatchIn/features/splash/presentation/widgets/splash_view_body.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/core/utils/app_colors.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  void _goNext(BuildContext context) {
    final prefs = getIt<SharedPreferencesService>();
    if (!prefs.isOnBoardingViewed()) {
      context.go(AppRoutes.kOnboardingView);
    } else if (prefs.shouldSkipAuth()) {
      context.go(AppRoutes.kHomeView);
    } else {
      context.go(AppRoutes.kRegisterView);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SplashViewBody(
        onAnimationCompleted: () => _goNext(context),
      ),
    );
  }
}
