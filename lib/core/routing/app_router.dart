import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/features/splash/presentation/pages/splash_view.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/core/widgets/app_web_view.dart';
import 'package:MatchIn/core/widgets/main_navigation_screen.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/views/application_questions_view.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/views/application_submitted_view.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/views/apply_for_role_view.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/views/review_application_view.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/views/tracking_application_view.dart';
import 'package:MatchIn/features/auth/presentation/cubit/otp_cubit.dart';
import 'package:MatchIn/features/auth/presentation/cubit/reset_password_cubit.dart';
import 'package:MatchIn/features/auth/presentation/pages/create_new_password_view.dart';
import 'package:MatchIn/features/auth/presentation/pages/login_view.dart';
import 'package:MatchIn/features/auth/presentation/pages/otp_verification_view.dart';
import 'package:MatchIn/features/auth/presentation/pages/password_changed_success_view.dart';
import 'package:MatchIn/features/auth/presentation/pages/register_view.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/views/job_details_view.dart';
import 'package:MatchIn/features/home/presentation/views/jobs_search_view.dart';
import 'package:MatchIn/features/home/presentation/views/notifications_view.dart';
import 'package:MatchIn/features/home/presentation/views/settings_view.dart';
import 'package:MatchIn/features/onbording/presentation/pages/onbording.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRouter {
  AppRouter._();

  static CustomTransitionPage<dynamic> _buildTransitionPage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.kSplashView,
    redirect: (context, state) {
      if (!getIt.isRegistered<SharedPreferencesService>()) {
        return null;
      }

      final prefs = getIt<SharedPreferencesService>();
      final isOnboarded = prefs.isOnBoardingViewed();
      final isLoggedIn = prefs.isLoggedIn();
      final location = state.uri.path;

      // Splash handles its own navigation via animation callback
      if (location == AppRoutes.kSplashView) return null;

      // Not onboarded → stay on onboarding if already there, else redirect
      if (!isOnboarded) {
        return location == AppRoutes.kOnboardingView
            ? null
            : AppRoutes.kOnboardingView;
      }

      // Onboarded but still on onboarding page → move forward
      if (location == AppRoutes.kOnboardingView) {
        return isLoggedIn ? AppRoutes.kHomeView : AppRoutes.kRegisterView;
      }

      return null;
    },
    routes: [
      // Splash / Root
      GoRoute(
        path: AppRoutes.kSplashView,
        pageBuilder: (context, state) {
          return _buildTransitionPage(state: state, child: const SplashView());
        },
      ),

      // Onboarding
      GoRoute(
        path: AppRoutes.kOnboardingView,
        pageBuilder: (context, state) {
          return _buildTransitionPage(state: state, child: const Onb1());
        },
      ),

      // Main Navigation
      GoRoute(
        path: AppRoutes.kHomeView,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: const MainNavigationScreen(),
          );
        },
      ),

      // WebView
      GoRoute(
        path: AppRoutes.kWebView,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};

          final url = args['url'] as String? ?? '';
          final title = args['title'] as String?;

          return _buildTransitionPage(
            state: state,
            child: AppWebView(url: url, title: title),
          );
        },
      ),

      // Jobs Search
      GoRoute(
        path: AppRoutes.kJobsSearchView,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: const JobsSearchView(),
          );
        },
      ),

      // Job Details
      GoRoute(
        path: AppRoutes.kJobDetailsView,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: const JobDetailsView(),
          );
        },
      ),

      // Notifications
      GoRoute(
        path: AppRoutes.knotifications,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: const NotificationsView(),
          );
        },
      ),

      // Settings
      GoRoute(
        path: AppRoutes.ksettings,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: const SettingsView(),
          );
        },
      ),

      // Register
      GoRoute(
        path: AppRoutes.kRegisterView,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: const RegisterView(),
          );
        },
      ),

      // Login
      GoRoute(
        path: AppRoutes.kLoginView,
        pageBuilder: (context, state) {
          return _buildTransitionPage(state: state, child: const LoginView());
        },
      ),

      // Forget Password
      GoRoute(
        path: AppRoutes.kForgetPasswordView,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: BlocProvider(
              create: (_) => getIt<OtpCubit>(),
              child: OtpVerificationView(
                email: state.extra as String? ?? 'user@example.com',
              ),
            ),
          );
        },
      ),

      // OTP
      GoRoute(
        path: AppRoutes.kOtpVerificationView,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: BlocProvider(
              create: (_) => getIt<OtpCubit>(),
              child: OtpVerificationView(
                email: state.extra as String? ?? 'user@example.com',
              ),
            ),
          );
        },
      ),

      // Create New Password
      GoRoute(
        path: AppRoutes.kCreateNewPasswordView,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: BlocProvider(
              create: (_) => getIt<ResetPasswordCubit>(),
              child: CreateNewPasswordView(
                email: state.extra as String? ?? 'user@example.com',
              ),
            ),
          );
        },
      ),

      // Password Changed Success
      GoRoute(
        path: AppRoutes.kPasswordChangedSuccessView,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: const PasswordChangedSuccessView(),
          );
        },
      ),

      // Apply For Role
      GoRoute(
        path: AppRoutes.kapplyForRole,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: const ApplyForRoleView(),
          );
        },
      ),

      // Application Questions
      GoRoute(
        path: AppRoutes.kapplicationQuestions,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: const ApplicationQuestionsView(),
          );
        },
      ),

      // Review Application
      GoRoute(
        path: AppRoutes.kreviewApplication,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: const ReviewApplicationView(),
          );
        },
      ),

      // Application Submitted
      GoRoute(
        path: AppRoutes.kapplicationSubmitted,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: const ApplicationSubmittedView(),
          );
        },
      ),

      // Tracking Application
      GoRoute(
        path: AppRoutes.ktrackingApplication,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: const TrackingApplicationView(),
          );
        },
      ),
    ],
  );
}
