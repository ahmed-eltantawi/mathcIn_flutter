import 'package:MatchIn/core/theme/app_semantic_colors.dart';
import 'package:flutter/material.dart';
import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/core/utils/app_text_styles.dart';

ThemeData getDarkTheme({bool isArabic = false}) {
  final textTheme = AppTextStyles.textTheme(
    isArabic: isArabic,
  );

  const colorScheme = ColorScheme.dark(
    primary: AppColors.midnightBlue,
    onPrimary: AppColors.white,
    secondary: AppColors.terracotta,
    onSecondary: AppColors.white,
    tertiary: AppColors.goldenMustard,
    onTertiary: AppColors.white,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkTextPrimary,
    surfaceContainerHighest: AppColors.darkSurfaceVariant,
    onSurfaceVariant: AppColors.darkTextSecondary,
    outline: AppColors.darkBorder,
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
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: themedTextTheme,

    extensions: const [
      AppSemanticColors(success: AppColors.forestGreen),
    ],

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkTextPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),

    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.darkBorder),
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.darkDivider,
      thickness: 1,
    ),

    iconTheme: const IconThemeData(
      color: AppColors.darkTextSecondary,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      hintStyle: const TextStyle(
        color: AppColors.darkTextSecondary,
      ),
      border: _darkInputBorder,
      enabledBorder: _darkInputBorder,
      focusedBorder: _darkInputBorder.copyWith(
        borderSide: const BorderSide(
          color: AppColors.terracotta,
          width: 1.5,
        ),
      ),
      errorBorder: _darkInputBorder.copyWith(
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

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.terracotta,
      ),
    ),

    progressIndicatorTheme:
        const ProgressIndicatorThemeData(
          color: AppColors.goldenMustard,
        ),
  );
}

final _darkInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(12),
  borderSide: const BorderSide(color: AppColors.darkBorder),
);
