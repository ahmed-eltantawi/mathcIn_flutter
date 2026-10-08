import 'package:MatchIn/core/routing/app_router.dart';
import 'package:MatchIn/core/routing/cubit/main_navigation_cubit.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/core/theme/app_theme.dart';
import 'package:MatchIn/features/home/presentation/cubit/home_cubit.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_cubit.dart';
import 'package:MatchIn/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:MatchIn/features/settings/presentation/cubit/settings_state.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MatchIn extends StatelessWidget {
  const MatchIn({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: getIt<SettingsCubit>()..loadSettings(),
        ),
        BlocProvider.value(
          value: getIt<JobsFeedCubit>()..getJobs(),
        ),
        BlocProvider.value(
          value: getIt<HomeCubit>()..getHomeDashboard(),
        ),
        BlocProvider.value(
          value: getIt<MainNavigationCubit>(),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          final locale = Locale(settingsState.languageCode);

          return ScreenUtilInit(
            designSize: const Size(390, 845),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                locale: locale,
                supportedLocales: S.delegate.supportedLocales,
                localizationsDelegates: const [
                  S.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                theme: AppTheme.light(locale: locale),
                darkTheme: AppTheme.dark(locale: locale),
                themeMode: settingsState.themeMode,
                routerConfig: AppRouter.router,
              );
            },
          );
        },
      ),
    );
  }
}
