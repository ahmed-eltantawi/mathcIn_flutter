import 'package:flutter/material.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';

extension DateTimeExtensions on DateTime {
  /// يحول التاريخ لصيغة نسبية مقروءة زي:
  /// "Just now" / "5m ago" / "3h ago" / "2d ago" / "3w ago" / "2mo ago" / "1y ago"
  /// أو بالعربي حسب لغة التطبيق الحالية
  String timeAgo(BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(this);
    final l10n = context.l10n;

    // لو التاريخ في المستقبل (بسبب فروق توقيت مثلاً) نتعامل معه كـ "الآن"
    if (difference.isNegative) {
      return l10n.justNow;
    }

    if (difference.inSeconds < 60) {
      return l10n.justNow;
    }

    if (difference.inMinutes < 60) {
      return l10n.minutesAgo(difference.inMinutes);
    }

    if (difference.inHours < 24) {
      return l10n.hoursAgo(difference.inHours);
    }

    if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    }

    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return l10n.weeksAgo(weeks);
    }

    if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return l10n.monthsAgo(months);
    }

    final years = (difference.inDays / 365).floor();
    return l10n.yearsAgo(years);
  }

  /// صيغة تاريخ مبسطة ثابتة (مش نسبية) — مفيدة لو محتاج تاريخ دقيق في مكان تاني
  /// مثال: 20/05/2025
  String toFormattedDate() {
    final day = this.day.toString().padLeft(2, '0');
    final month = this.month.toString().padLeft(2, '0');
    return '$day/$month/$year';
  }
}
