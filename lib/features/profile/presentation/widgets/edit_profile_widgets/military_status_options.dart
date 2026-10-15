import 'package:MatchIn/generated/l10n.dart';

/// Fixed Military Status options for the Edit Profile dropdown.
///
/// Display labels are localized through [S]; stored machine values are
/// never translated. Only [submittableValues] may be sent through
/// PATCH /candidate/profile.
class MilitaryStatusOptions {
  const MilitaryStatusOptions._();

  static const String completed = 'completed';
  static const String exempted = 'exempted';
  static const String postponed = 'postponed';

  /// Placeholder key for the "Final Exemption" display option.
  ///
  /// The backend machine value is unconfirmed, so this key stays in
  /// [disabledValues] and is never submitted. Replace it once the
  /// backend documents the value.
  /// TODO(backend-contract): confirm the military_status machine value
  /// for "Final Exemption", then enable submission of this option.
  static const String finalExemptionPlaceholder = 'final_exemption_unconfirmed';

  /// Machine values the backend accepts (per confirmed contracts).
  static const Set<String> submittableValues = {completed, exempted, postponed};

  /// Options rendered but not selectable.
  static const Set<String> disabledValues = {finalExemptionPlaceholder};

  /// Machine value → localized display label, in fixed display order.
  static Map<String, String> items(S locale) {
    return {
      completed: locale.militaryCompleted,
      exempted: locale.militaryExempted,
      postponed: locale.militaryPostponed,
      finalExemptionPlaceholder: locale.militaryFinalExemption,
    };
  }

  /// Localized label for a machine value, falling back to the raw value
  /// so unknown existing backend values keep displaying.
  static String labelOf(S locale, String value) {
    return items(locale)[value] ?? value;
  }
}
