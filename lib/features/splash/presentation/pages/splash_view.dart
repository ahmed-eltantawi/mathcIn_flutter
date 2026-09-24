import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/features/splash/presentation/widgets/animated_logo_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    _startDelay();
  }

  void _startDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    context.go(AppRoutes.kOnboardingView);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const AnimatedLogoWidget(),
    );
  }
}
