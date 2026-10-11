import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/features/splash/presentation/widgets/splash_view_body.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  void _handleNavigation(BuildContext context) {
    if (!context.mounted) return;

    final prefs = getIt<SharedPreferencesService>();
    final isOnboarded = prefs.isOnBoardingViewed();
    final isLoggedIn = prefs.isLoggedIn();

    if (!isOnboarded) {
      context.go(AppRoutes.kOnboardingView);
    } else if (isLoggedIn) {
      context.go(AppRoutes.kHomeView);
    } else {
      context.go(AppRoutes.kLoginView);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: SplashViewBody(
        onAnimationCompleted: () => _handleNavigation(context),
      ),
    );
  }
}
