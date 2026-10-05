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
import 'package:MatchIn/features/home/data/data_sources/home_mock_remote_data_source_impl.dart';
import 'package:MatchIn/features/home/data/data_sources/home_remote_data_source.dart';
import 'package:MatchIn/features/home/data/data_sources/repositories/home_repository_impl.dart';
import 'package:MatchIn/features/home/domain/repositories/home_repository.dart';
import 'package:MatchIn/features/home/domain/use_cases/get_home_dashboard_use_case.dart';
import 'package:MatchIn/features/home/presentation/cubit/home_cubit.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/jobs_local_data_source.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/jobs_local_data_source_impl.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/jobs_remote_data_source.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/jobs_remote_data_source_impl.dart';
import 'package:MatchIn/features/jobsAndApplications/data/repositories/jobs_repository_impl.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/repositories/jobs_repository.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/apply_for_job_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/get_cached_jobs_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/get_jobs_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/toggle_save_job_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/cv_cubit.dart';
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
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_cubit.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source_impl.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_remote_data_source_impl.dart';
import 'package:MatchIn/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:MatchIn/features/profile/domain/use_cases/add_candidate_project_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/add_candidate_skill_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/delete_candidate_project_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_cached_candidate_profile_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_candidate_profile_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_candidate_projects_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_candidate_skills_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_project_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/remove_candidate_skill_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/search_skills_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/update_candidate_project_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/projects_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/skills_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/roadmap_cubit/roadmap_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/skill_task_cubit/skill_task_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/treasure_cubit/treasure_cubit.dart';
import 'package:MatchIn/features/saved/data/data_sources/saved_jobs_remote_data_source.dart';
import 'package:MatchIn/features/saved/data/data_sources/saved_jobs_remote_data_source_impl.dart';
import 'package:MatchIn/features/saved/data/repositories/saved_jobs_repository_impl.dart';
import 'package:MatchIn/features/saved/domain/repositories/saved_jobs_repository.dart';
import 'package:MatchIn/features/saved/domain/use_cases/get_saved_jobs_use_case.dart';
import 'package:MatchIn/features/saved/domain/use_cases/save_job_use_case.dart';
import 'package:MatchIn/features/saved/domain/use_cases/unsave_job_use_case.dart';
import 'package:MatchIn/features/saved/presentation/cubit/saved_jobs_cubit.dart';
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
    // () => AuthRemoteDataSourceImpl(apiConsumer: getIt()),
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
    // () => ChatbotRemoteDataSourceImpl(apiConsumer: getIt()),
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
      getCachedJobsUseCase: getIt(),
      toggleSaveJobUseCase: getIt(),
      applyForJobUseCase: getIt(),
    ),
  );

  // =========================================================
  // Home Feature
  // =========================================================

  getIt.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeMockRemoteDataSourceImpl(),
    // () => HomeRemoteDataSourceImpl(apiConsumer: getIt()),
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

  getIt.registerFactory<CvCubit>(
    () => CvCubit(filePickerService: getIt<FilePickerService>()),
  );

  // =========================================================
  // Saved Jobs Feature
  // =========================================================

  getIt.registerLazySingleton<SavedJobsRemoteDataSource>(
    () => SavedJobsRemoteDataSourceImpl(apiConsumer: getIt<ApiConsumer>()),
  );

  getIt.registerLazySingleton<SavedJobsRepository>(
    () => SavedJobsRepositoryImpl(
      remoteDataSource: getIt<SavedJobsRemoteDataSource>(),
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

  getIt.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(sharedPreferencesHelper: getIt()),
  );

  // Profile Repository
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
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
}
