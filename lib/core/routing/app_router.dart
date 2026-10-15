import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/features/profile/presentation/views/edit_career_preferences_view.dart';
import 'package:MatchIn/features/profile/presentation/views/edit_education_view.dart';
import 'package:MatchIn/features/profile/presentation/views/edit_experience_view.dart';
import 'package:MatchIn/features/profile/presentation/views/edit_profile_view.dart';
import 'package:MatchIn/features/profile/presentation/views/edit_projects_view.dart';
import 'package:MatchIn/features/profile/presentation/views/edit_skills_view.dart';
import 'package:MatchIn/features/splash/presentation/pages/splash_view.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/core/widgets/app_web_view.dart';
import 'package:MatchIn/core/widgets/main_navigation_screen.dart';
import 'package:MatchIn/features/chatbot/presentation/views/ai_chat_view.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
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
import 'package:MatchIn/features/settings/presentation/views/change_password_view.dart';
import 'package:MatchIn/features/settings/presentation/views/contact_us_view.dart';
import 'package:MatchIn/features/settings/presentation/views/follow_us_view.dart';
import 'package:MatchIn/features/settings/presentation/views/privacy_policy_view.dart';
import 'package:MatchIn/features/onbording/presentation/pages/onbording.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRouter {
  AppRouter._();

  // --- Extracts the job from route extras, accepting either a bare
  // --- JobEntity (legacy call sites) or {'job': JobEntity, ...}.
  static JobEntity _jobFromExtra(Object? extra) {
    if (extra is JobEntity) return extra;
    if (extra is Map<String, dynamic> && extra['job'] is JobEntity) {
      return extra['job'] as JobEntity;
    }
    throw ArgumentError('Route requires a JobEntity extra');
  }

  static String? _coverLetterFromExtra(Object? extra) {
    if (extra is Map<String, dynamic>) {
      final value = extra['coverLetter'];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  static String? _cvFileNameFromExtra(Object? extra) {
    if (extra is Map<String, dynamic>) {
      final value = extra['cvFileName'] ?? extra['cvName'];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  static String? _cvFileSizeFromExtra(Object? extra) {
    if (extra is Map<String, dynamic>) {
      final value = extra['cvFileSize'] ?? extra['cvSize'];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  static String _heroPrefixFromExtra(Object? extra) {
    if (extra is Map<String, dynamic>) {
      final value = extra['heroPrefix'];
      if (value is String && value.isNotEmpty) return value;
    }
    return 'feed';
  }

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
      final skipAuth = prefs.shouldSkipAuth();
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
        return skipAuth ? AppRoutes.kHomeView : AppRoutes.kRegisterView;
      }

      // Signed-in users never see register/login again. Guests keep
      // access so the guest-mode dialog can push Login/Register and
      // pop back to the previous screen afterwards.
      final isLoggedIn = prefs.isLoggedIn();
      if (location == AppRoutes.kRegisterView ||
          location == AppRoutes.kLoginView) {
        return isLoggedIn ? AppRoutes.kHomeView : null;
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
            child: const MainNavigationWidget(),
          );
        },
      ),

      // AI Chatbot
      GoRoute(
        path: AppRoutes.kChatBotView,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: const AiChatView(),
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
          final job = _jobFromExtra(state.extra);
          final heroPrefix = _heroPrefixFromExtra(state.extra);
          return _buildTransitionPage(
            state: state,
            child: JobDetailsView(job: job, heroPrefix: heroPrefix),
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

      // Change Password
      GoRoute(
        path: AppRoutes.kChangePasswordView,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: const ChangePasswordView(),
          );
        },
      ),

      // Privacy Policy
      GoRoute(
        path: AppRoutes.kPrivacyPolicyView,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: const PrivacyPolicyView(),
          );
        },
      ),

      // Contact Us
      GoRoute(
        path: AppRoutes.kContactUsView,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: const ContactUsView(),
          );
        },
      ),

      // Follow Us
      GoRoute(
        path: AppRoutes.kFollowUsView,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: const FollowUsView(),
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

      // Forget Password OTP — after confirming reset OTP, go to Create New Password
      GoRoute(
        path: AppRoutes.kForgetPasswordView,
        pageBuilder: (context, state) {
          final extra = state.extra;
          final email = extra is Map<String, dynamic>
              ? extra['email'] as String? ?? 'user@example.com'
              : extra is String
              ? extra
              : 'user@example.com';
          return _buildTransitionPage(
            state: state,
            child: BlocProvider(
              create: (_) => getIt<OtpCubit>(),
              child: OtpVerificationView(
                email: email,
                mode: OtpMode.passwordReset,
              ),
            ),
          );
        },
      ),

      // OTP — email verification after registration → navigates to Home
      GoRoute(
        path: AppRoutes.kOtpVerificationView,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: BlocProvider(
              create: (_) => getIt<OtpCubit>(),
              child: OtpVerificationView(
                email: state.extra as String? ?? 'user@example.com',
                mode: OtpMode.emailVerification,
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
          final job = _jobFromExtra(state.extra);
          return _buildTransitionPage(
            state: state,
            child: ApplyForRoleView(job: job),
          );
        },
      ),

      // Application Questions
      GoRoute(
        path: AppRoutes.kapplicationQuestions,
        pageBuilder: (context, state) {
          final job = _jobFromExtra(state.extra);
          return _buildTransitionPage(
            state: state,
            child: ApplicationQuestionsView(job: job),
          );
        },
      ),

      // Review Application
      GoRoute(
        path: AppRoutes.kreviewApplication,
        pageBuilder: (context, state) {
          final job = _jobFromExtra(state.extra);
          return _buildTransitionPage(
            state: state,
            child: ReviewApplicationView(
              job: job,
              coverLetter: _coverLetterFromExtra(state.extra),
              cvFileName: _cvFileNameFromExtra(state.extra),
              cvFileSize: _cvFileSizeFromExtra(state.extra),
            ),
          );
        },
      ),

      // Application Submitted
      GoRoute(
        path: AppRoutes.kapplicationSubmitted,
        pageBuilder: (context, state) {
          final job = _jobFromExtra(state.extra);
          return _buildTransitionPage(
            state: state,
            child: ApplicationSubmittedView(job: job),
          );
        },
      ),

      // Tracking Application
      GoRoute(
        path: AppRoutes.ktrackingApplication,
        pageBuilder: (context, state) {
          final job = _jobFromExtra(state.extra);
          return _buildTransitionPage(
            state: state,
            child: TrackingApplicationView(job: job),
          );
        },
      ),

      // Edit Skills View
      GoRoute(
        path: AppRoutes.keditSkillsView,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: const EditSkillsView(),
          );
        },
      ),

      // Edit Projects View
      GoRoute(
        path: AppRoutes.keditProjectsView,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: const EditProjectsView(),
          );
        },
      ),

      // Edit Career Preferences View
      GoRoute(
        path: AppRoutes.keditcareerPrefView,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: const EditCareerPreferencesView(),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.keditProfileView,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: const EditProfileView(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.keditEducationView,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: const EditEducationView(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.keditExperience,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: const EditExperienceView(),
          );
        },
      ),
    ],
  );
}
