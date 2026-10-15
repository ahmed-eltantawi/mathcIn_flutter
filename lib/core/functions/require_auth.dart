import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/generated/l10n.dart';

bool _isGuestDialogOpen = false;

//* Centralized authentication guard for candidate actions that require a
//* signed-in session (apply, saved jobs, applied jobs, ...).
//* Returns true when the user is authenticated; otherwise shows the
//* localized guest-mode dialog once and returns false without issuing
//* any protected API request.
bool requireAuth(BuildContext context) {
  final prefs = getIt<SharedPreferencesService>();
  if (prefs.isLoggedIn()) return true;

  if (!_isGuestDialogOpen) {
    _isGuestDialogOpen = true;
    final locale = S.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(locale.guestModeTitle),
          content: Text(locale.guestModeMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(locale.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Push keeps the current job/screen underneath so that
                // going back after login restores the previous context.
                context.push(AppRoutes.kLoginView);
              },
              child: Text(locale.login),
            ),
          ],
        );
      },
    ).whenComplete(() {
      _isGuestDialogOpen = false;
    });
  }

  return false;
}
