abstract final class AppRoutes {
  AppRoutes._();

  // Splash & Onboarding
  static const String kSplashView = '/';
  static const String kOnboardingView = '/onboarding';

  // Authentication
  static const String kLoginView = '/login';
  static const String kRegisterView = '/register';
  static const String kForgetPasswordView = '/forgotPassword';
  static const String kOtpVerificationView = '/otp';
  static const String kCreateNewPasswordView = '/createNewPassword';
  static const String kPasswordChangedSuccessView = '/passwordChangedSuccess';

  // Main
  static const String kHomeView = '/home';

  // Jobs
  static const String kJobsSearchView = '/jobs/search';
  static const String kJobDetailsView = '/jobs/details';
  static const String knotifications = '/notifications';
  static const String ksettings = '/settings';

  // Applications
  static const String kapplyForRole = '/applications/apply';
  static const String kapplicationQuestions = '/applications/questions';
  static const String kreviewApplication = '/applications/review';
  static const String kapplicationSubmitted = '/applications/submitted';
  static const String ktrackingApplication = '/applications/tracking';

  // WebView
  static const String kWebView = '/webView';

  // Profile
  static const String keditSkillsView = '/profile/skills';
  static const String keditProjectsView = '/profile/projects';
  static const String keditcareerPrefView = '/profile/careerPref';

  static const String kChangePasswordView = '/changePassword';
}
