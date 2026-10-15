class ExperienceTechnologiesParser {
  const ExperienceTechnologiesParser._();

  /// Converts a comma-separated related-skills input into a list.
  ///
  /// Trims whitespace, drops empty entries, preserves input order.
  /// Example: "Flutter, Dart, Firebase" → ["Flutter", "Dart", "Firebase"].
  static List<String> parse(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  /// Joins stored technologies for the Edit-mode text field.
  static String join(List<String> technologies) {
    return technologies.join(', ');
  }
}
