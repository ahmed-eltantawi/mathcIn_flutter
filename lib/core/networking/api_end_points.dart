///* EndPoints: the endpoints of the api
abstract class EndPoint {
  //TODO: change these values
  static const String baseUrl =
      'https://nuke-borough-shoppers-lodging.trycloudflare.com/api';
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

  // Applications
  static const String applications = 'applications';
  static String applicationDetails(dynamic id) => 'applications/$id';
  static String updateApplicationStatus(dynamic id) =>
      'applications/$id/status';
  static String withdrawApplication(dynamic id) => 'applications/$id/withdraw';

  // Candidate Profile
  static const String candidateProfile = 'candidate/profile';

  // Candidate Skills
  static const String candidateSkills = 'candidate/skills';

  static String candidateSkill(int candidateSkillId) =>
      'candidate/skills/$candidateSkillId';

  // Search Skills
  static const String searchSkills = 'skills/search';

  // Candidate Projects
  static const String candidateProjects = 'candidate/projects';

  static String candidateProject(int projectId) =>
      'candidate/projects/$projectId';

  // Career Preferences
  static const String careerPreferences = 'candidate/career-preferences';

  // Notifications
  static const String notifications = 'notifications';
  static const String notificationsUnreadCount = 'notifications/unread-count';
  static const String notificationsReadAll = 'notifications/read-all';
  static String markNotificationAsRead(dynamic id) => 'notifications/$id/read';
}

///* ApiKeys: the keys of the api
abstract class ApiKey {
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
  static const String coverLetter = 'cover_letter';
  static const String notes = 'notes';
  static const String status = 'status';
  static const String appliedAt = 'applied_at';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String attributes = 'attributes';
  static const String data = 'data';
  static const String type = 'type';
  static const String links = 'links';
  static const String meta = 'meta';
  static const String id = 'id';
  static const String isRead = 'is_read';
  static const String readAt = 'read_at';
  static const String title = 'title';
  static const String count = 'count';
  static const String updatedCount = 'updated_count';
  static const String unreadOnly = 'unread_only';
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
