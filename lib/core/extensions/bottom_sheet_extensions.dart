import 'package:flutter/material.dart';
import 'package:MatchIn/core/widgets/app_bottom_sheet.dart';

/// Extension on [BuildContext] for displaying standard bottom sheets.
extension BottomSheetExtensions on BuildContext {
  /// Displays an [AppBottomSheet] with the given child widget.
  Future<T?> showAppBottomSheet<T>({
    required Widget child,
    String? title,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = true,
  }) {
    return AppBottomSheet.show<T>(
      this,
      child: child,
      title: title,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
    );
  }
}
