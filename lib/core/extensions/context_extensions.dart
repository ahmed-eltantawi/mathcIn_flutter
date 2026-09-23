import 'package:MatchIn/core/theme/app_semantic_colors.dart';
import 'package:flutter/material.dart';
import 'package:MatchIn/generated/l10n.dart';

/// Extension methods on [BuildContext] for easy access to theme, color scheme,
/// text theme, and localization resources.
extension BuildContextX on BuildContext {
  /// Returns the current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// Returns the current [ColorScheme].
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Returns semantic application colors.
  AppSemanticColors get semanticColors =>
      Theme.of(this).extension<AppSemanticColors>()!;

  /// Returns the current [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Returns localized strings via generated [S] class.
  S get l10n => S.of(this);
}
