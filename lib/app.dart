import 'package:MatchIn/core/routing/app_router.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/core/theme/dark_theme.dart';
import 'package:MatchIn/core/theme/light_theme.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_cubit.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MatchIn extends StatelessWidget {
  const MatchIn({super.key});

  @override
  Widget build(BuildContext context) {
    const locale = Locale('en');
    final isArabic = locale.languageCode == 'ar';

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: getIt<JobsCubit>()..getJobs(),
        ),
        // أي Cubit مشترك تاني هيتضاف هنا مستقبلاً
      ],
      child: ScreenUtilInit(
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
            theme: getLightTheme(isArabic: isArabic),
            darkTheme: getDarkTheme(isArabic: isArabic),
            themeMode: ThemeMode.system,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
