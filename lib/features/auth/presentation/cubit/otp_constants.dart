///* OTP timing configuration shared by the cubit and the animated field.
abstract final class OtpConstants {
  OtpConstants._();

  //! ===== Verification Timing =====
  // --- Minimum time the verifying orbit animation stays visible,
  // --- even when the API responds faster. Matches the default of
  // --- OtpAnimatedField.minimumVerifyingDuration so cubit emission
  // --- and widget animation stay in sync. ---
  static const Duration minVerifyingDuration = Duration(milliseconds: 1500);
}
