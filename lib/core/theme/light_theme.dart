import 'package:MatchIn/core/theme/app_semantic_colors.dart';
import 'package:flutter/material.dart';
import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/core/utils/app_text_styles.dart';

ThemeData getLightTheme({bool isArabic = false}) {
  final textTheme = AppTextStyles.textTheme(
    isArabic: isArabic,
  );

  const colorScheme = ColorScheme.light(
    primary: AppColors.midnightBlue,
    onPrimary: AppColors.white,
    secondary: AppColors.terracotta,
    onSecondary: AppColors.white,
    tertiary: AppColors.goldenMustard,
    onTertiary: AppColors.midnightBlue,
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightTextPrimary,
    surfaceContainerHighest: AppColors.lightSurfaceVariant,
    onSurfaceVariant: AppColors.lightTextSecondary,
    outline: AppColors.lightBorder,
    error: AppColors.mutedRed,
    onError: AppColors.white,
  );

  final themedTextTheme = textTheme.copyWith(
    titleSmall: textTheme.titleSmall?.copyWith(
      color: colorScheme.onSurface.withValues(alpha: 0.6),
    ),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.lightBackground,
    textTheme: themedTextTheme,

    extensions: const [
      AppSemanticColors(success: AppColors.forestGreen),
    ],

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.lightTextPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),

    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          color: AppColors.lightBorder,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.lightBorder,
      thickness: 1,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface,
      hintStyle: const TextStyle(
        color: AppColors.lightTextSecondary,
      ),
      border: _lightInputBorder,
      enabledBorder: _lightInputBorder,
      focusedBorder: _lightInputBorder.copyWith(
        borderSide: const BorderSide(
          color: AppColors.midnightBlue,
          width: 1.5,
        ),
      ),
      errorBorder: _lightInputBorder.copyWith(
        borderSide: const BorderSide(
          color: AppColors.mutedRed,
        ),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.midnightBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    progressIndicatorTheme:
        const ProgressIndicatorThemeData(
          color: AppColors.midnightBlue,
        ),
  );
}

final _lightInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(12),
  borderSide: const BorderSide(
    color: AppColors.lightBorder,
  ),
);
