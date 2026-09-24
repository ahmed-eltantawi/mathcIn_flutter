import 'package:MatchIn/core/routing/app_router.dart';
import 'package:MatchIn/core/theme/dark_theme.dart';
import 'package:MatchIn/core/theme/light_theme.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class MatchIn extends StatelessWidget {
  const MatchIn({super.key});

  @override
  Widget build(BuildContext context) {
    const locale = Locale('en');
    final isArabic = locale.languageCode == 'ar';

    return ScreenUtilInit(
      designSize: const Size(390, 845),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,

          // Localization
          locale: locale,
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // Theme
          theme: getLightTheme(isArabic: isArabic),
          darkTheme: getDarkTheme(isArabic: isArabic),
          themeMode: ThemeMode.light,

          // Router
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
