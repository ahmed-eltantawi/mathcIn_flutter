import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';

class ExperienceManagementHeader extends StatelessWidget {
  const ExperienceManagementHeader({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final theme = Theme.of(context);

    return Row(
      children: [
        IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
        Expanded(
          child: Text(
            locale.experience,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(locale.help),
              content: Text(locale.experienceManagementDescription),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(locale.cancel),
                ),
              ],
            ),
          ),
          icon: const Icon(Icons.help_outline),
        ),
      ],
    );
  }
}
