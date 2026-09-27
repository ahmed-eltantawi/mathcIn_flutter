class AppStrings {
  static const String appName = 'MarchIn';
  static const String skip = 'Skip';
  static const String next = 'Next';
  static const String getStarted = 'Get Started';
  static const String onboardingTitle1 = 'Discover New Trends';
  static const String onboardingDesc1 =
      'Find the best products for your lifestyle with our curated collection.';
  static const String onboardingTitle2 = 'Easy Shopping';
  static const String onboardingDesc2 =
      'Enjoy a seamless shopping experience with secure payments and fast delivery.';
  static const String onboardingTitle3 = 'Exclusive Offers';
  static const String onboardingDesc3 =
      'Get access to members-only deals and special discounts.';

  // Validation Messages
  static const String emailRequired = 'Email is required';
  static const String emailMinLength = 'Email must be at least 6 characters';
  static const String emailMustEndGmail = 'Email must end with @gmail.com';
  static const String emailInvalidFormat = 'Invalid email format';

  static const String fieldRequired = 'Field is required';
  static const String passwordAtLeast8Char =
      'Password must be at least 8 characters';
  static const String passwordAtLeast1Uppercase =
      'Password must contain at least 1 uppercase letter';
  static const String passwordAtLeast1Lowercase =
      'Password must contain at least 1 lowercase letter';
  static const String passwordAtLeast1Number =
      'Password must contain at least 1 number';
  static const String passwordAtLeast1SpecialChar =
      'Password must contain at least 1 special character';
  static const String passwordNotTheSame = 'Passwords do not match';

  static const String idRequired = 'ID is required';
  static const String idInvalid = 'Invalid ID format';

  static const String phoneRequired = 'Phone number is required';
  static const String phoneInvalidStart =
      'Phone number must start with 010, 011, 012, or 015';
  static const String phoneInvalidLength = 'Phone number must be 11 digits';
  static const String phoneInvalidFormat = 'Phone number must be digits only';

  static const String usernameRequired = 'Username is required';
  static const String usernameMustStartWithLetter =
      'Username must start with a letter';
  static const String usernameMinLength =
      'Username must be at least 3 characters';
  static const String usernameInvalidFormat = 'Username format is invalid';
  static const String usernameMustContainAtLeast3Letters =
      'Username must contain at least 3 letters';

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value != password) {
      return AppStrings.passwordNotTheSame;
    }
    return null;
  }
}
