import 'package:MatchIn/core/cache/secure_storage_helper.dart';
import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/core/networking/dio_consumer.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/core/routing/cubit/main_navigation_cubit.dart';
import 'package:MatchIn/core/services/file_picker_service.dart';
import 'package:MatchIn/core/services/secure_storage_service.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/core/widgets/ads/rewarded_ad_manager.dart';
import 'package:MatchIn/features/auth/data/data_sources/auth_mock_remote_data_source_impl.dart';
import 'package:MatchIn/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:MatchIn/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:MatchIn/features/auth/domain/repositories/auth_repository.dart';
import 'package:MatchIn/features/auth/domain/use_cases/login_use_case.dart';
import 'package:MatchIn/features/auth/domain/use_cases/register_use_case.dart';
import 'package:MatchIn/features/auth/domain/use_cases/resend_otp_use_case.dart';
import 'package:MatchIn/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:MatchIn/features/auth/domain/use_cases/verify_otp_use_case.dart';
import 'package:MatchIn/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:MatchIn/features/auth/presentation/cubit/otp_cubit.dart';
import 'package:MatchIn/features/auth/presentation/cubit/reset_password_cubit.dart';
import 'package:MatchIn/features/chatbot/data/data_sources/chatbot_local_data_source.dart';
import 'package:MatchIn/features/chatbot/data/data_sources/chatbot_local_data_source_impl.dart';
import 'package:MatchIn/features/chatbot/data/data_sources/chatbot_mock_remote_data_source_impl.dart';
import 'package:MatchIn/features/chatbot/data/data_sources/chatbot_remote_data_source.dart';
import 'package:MatchIn/features/chatbot/data/repositories/chatbot_repository_impl.dart';
import 'package:MatchIn/features/chatbot/domain/repositories/chatbot_repository.dart';
import 'package:MatchIn/features/chatbot/domain/use_cases/clear_all_chats_use_case.dart';
import 'package:MatchIn/features/chatbot/domain/use_cases/delete_chat_use_case.dart';
import 'package:MatchIn/features/chatbot/domain/use_cases/get_chat_history_use_case.dart';
import 'package:MatchIn/features/chatbot/domain/use_cases/save_chat_use_case.dart';
import 'package:MatchIn/features/chatbot/domain/use_cases/send_message_use_case.dart';
import 'package:MatchIn/features/chatbot/presentation/cubit/chatbot_cubit.dart';
import 'package:MatchIn/features/home/data/data_sources/home_remote_data_source_impl.dart';
import 'package:MatchIn/features/home/data/data_sources/home_remote_data_source.dart';
import 'package:MatchIn/features/home/data/repositories/home_repository_impl.dart';
import 'package:MatchIn/features/home/domain/repositories/home_repository.dart';
import 'package:MatchIn/features/home/domain/use_cases/get_home_dashboard_use_case.dart';
import 'package:MatchIn/features/home/presentation/cubit/home_cubit.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source_impl.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_remote_data_source_impl.dart';
import 'package:MatchIn/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_user_profile_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/applications_local_data_source.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/applications_local_data_source_impl.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/applications_remote_data_source.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/applications_remote_data_source_impl.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/jobs_local_data_source.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/jobs_local_data_source_impl.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/jobs_remote_data_source.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/jobs_remote_data_source_impl.dart';
import 'package:MatchIn/features/jobsAndApplications/data/repositories/applications_repository_impl.dart';
import 'package:MatchIn/features/jobsAndApplications/data/repositories/jobs_repository_impl.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/repositories/applications_repository.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/repositories/jobs_repository.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/apply_for_job_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/apply_to_job_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/get_application_details_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/get_applications_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/get_cached_applications_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/get_cached_jobs_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/get_jobs_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/refresh_jobs_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/search_jobs_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/toggle_save_job_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/update_application_status_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/withdraw_application_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/application_details_cubit.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/applications_cubit.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/apply_to_job_cubit.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/cv_cubit.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_cubit.dart';
import 'package:MatchIn/features/profile/domain/use_cases/add_candidate_project_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/add_candidate_skill_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/delete_candidate_project_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_cached_candidate_profile_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_candidate_profile_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_candidate_projects_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_candidate_skills_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_career_preferences_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_project_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/remove_candidate_skill_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/save_career_preferences_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/search_skills_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/update_candidate_project_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/career_preferences_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/projects_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/skills_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/roadmap_cubit/roadmap_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/skill_task_cubit/skill_task_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/treasure_cubit/treasure_cubit.dart';
import 'package:MatchIn/features/saved/data/data_sources/saved_jobs_local_data_source.dart';
import 'package:MatchIn/features/saved/data/data_sources/saved_jobs_local_data_source_impl.dart';
import 'package:MatchIn/features/saved/data/data_sources/saved_jobs_remote_data_source.dart';
import 'package:MatchIn/features/saved/data/data_sources/saved_jobs_remote_data_source_impl.dart';
import 'package:MatchIn/features/saved/data/repositories/saved_jobs_repository_impl.dart';
import 'package:MatchIn/features/saved/domain/repositories/saved_jobs_repository.dart';
import 'package:MatchIn/features/saved/domain/use_cases/get_saved_jobs_use_case.dart';
import 'package:MatchIn/features/saved/domain/use_cases/save_job_use_case.dart';
import 'package:MatchIn/features/saved/domain/use_cases/unsave_job_use_case.dart';
import 'package:MatchIn/features/saved/presentation/cubit/saved_jobs_cubit.dart';
import 'package:MatchIn/features/settings/data/data_sources/settings_local_data_source.dart';
import 'package:MatchIn/features/settings/data/data_sources/settings_local_data_source_impl.dart';
import 'package:MatchIn/features/settings/data/data_sources/settings_remote_data_source.dart';
import 'package:MatchIn/features/settings/data/data_sources/settings_remote_data_source_impl.dart';
import 'package:MatchIn/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:MatchIn/features/settings/domain/repositories/settings_repository.dart';
import 'package:MatchIn/features/settings/domain/use_cases/change_password_use_case.dart';
import 'package:MatchIn/features/settings/domain/use_cases/get_language_use_case.dart';
import 'package:MatchIn/features/settings/domain/use_cases/get_notification_preference_use_case.dart';
import 'package:MatchIn/features/settings/domain/use_cases/get_theme_mode_use_case.dart';
import 'package:MatchIn/features/settings/domain/use_cases/logout_use_case.dart';
import 'package:MatchIn/features/settings/domain/use_cases/set_language_use_case.dart';
import 'package:MatchIn/features/settings/domain/use_cases/set_notification_preference_use_case.dart';
import 'package:MatchIn/features/settings/domain/use_cases/set_theme_mode_use_case.dart';
import 'package:MatchIn/features/settings/presentation/cubit/change_password_cubit.dart';
import 'package:MatchIn/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // =========================================================
  // Main Navigation
  // =========================================================

  getIt.registerLazySingleton<MainNavigationCubit>(() => MainNavigationCubit());

  // =========================================================
  // Auth Feature
  // =========================================================

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthMockRemoteDataSourceImpl(),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
  );

  getIt.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<VerifyOtpUseCase>(
    () => VerifyOtpUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<ResendOtpUseCase>(
    () => ResendOtpUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(repository: getIt()),
  );

  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(loginUseCase: getIt(), registerUseCase: getIt()),
  );

  getIt.registerFactory<OtpCubit>(
    () => OtpCubit(verifyOtpUseCase: getIt(), resendOtpUseCase: getIt()),
  );

  getIt.registerFactory<ResetPasswordCubit>(
    () => ResetPasswordCubit(resetPasswordUseCase: getIt()),
  );

  // =========================================================
  // Roadmap Feature
  // =========================================================

  getIt.registerLazySingleton<RewardedAdManager>(() => RewardedAdManager());

  getIt.registerFactory<RoadmapCubit>(
    () => RoadmapCubit(sharedPreferencesService: getIt()),
  );

  getIt.registerFactory<TreasureCubit>(
    () => TreasureCubit(sharedPreferencesService: getIt()),
  );

  getIt.registerFactory<SkillTaskCubit>(
    () => SkillTaskCubit(sharedPreferencesService: getIt()),
  );

  // =========================================================
  // Chatbot Feature
  // =========================================================

  getIt.registerLazySingleton<ChatbotRemoteDataSource>(
    () => ChatbotMockRemoteDataSourceImpl(),
  );

  getIt.registerLazySingleton<ChatbotLocalDataSource>(
    () => ChatbotLocalDataSourceImpl(sharedPreferencesHelper: getIt()),
  );

  getIt.registerLazySingleton<ChatbotRepository>(
    () => ChatbotRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );

  getIt.registerLazySingleton<GetChatHistoryUseCase>(
    () => GetChatHistoryUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<SendMessageUseCase>(
    () => SendMessageUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<SaveChatUseCase>(
    () => SaveChatUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<DeleteChatUseCase>(
    () => DeleteChatUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<ClearAllChatsUseCase>(
    () => ClearAllChatsUseCase(repository: getIt()),
  );

  getIt.registerFactory<ChatbotCubit>(
    () => ChatbotCubit(
      getChatHistoryUseCase: getIt(),
      sendMessageUseCase: getIt(),
      saveChatUseCase: getIt(),
      deleteChatUseCase: getIt(),
      clearAllChatsUseCase: getIt(),
    ),
  );

  // =========================================================
  // Jobs Feature
  // =========================================================

  getIt.registerLazySingleton<JobsLocalDataSource>(
    () => JobsLocalDataSourceImpl(sharedPreferencesHelper: getIt()),
  );

  getIt.registerLazySingleton<JobsRemoteDataSource>(
    () => JobsRemoteDataSourceImpl(apiConsumer: getIt()),
  );

  getIt.registerLazySingleton<JobsRepository>(
    () => JobsRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  getIt.registerLazySingleton<GetJobsUseCase>(
    () => GetJobsUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<SearchJobsUseCase>(
    () => SearchJobsUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<RefreshJobsUseCase>(
    () => RefreshJobsUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<GetCachedJobsUseCase>(
    () => GetCachedJobsUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<ToggleSaveJobUseCase>(
    () => ToggleSaveJobUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<ApplyForJobUseCase>(
    () => ApplyForJobUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<JobsFeedCubit>(
    () => JobsFeedCubit(
      getJobsUseCase: getIt(),
      searchJobsUseCase: getIt(),
      refreshJobsUseCase: getIt(),
      toggleSaveJobUseCase: getIt(),
      applyForJobUseCase: getIt(),
    ),
  );

  // =========================================================
  // Home Feature
  // =========================================================

  getIt.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(
      apiConsumer: getIt(),
      profileLocalDataSource: getIt(),
    ),
  );

  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: getIt()),
  );

  getIt.registerLazySingleton<GetHomeDashboardUseCase>(
    () => GetHomeDashboardUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<HomeCubit>(
    () => HomeCubit(getHomeDashboardUseCase: getIt()),
  );

  // =========================================================
  // Profile Feature
  // =========================================================

  getIt.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(sharedPreferencesHelper: getIt()),
  );

  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  getIt.registerLazySingleton<GetUserProfileUseCase>(
    () => GetUserProfileUseCase(getIt()),
  );

  // =========================================================
  // External
  // =========================================================

  final sharedPreferences = await SharedPreferences.getInstance();

  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // =========================================================
  // Core Storage Helpers
  // =========================================================

  getIt.registerLazySingleton<SharedPreferencesHelper>(
    () => SharedPreferencesHelper(preferences: getIt()),
  );

  getIt.registerLazySingleton<SecureStorageHelper>(() => SecureStorageHelper());

  // =========================================================
  // Core Services
  // =========================================================

  getIt.registerLazySingleton<SharedPreferencesService>(
    () => SharedPreferencesService(getIt()),
  );

  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(getIt()),
  );

  getIt.registerLazySingleton<FilePickerService>(() => FilePickerService());

  // =========================================================
  // Networking
  // =========================================================

  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  getIt.registerLazySingleton<Dio>(() => Dio());

  getIt.registerLazySingleton<ApiConsumer>(
    () => DioConsumer(
      dio: getIt(),
      secureStorageService: getIt(),
      sharedPreferencesService: getIt(),
    ),
  );

  // =========================================================
  // Applications Feature
  // =========================================================

  getIt.registerLazySingleton<ApplicationsLocalDataSource>(
    () => ApplicationsLocalDataSourceImpl(sharedPreferencesHelper: getIt()),
  );

  getIt.registerLazySingleton<ApplicationsRemoteDataSource>(
    () => ApplicationsRemoteDataSourceImpl(apiConsumer: getIt<ApiConsumer>()),
  );

  getIt.registerLazySingleton<ApplicationsRepository>(
    () => ApplicationsRepositoryImpl(
      remoteDataSource: getIt<ApplicationsRemoteDataSource>(),
      localDataSource: getIt<ApplicationsLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton<GetApplicationsUseCase>(
    () => GetApplicationsUseCase(repository: getIt<ApplicationsRepository>()),
  );

  getIt.registerLazySingleton<GetCachedApplicationsUseCase>(
    () => GetCachedApplicationsUseCase(
      repository: getIt<ApplicationsRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetApplicationDetailsUseCase>(
    () => GetApplicationDetailsUseCase(
      repository: getIt<ApplicationsRepository>(),
    ),
  );

  getIt.registerLazySingleton<ApplyToJobUseCase>(
    () => ApplyToJobUseCase(repository: getIt<ApplicationsRepository>()),
  );

  getIt.registerLazySingleton<UpdateApplicationStatusUseCase>(
    () => UpdateApplicationStatusUseCase(
      repository: getIt<ApplicationsRepository>(),
    ),
  );

  getIt.registerLazySingleton<WithdrawApplicationUseCase>(
    () =>
        WithdrawApplicationUseCase(repository: getIt<ApplicationsRepository>()),
  );

  getIt.registerFactory<CvCubit>(
    () => CvCubit(filePickerService: getIt<FilePickerService>()),
  );

  getIt.registerFactory<ApplicationsCubit>(
    () => ApplicationsCubit(
      getApplicationsUseCase: getIt<GetApplicationsUseCase>(),
      getCachedApplicationsUseCase: getIt<GetCachedApplicationsUseCase>(),
    ),
  );

  getIt.registerFactory<ApplicationDetailsCubit>(
    () => ApplicationDetailsCubit(
      getApplicationDetailsUseCase: getIt<GetApplicationDetailsUseCase>(),
      withdrawApplicationUseCase: getIt<WithdrawApplicationUseCase>(),
      updateApplicationStatusUseCase: getIt<UpdateApplicationStatusUseCase>(),
    ),
  );

  getIt.registerFactory<ApplyToJobCubit>(
    () => ApplyToJobCubit(applyToJobUseCase: getIt<ApplyToJobUseCase>()),
  );

  // =========================================================
  // Saved Jobs Feature
  // =========================================================

  getIt.registerLazySingleton<SavedJobsLocalDataSource>(
    () => SavedJobsLocalDataSourceImpl(sharedPreferencesHelper: getIt()),
  );

  getIt.registerLazySingleton<SavedJobsRemoteDataSource>(
    () => SavedJobsRemoteDataSourceImpl(apiConsumer: getIt<ApiConsumer>()),
  );

  getIt.registerLazySingleton<SavedJobsRepository>(
    () => SavedJobsRepositoryImpl(
      remoteDataSource: getIt<SavedJobsRemoteDataSource>(),
      localDataSource: getIt<SavedJobsLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton<GetSavedJobsUseCase>(
    () => GetSavedJobsUseCase(repository: getIt<SavedJobsRepository>()),
  );

  getIt.registerLazySingleton<SaveJobUseCase>(
    () => SaveJobUseCase(repository: getIt<SavedJobsRepository>()),
  );

  getIt.registerLazySingleton<UnsaveJobUseCase>(
    () => UnsaveJobUseCase(repository: getIt<SavedJobsRepository>()),
  );

  getIt.registerFactory<SavedJobsCubit>(
    () => SavedJobsCubit(
      getSavedJobsUseCase: getIt<GetSavedJobsUseCase>(),
      saveJobUseCase: getIt<SaveJobUseCase>(),
      unsaveJobUseCase: getIt<UnsaveJobUseCase>(),
    ),
  );

  // Profile Data Sources
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(apiConsumer: getIt()),
  );

  // Profile Use Cases and cubit
  getIt.registerLazySingleton<GetCandidateProfileUseCase>(
    () => GetCandidateProfileUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<GetCachedCandidateProfileUseCase>(
    () => GetCachedCandidateProfileUseCase(repository: getIt()),
  );

  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      getCandidateProfileUseCase: getIt(),
      getCachedCandidateProfileUseCase: getIt(),
    ),
  );

  // Skills use cases and cubit
  getIt.registerFactory<SkillsCubit>(
    () => SkillsCubit(
      getCandidateSkillsUseCase: getIt(),
      addCandidateSkillUseCase: getIt(),
      removeCandidateSkillUseCase: getIt(),
      searchSkillsUseCase: getIt(),
    ),
  );

  getIt.registerLazySingleton<GetCandidateSkillsUseCase>(
    () => GetCandidateSkillsUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<AddCandidateSkillUseCase>(
    () => AddCandidateSkillUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<RemoveCandidateSkillUseCase>(
    () => RemoveCandidateSkillUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<SearchSkillsUseCase>(
    () => SearchSkillsUseCase(repository: getIt()),
  );

  // Projects use cases and cubit

  getIt.registerFactory<ProjectsCubit>(
    () => ProjectsCubit(
      getProjectsUseCase: getIt(),
      addCandidateProjectUseCase: getIt(),
      updateCandidateProjectUseCase: getIt(),
      deleteCandidateProjectUseCase: getIt(),
      getProjectUseCase: getIt(),
    ),
  );
  getIt.registerLazySingleton<GetProjectsUseCase>(
    () => GetProjectsUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<GetProjectUseCase>(
    () => GetProjectUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<AddCandidateProjectUseCase>(
    () => AddCandidateProjectUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<UpdateCandidateProjectUseCase>(
    () => UpdateCandidateProjectUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<DeleteCandidateProjectUseCase>(
    () => DeleteCandidateProjectUseCase(repository: getIt()),
  );

  // career preferences
  getIt.registerFactory<CareerPreferencesCubit>(
    () => CareerPreferencesCubit(
      getCareerPreferencesUseCase: getIt(),
      saveCareerPreferencesUseCase: getIt(),
    ),
  );
  getIt.registerLazySingleton<GetCareerPreferencesUseCase>(
    () => GetCareerPreferencesUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<SaveCareerPreferencesUseCase>(
    () => SaveCareerPreferencesUseCase(repository: getIt()),
  );

  // =========================================================
  // Settings Feature
  // =========================================================

  getIt.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(
      sharedPreferencesService: getIt(),
      secureStorageService: getIt(),
      profileLocalDataSource: getIt(),
    ),
  );

  getIt.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSourceImpl(apiConsumer: getIt()),
  );

  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      localDataSource: getIt(),
      remoteDataSource: getIt(),
    ),
  );

  getIt.registerLazySingleton<GetNotificationPreferenceUseCase>(
    () => GetNotificationPreferenceUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<SetNotificationPreferenceUseCase>(
    () => SetNotificationPreferenceUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<GetLanguageUseCase>(
    () => GetLanguageUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<SetLanguageUseCase>(
    () => SetLanguageUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<GetThemeModeUseCase>(
    () => GetThemeModeUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<SetThemeModeUseCase>(
    () => SetThemeModeUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<ChangePasswordUseCase>(
    () => ChangePasswordUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<SettingsCubit>(
    () => SettingsCubit(
      getNotificationPreferenceUseCase: getIt(),
      setNotificationPreferenceUseCase: getIt(),
      getLanguageUseCase: getIt(),
      setLanguageUseCase: getIt(),
      getThemeModeUseCase: getIt(),
      setThemeModeUseCase: getIt(),
      logoutUseCase: getIt(),
    ),
  );

  getIt.registerFactory<ChangePasswordCubit>(
    () => ChangePasswordCubit(changePasswordUseCase: getIt()),
  );
}

