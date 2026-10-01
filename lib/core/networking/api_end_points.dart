///* EndPoints: the endpoints of the api
abstract class EndPoint {
  //TODO: change these values
  static const String baseUrl = 'http://10.0.2.2:8000/api/';
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String refreshToken = 'auth/refresh-token';

  // Email Verification
  static const String verifyEmailOtp = 'auth/verify-email-otp';
  static const String resendEmailOtp = 'auth/resend-email-otp';

  // Password Recovery
  static const String forgotPassword = 'auth/forgot-password';
  static const String verifyPasswordResetOtp =
      'auth/forgot-password/verify-otp';
  static const String resetPassword = 'auth/reset-password';

  // Current User
  static const String currentUser = 'auth/me';

  static const String chatMessage = 'chatbot/chat';
  static const String savedJobs = 'saved-jobs';
  static const String jobs = 'jobs';
  static String saveJob(dynamic jobPostId) => 'jobs/$jobPostId/save';
}

///* ApiKeys: the keys of the api
abstract class ApiKey {
  //TODO: change these values
  static const String statusCode = 'statusCode';
  static const String errorMessage = 'message';
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String email = 'email';
  static const String otp = 'otp';
  static const String newPassword = 'new_password';
  static const String name = 'name';
  static const String password = 'password';
  static const String passwordConfirmation = 'password_confirmation';
  static const String page = 'page';
  static const String perPage = 'per_page';
  static const String jobId = 'job_id';
  static const String isSaved = 'is_saved';
  static const String search = 'search';
  static const String sort = 'sort';
  static const String companyId = 'company_id';
  static const String jobType = 'job_type';
  static const String workMode = 'work_mode';
  static const String employmentType = 'employment_type';
  static const String experienceLevel = 'experience_level';
  static const String country = 'country';
  static const String state = 'state';
  static const String city = 'city';
  static const String source = 'source';
  static const String applicationMethod = 'application_method';
  static const String isVerifiedCompany = 'is_verified_company';
  static const String requiredSkillIds = 'required_skill_ids[]';
  static const String preferredSkillIds = 'preferred_skill_ids[]';
  // static const String id = 'id';
}

///* ApiHeaderKey: the header keys of the api
abstract class ApiHeaderKey {
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer ';
  static const String acceptLanguage = 'Accept-Language';
  static const String accept = 'Accept';
  static const String contentType = 'Content-Type';

  static String getAuthorizationValue({required String? accessToken}) =>
      '${ApiHeaderKey.bearer} $accessToken';
}
