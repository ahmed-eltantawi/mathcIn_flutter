import 'package:flutter/material.dart';

@immutable
class AppSemanticColors
    extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({required this.success});

  final Color success;

  @override
  AppSemanticColors copyWith({Color? success}) {
    return AppSemanticColors(
      success: success ?? this.success,
    );
  }

  @override
  AppSemanticColors lerp(
    covariant AppSemanticColors? other,
    double t,
  ) {
    if (other == null) return this;

    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
    );
  }
}
