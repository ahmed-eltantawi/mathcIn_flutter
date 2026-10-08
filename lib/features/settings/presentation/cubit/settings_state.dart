import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.isNotificationsEnabled = true,
    this.languageCode = 'en',
    this.themeMode = ThemeMode.system,
    this.isLoading = false,
    this.isLoggedOut = false,
    this.errorMessage,
  });

  final bool isNotificationsEnabled;
  final String languageCode;
  final ThemeMode themeMode;
  final bool isLoading;
  final bool isLoggedOut;
  final String? errorMessage;

  SettingsState copyWith({
    bool? isNotificationsEnabled,
    String? languageCode,
    ThemeMode? themeMode,
    bool? isLoading,
    bool? isLoggedOut,
    String? errorMessage,
  }) {
    return SettingsState(
      isNotificationsEnabled:
          isNotificationsEnabled ?? this.isNotificationsEnabled,
      languageCode: languageCode ?? this.languageCode,
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
      isLoggedOut: isLoggedOut ?? this.isLoggedOut,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isNotificationsEnabled,
    languageCode,
    themeMode,
    isLoading,
    isLoggedOut,
    errorMessage,
  ];
}
