import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class AppTextStyles {
  static const String _arabicFont = 'Alexandria';
  static const String _latinFont = 'DMSans';

  static String _font(bool isArabic) => isArabic ? _arabicFont : _latinFont;

  // ── Legacy static styles (kept for backward compat) ──────────────────────
  static TextStyle semiBold20 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 20.sp,
    color: AppColors.primary,
  );

  static TextStyle regular14 = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14.sp,
    color: AppColors.textSecondary,
  );

  // ── Heading styles ────────────────────────────────────────────────────────

  static TextStyle heading24Bold({required bool isArabic, Color? color}) =>
      TextStyle(
        fontFamily: _font(isArabic),
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle heading18Bold({required bool isArabic, Color? color}) =>
      TextStyle(
        fontFamily: _font(isArabic),
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textPrimary,
      );

  // ── Body styles ───────────────────────────────────────────────────────────

  static TextStyle body14Bold({required bool isArabic, Color? color}) =>
      TextStyle(
        fontFamily: _font(isArabic),
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle body14SemiBold({required bool isArabic, Color? color}) =>
      TextStyle(
        fontFamily: _font(isArabic),
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle body14Regular({required bool isArabic, Color? color}) =>
      TextStyle(
        fontFamily: _font(isArabic),
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle body12SemiBold({required bool isArabic, Color? color}) =>
      TextStyle(
        fontFamily: _font(isArabic),
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle body12Regular({required bool isArabic, Color? color}) =>
      TextStyle(
        fontFamily: _font(isArabic),
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.textPrimary,
      );

  // ── TextTheme builder ─────────────────────────────────────────────────────

  static TextTheme textTheme({bool isArabic = false}) {
    final font = _font(isArabic);
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: font,
        fontSize: 57.sp,
        fontWeight: FontWeight.w400,
      ),
      displayMedium: TextStyle(
        fontFamily: font,
        fontSize: 45.sp,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: TextStyle(
        fontFamily: font,
        fontSize: 36.sp,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: TextStyle(
        fontFamily: font,
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        fontFamily: font,
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: TextStyle(
        fontFamily: font,
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        fontFamily: font,
        fontSize: 22.sp,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        fontFamily: font,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        fontFamily: font,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        fontFamily: font,
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        fontFamily: font,
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        fontFamily: font,
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        fontFamily: font,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        fontFamily: font,
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        fontFamily: font,
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
