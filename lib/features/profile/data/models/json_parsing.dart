/// Tolerant primitives for backend JSON decoding in the Profile feature.
///
/// The API returns numeric IDs either as numbers or numeric strings and
/// boolean flags either as booleans or documented `0`/`1` variants.
/// Direct `as` casts throw on drift and — inside list parsing — silently
/// discard valid records, so every model decodes through these helpers.
/// Malformed values yield null and callers decide (skip the item, keep a
/// documented default); nothing is fabricated here.
class JsonParsing {
  const JsonParsing._();

  /// Parses numeric and numeric-string IDs (`10`, `"10"`).
  /// Returns null for anything else.
  static int? parseId(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  /// Parses booleans and documented `0`/`1` variants
  /// (`true`, `1`, `"1"`, `"true"` → true).
  /// Returns null for anything else, including missing values.
  static bool? parseBoolFlag(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return null;
  }

  /// Reads an optional string without throwing on type drift.
  static String? parseString(dynamic value) => value?.toString();

  /// Reads an optional string list; non-list values become empty
  /// so nullable arrays never corrupt their record.
  static List<String> parseStringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((item) => item.toString()).toList();
  }
}
