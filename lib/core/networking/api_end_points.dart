///* EndPoints: the endpoints of the api
abstract class EndPoint {
  static const String baseUrl = 'https://iptvdemo.serv5group.com/api/';

  // --- Runtime-resolved API base URL. Firebase Firestore is the only
  // --- source of truth; there is intentionally no hardcoded fallback.
  // --- Empty means unresolved: it is assigned a validated URL by the
  // --- service locator at startup (valid cache) and by AppInitializer
  // --- on Firebase refreshes. Dio refuses to send requests while empty,
  // --- so no call ever goes to an obsolete backend. ---

  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String refreshToken = 'auth/refresh';
  static const String logout = 'auth/logout';

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

  // AI Mentor / Chatbot
  static const String mentorContextPreview = 'mentor/context-preview';
  static const String mentorConversations = 'mentor/conversations';
  static String mentorConversationDetails(dynamic conversationId) =>
      'mentor/conversations/$conversationId';
  static String mentorConversationMessages(dynamic conversationId) =>
      'mentor/conversations/$conversationId/messages';
  static const String savedJobs = 'saved-jobs';
  static const String jobs = 'jobs';
  static String jobDetails(dynamic jobPostId) => 'jobs/$jobPostId';

  static String saveJob(dynamic jobPostId) => 'jobs/$jobPostId/save';

  // Applications
  static const String applications = 'applications';
  static String applicationDetails(dynamic id) => 'applications/$id';
  static String updateApplicationStatus(dynamic id) =>
      'applications/$id/status';
  static String withdrawApplication(dynamic id) => 'applications/$id/withdraw';

  static String applicationNotes(dynamic id) => 'applications/$id/notes';
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

  // Candidate Educations
  static const String candidateEducations = 'candidate/educations';

  static String candidateEducation(int educationId) =>
      'candidate/educations/$educationId';

  // Candidate Experiences
  static const String candidateExperiences = 'candidate/experiences';

  static String candidateExperience(int experienceId) =>
      'candidate/experiences/$experienceId';

  // CV Upload
  static const String cvUpload = 'cv/upload';

  // CV extraction status, history, and retry (background parsing).
  static String cvStatus(int cvDocumentId) => 'cv/status/$cvDocumentId';

  static const String cvHistory = 'cv/history';

  static String cvRetry(int cvDocumentId) => 'cv/retry/$cvDocumentId';

  // CV extraction verification.
  static String cvVerifyExtraction(dynamic extractionId) =>
      'cv/extractions/$extractionId/verify';

  // CV binary preview/download (native format, inline disposition).
  static const String cvPreview = 'cv/preview';

  static String cvPreviewDocument(dynamic cvDocumentId) =>
      'cv/preview/$cvDocumentId';

  static const String cvFile = 'cv/file';

  static String cvFileDocument(dynamic cvDocumentId) => 'cv/file/$cvDocumentId';

  // Career Preferences
  static const String careerPreferences = 'candidate/career-preferences';

  // Roadmaps
  static const String roadmaps = 'roadmaps';

  static String roadmapDetails(int roadmapId) => 'roadmaps/$roadmapId';

  static String roadmapRefresh(int roadmapId) => 'roadmaps/$roadmapId/refresh';

  static String roadmapTaskComplete(int roadmapTaskId) =>
      'roadmap-tasks/$roadmapTaskId/complete';

  static const String roadmapXp = 'roadmaps/xp';

  static String roadmapDetailsXp(int roadmapId) => 'roadmaps/$roadmapId/xp';

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
  static const String role = 'role';
  static const String password = 'password';
  static const String passwordConfirmation = 'password_confirmation';
  static const String page = 'page';
  static const String perPage = 'per_page';
  static const String jobId = 'job_id';
  static const String jobPostId = 'job_post_id';
  static const String cvDocumentId = 'cv_document_id';
  static const String isSaved = 'is_saved';
  static const String search = 'search';
  // Skills taxonomy autocomplete uses `q` (live-verified: `search=` → 422).
  static const String skillsQuery = 'q';
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
  static const String reason = 'reason';
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
  static const String contextMode = 'context_mode';
  static const String suggestedActions = 'suggested_actions';
  static const String userMessage = 'user_message';
  static const String mentorReply = 'mentor_reply';
  static const String isArchived = 'is_archived';
}

///* ApiHeaderKey: the header keys of the api
abstract class ApiHeaderKey {
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
  static const String acceptLanguage = 'Accept-Language';
  static const String accept = 'Accept';
  static const String contentType = 'Content-Type';

  static String getAuthorizationValue({required String? accessToken}) =>
      '${ApiHeaderKey.bearer} $accessToken';
}
