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

  static const Color darkPrimary = Color(0xFF4C82E6);
  static const Color darkSecondary = Color(0xFFE27D60);
  static const Color darkSuccess = Color(0xFF4ADE80);
  static const Color darkError = Color(0xFFEF5350);

  static const Color darkBackground = Color(0xFF0F1216);
  static const Color darkSurface = Color(0xFF191F26);
  static const Color darkSurfaceVariant = Color(0xFF222933);
  static const Color darkInputFill = Color(0xFF13171C);

  static const Color darkTextPrimary = Color(0xFFF3F5F7);
  static const Color darkTextSecondary = Color(0xFF9AA4B2);
  static const Color darkTextHint = Color(0xFF667085);

  static const Color darkBorder = Color(0xFF2D3540);
  static const Color darkDivider = Color(0xFF262D37);

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
