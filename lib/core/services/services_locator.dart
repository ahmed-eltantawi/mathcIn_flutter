import 'package:MatchIn/core/cache/secure_storage_helper.dart';
import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/core/networking/dio_consumer.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/core/routing/cubit/main_navigation_cubit.dart';
import 'package:MatchIn/core/services/file_picker_service.dart';
import 'package:MatchIn/core/services/secure_storage_service.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/features/home/data/data_sources/home_mock_remote_data_source_impl.dart';
import 'package:MatchIn/features/home/data/data_sources/home_remote_data_source.dart';
import 'package:MatchIn/features/home/data/data_sources/repositories/home_repository_impl.dart';
import 'package:MatchIn/features/home/domain/repositories/home_repository.dart';
import 'package:MatchIn/features/home/domain/use_cases/get_home_dashboard_use_case.dart';
import 'package:MatchIn/features/home/presentation/cubit/home_cubit.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/jobs_mock_remote_data_source_impl.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/jobs_remote_data_source.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/repositories/jobs_repository_impl.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/repositories/jobs_repository.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/apply_for_job_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/get_jobs_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/toggle_save_job_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/cv_cubit.dart';
import 'package:MatchIn/features/auth/data/data_sources/auth_mock_remote_data_source_impl.dart';
import 'package:MatchIn/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:MatchIn/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:MatchIn/features/auth/domain/repositories/auth_repository.dart';
import 'package:MatchIn/features/auth/domain/use_cases/resend_otp_use_case.dart';
import 'package:MatchIn/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:MatchIn/features/auth/domain/use_cases/verify_otp_use_case.dart';
import 'package:MatchIn/features/auth/presentation/cubit/otp_cubit.dart';
import 'package:MatchIn/features/auth/presentation/cubit/reset_password_cubit.dart';
import 'package:MatchIn/features/chatbot/data/data_sources/chatbot_local_data_source.dart';
import 'package:MatchIn/features/chatbot/data/data_sources/chatbot_local_data_source_impl.dart';
import 'package:MatchIn/features/chatbot/data/data_sources/chatbot_mock_remote_data_source_impl.dart';
import 'package:MatchIn/features/chatbot/data/data_sources/chatbot_remote_data_source.dart';
// ignore: unused_import
import 'package:MatchIn/features/chatbot/data/data_sources/chatbot_remote_data_source_impl.dart';
import 'package:MatchIn/features/chatbot/data/repositories/chatbot_repository_impl.dart';
import 'package:MatchIn/features/chatbot/domain/repositories/chatbot_repository.dart';
import 'package:MatchIn/features/chatbot/domain/use_cases/clear_all_chats_use_case.dart';
import 'package:MatchIn/features/chatbot/domain/use_cases/delete_chat_use_case.dart';
import 'package:MatchIn/features/chatbot/domain/use_cases/get_chat_history_use_case.dart';
import 'package:MatchIn/features/chatbot/domain/use_cases/save_chat_use_case.dart';
import 'package:MatchIn/features/chatbot/domain/use_cases/send_message_use_case.dart';
import 'package:MatchIn/features/chatbot/presentation/cubit/chatbot_cubit.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/roadmap_cubit/roadmap_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/skill_task_cubit/skill_task_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/treasure_cubit/treasure_cubit.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // =========================================================
  // Main Navigation
  // =========================================================

  getIt.registerLazySingleton<MainNavigationCubit>(
    () => MainNavigationCubit(),
  );

  // =========================================================
  // Auth Feature
  // =========================================================

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthMockRemoteDataSourceImpl(),
    // () => AuthRemoteDataSourceImpl(apiConsumer: getIt()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
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

  getIt.registerFactory<OtpCubit>(
    () => OtpCubit(
      verifyOtpUseCase: getIt(),
      resendOtpUseCase: getIt(),
    ),
  );

  getIt.registerFactory<ResetPasswordCubit>(
    () => ResetPasswordCubit(resetPasswordUseCase: getIt()),
  );

  // =========================================================
  // Roadmap Feature
  // =========================================================

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
    () => ChatbotLocalDataSourceImpl(
      sharedPreferencesHelper: getIt(),
    ),
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

  getIt.registerLazySingleton<JobsRemoteDataSource>(
    () => JobsMockRemoteDataSourceImpl(),
    // () => JobsRemoteDataSourceImpl(apiConsumer: getIt()),
  );

  getIt.registerLazySingleton<JobsRepository>(
    () => JobsRepositoryImpl(remoteDataSource: getIt()),
  );

  getIt.registerLazySingleton<GetJobsUseCase>(
    () => GetJobsUseCase(repository: getIt()),
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

  final sharedPreferences =
      await SharedPreferences.getInstance();

  getIt.registerLazySingleton<SharedPreferences>(
    () => sharedPreferences,
  );

  // =========================================================
  // Core Storage Helpers
  // =========================================================

  getIt.registerLazySingleton<SharedPreferencesHelper>(
    () => SharedPreferencesHelper(preferences: getIt()),
  );

  getIt.registerLazySingleton<SecureStorageHelper>(
    () => SecureStorageHelper(),
  );

  // =========================================================
  // Core Services
  // =========================================================

  getIt.registerLazySingleton<SharedPreferencesService>(
    () => SharedPreferencesService(getIt()),
  );

  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(getIt()),
  );

  getIt.registerLazySingleton<FilePickerService>(
    () => FilePickerService(),
  );

  // =========================================================
  // Networking
  // =========================================================

  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(),
  );

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
    () => CvCubit(
      filePickerService: getIt<FilePickerService>(),
    ),
  );
}
