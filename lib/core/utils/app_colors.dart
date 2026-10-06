import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  // =========================================================
  // Brand Colors
  // =========================================================

  static const Color midnightBlue = Color(0xFF1F365C);
  static const Color terracotta = Color(0xFFD06B4F);
  static const Color goldenMustard = Color(0xFFD4A72C);

  // =========================================================
  // Semantic Status Colors
  // =========================================================

  static const Color forestGreen = Color(0xFF4F7A5A);
  static const Color amber = Color(0xFFC88A26);
  static const Color mutedRed = Color(0xFFB85450);

  // =========================================================
  // Light Palette
  // =========================================================

  static const Color lightBackground = Color(0xFFFAF8F4);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF4F1EC);

  static const Color lightTextPrimary = Color(0xFF222831);
  static const Color lightTextSecondary = Color(0xFF707780);
  static const Color lightBorder = Color(0xFFE5E1DA);

  // =========================================================
  // Dark Palette
  // =========================================================

  static const Color darkBackground = Color(0xFF111315);
  static const Color darkSurface = Color(0xFF1F242A);
  static const Color darkSurfaceVariant = Color(0xFF262B31);

  static const Color darkTextPrimary = Color(0xFFF4F2EF);
  static const Color darkTextSecondary = Color(0xFFA7ABB1);

  static const Color darkBorder = Color(0xFF363D45);
  static const Color darkDivider = Color(0xFF30363D);

  // =========================================================
  // Common
  // =========================================================

  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Colors.transparent;

  // =========================================================
  // Legacy UI Aliases
  // =========================================================

  // These aliases keep the existing presentation widgets compatible with the
  // current palette while they are migrated to theme-based colors.
  static const Color primary = midnightBlue;
  static const Color secondary = terracotta;
  static const Color accent = goldenMustard;
  static const Color success = forestGreen;
  static const Color successBackground = Color(0xFFEBF3ED);
  static const Color error = Color(0xFFD32F2F);

  static const Color background = lightBackground;
  static const Color surface = lightSurface;
  static const Color surfaceVariant = lightSurfaceVariant;
  static const Color greyBackground = lightSurfaceVariant;

  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color border = lightBorder;
  static const Color textHint = textSecondary;
}
