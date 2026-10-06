import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';

class EducationManagementHeader extends StatelessWidget {
  const EducationManagementHeader({required this.onBack, super.key});

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
            locale.education,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        TextButton(onPressed: () {}, child: Text(locale.help)),
      ],
    );
  }
}
