abstract final class AppConstants {
  AppConstants._();

  static const String appName = 'SkillMatch';

  // =========================================================
  // Font Families
  // =========================================================

  static const String englishHeadingFont = 'DMSans';
  static const String englishBodyFont = 'Inter';

  static const String arabicHeadingFont = 'Alexandria';
  static const String arabicBodyFont = 'Tajawal';

  // =========================================================
  // Layout
  // =========================================================

  static const double screenHorizontalPadding = 20;
  static const double screenVerticalPadding = 16;

  // =========================================================
  // Spacing
  // =========================================================

  static const double spacing4 = 4;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing32 = 32;

  // =========================================================
  // Radius
  // =========================================================

  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXLarge = 20;

  // =========================================================
  // Animation
  // =========================================================

  static const Duration shortAnimation = Duration(
    milliseconds: 200,
  );
  static const Duration mediumAnimation = Duration(
    milliseconds: 300,
  );

  // =========================================================
  // Pagination
  // =========================================================
  static const int defaultPageSize = 20;

  // MatchingStatus
  static const int excellentMatchThreshold = 90;
  static const int goodMatchThreshold = 80;
  static const int fairMatchThreshold = 60;

  //TODO: change these values
  static const String appFamilyFont = 'Montserrat';
  static const String defaultAvatarUrl =
      'https://i.pinimg.com/736x/bd/42/8e/bd428e6bb156d90045700dbf3e967c3e.jpg';
  static const String noInternetConnection =
      'No Internet Connection';

  // TODO: change the app language from here
  static const String languageCode = 'en';


}
