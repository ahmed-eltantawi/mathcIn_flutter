import 'package:MatchIn/core/utils/app_strings.dart';

class Validator {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return AppStrings.emailRequired;
    }

    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!regex.hasMatch(email)) {
      return AppStrings.emailInvalidFormat;
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (password.length < 8) {
      return AppStrings.passwordAtLeast8Char;
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return AppStrings.passwordAtLeast1Uppercase;
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return AppStrings.passwordAtLeast1Lowercase;
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return AppStrings.passwordAtLeast1Number;
    }
    if (!RegExp(r'[@$!%*?&]').hasMatch(password)) {
      return AppStrings.passwordAtLeast1SpecialChar;
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value != password) {
      return AppStrings.passwordNotTheSame;
    }
    return null;
  }

  static String? validatePhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return AppStrings.phoneRequired;
    }
    if (!RegExp(r'^01[0125]').hasMatch(phoneNumber)) {
      return AppStrings.phoneInvalidStart;
    }
    if (phoneNumber.length != 11) {
      return AppStrings.phoneInvalidLength;
    }
    if (!RegExp(r'^\d{11}$').hasMatch(phoneNumber)) {
      return AppStrings.phoneInvalidFormat;
    }
    return null;
  }

  static String? validateUserName(String? userName) {
    if (userName == null || userName.isEmpty) {
      return AppStrings.usernameRequired;
    }
    final regex = RegExp(r'^[a-zA-Z][a-zA-Z0-9_ ]{2,}$');
    if (!RegExp(r'^[a-zA-Z]').hasMatch(userName)) {
      return AppStrings.usernameMustStartWithLetter;
    } else if (userName.length < 3) {
      return AppStrings.usernameMinLength;
    } else if (!regex.hasMatch(userName)) {
      return AppStrings.usernameInvalidFormat;
    } else if (userName.replaceAll(RegExp(r'[^a-zA-Z]'), '').length < 3) {
      return AppStrings.usernameMustContainAtLeast3Letters;
    }
    return null;
  }
}
