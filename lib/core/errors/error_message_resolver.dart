import 'package:flutter/material.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';

/// Centralized utility for resolving error messages to user-facing, localized strings.
/// Prevents raw English server fallbacks or technical exceptions from leaking to the UI
/// when the user's language is Arabic.
abstract final class ErrorMessageResolver {
  ErrorMessageResolver._();

  static final RegExp _arabicRegex = RegExp(r'[\u0600-\u06FF]');

  /// Resolves any technical, backend, or fallback message into a localized user-friendly string.
  static String resolve(BuildContext context, String? rawMessage) {
    if (rawMessage == null || rawMessage.trim().isEmpty) {
      return context.l10n.somethingWentWrong;
    }

    final trimmed = rawMessage.trim();

    // If message already contains Arabic, display it directly
    if (_arabicRegex.hasMatch(trimmed)) {
      return trimmed;
    }

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final lower = trimmed.toLowerCase();

    // 1. Offline / No internet connection
    if (lower.contains('offline') ||
        lower.contains('no internet') ||
        lower.contains('socketexception') ||
        lower.contains('network') ||
        lower.contains('connection error') ||
        lower.contains('failed host lookup')) {
      return context.l10n.noInternetConnection;
    }

    // 2. Timeout
    if (lower.contains('timeout') || lower.contains('timed out')) {
      return isArabic
          ? 'انتهت مهلة الاتصال بالخادم، يرجى المحاولة مرة أخرى'
          : 'Connection timed out. Please try again';
    }

    // 3. Request cancelled
    if (lower.contains('cancelled') || lower.contains('canceled')) {
      return isArabic ? 'تم إلغاء الطلب' : 'The request was cancelled';
    }

    // 4. Unauthorized / Session expired / 401
    if (lower.contains('unauthorized') ||
        lower.contains('unauthenticated') ||
        lower.contains('token expired') ||
        lower.contains('session expired')) {
      return isArabic
          ? 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً'
          : 'Session expired. Please log in again';
    }

    // 5. Forbidden / 403
    if (lower.contains('forbidden') || lower.contains('access denied')) {
      return isArabic
          ? 'ليس لديك صلاحية للقيام بهذا الإجراء'
          : 'You do not have permission to perform this action';
    }

    // 6. Not Found / 404
    if (lower.contains('not found') || lower.contains('404')) {
      return isArabic
          ? 'لم يتم العثور على البيانات المطلوبة'
          : 'The requested data was not found';
    }

    // 7. Validation / Invalid input / Bad request
    if (lower.contains('validation') ||
        lower.contains('invalid input') ||
        lower.contains('invalid credentials') ||
        lower.contains('bad request')) {
      return isArabic
          ? 'يرجى التحقق من صحة البيانات والمحاولة مجدداً'
          : 'Please check your input and try again';
    }

    // 8. Server error / 500 / Fallbacks
    if (lower.contains('server error') ||
        lower.contains('problem with the server') ||
        lower.contains('internal server') ||
        lower.contains('took too long to transform') ||
        lower.contains('exception') ||
        lower.contains('failed to get response')) {
      return isArabic
          ? 'حدث خطأ في الخادم، يرجى المحاولة لاحقاً'
          : 'There was a problem with the server';
    }

    // 9. Something went wrong
    if (lower.contains('something went wrong')) {
      return context.l10n.somethingWentWrong;
    }

    // If language is Arabic and it's an unlocalized English string
    if (isArabic) {
      return context.l10n.somethingWentWrong;
    }

    return trimmed;
  }
}
