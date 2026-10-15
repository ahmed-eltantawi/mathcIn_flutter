import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shown when the candidate profile does not exist yet and the user
/// taps a management action (education, experience, skills, projects,
/// or career preferences).
///
/// Returns `true` when the user taps "Create Profile" so the caller can
/// navigate to the existing Edit Profile screen. Never navigates itself
/// and never triggers management GET requests.
class ProfileCreationPromptDialog extends StatelessWidget {
  const ProfileCreationPromptDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const ProfileCreationPromptDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        locale.createProfile,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        locale.completeProfilePrompt,
        style: theme.textTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(locale.cancel),
        ),
        SizedBox(width: 8.w),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(locale.createProfile),
        ),
      ],
    );
  }
}
