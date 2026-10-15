class ProfileFormValidator {
  const ProfileFormValidator._();

  /// Formats a picked date as `YYYY-MM-DD` for the backend.
  static String formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static DateTime? parseDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value.trim());
  }

  /// Extracts the `YYYY-MM-DD` calendar-date part from a backend date
  /// value for display. Accepts plain dates (`2000-01-01`) and full
  /// ISO-8601 datetimes (`2010-10-05T00:00:00.000000Z`), returning only
  /// the leading date part so no timezone shift can alter the calendar
  /// day. Returns `''` for null/empty input and the trimmed original
  /// for malformed values so unknown data keeps displaying verbatim.
  static String normalizeDateForDisplay(String? value) {
    if (value == null) return '';
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    final match = RegExp(r'^(\d{4}-\d{2}-\d{2})').firstMatch(trimmed);
    if (match == null) return trimmed;
    final candidate = match.group(1)!;
    final parts = candidate.split('-').map(int.tryParse).toList();
    final year = parts[0];
    final month = parts[1];
    final day = parts[2];
    if (year == null || month == null || day == null) return trimmed;
    if (month < 1 || month > 12 || day < 1 || day > 31) return trimmed;
    try {
      final date = DateTime(year, month, day);
      if (date.year != year || date.month != month || date.day != day) {
        return trimmed;
      }
    } catch (_) {
      return trimmed;
    }
    return candidate;
  }

  /// Parses a display-normalized `YYYY-MM-DD` value into a local-midnight
  /// [DateTime] for picker initialization, avoiding the timezone shift
  /// that parsing a full ISO-8601 instant can introduce.
  static DateTime? parseDisplayDate(String? value) {
    final normalized = normalizeDateForDisplay(value);
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(normalized)) return null;
    return DateTime.tryParse(normalized);
  }

  /// Returns [requiredMessage] when [value] is blank, otherwise null.
  static String? validateInstitution(
    String value, {
    required String requiredMessage,
  }) {
    if (value.trim().isEmpty) return requiredMessage;
    return null;
  }

  /// Returns [invalidMessage] when both dates are set and
  /// [end] is before [start], otherwise null.
  static String? validateDateRange({
    DateTime? start,
    DateTime? end,
    required String invalidMessage,
  }) {
    if (start == null || end == null) return null;
    if (end.isBefore(start)) return invalidMessage;
    return null;
  }
}
