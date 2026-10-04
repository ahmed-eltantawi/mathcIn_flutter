import 'package:flutter/material.dart';

class ProfileOverviewSummary extends StatelessWidget {
  const ProfileOverviewSummary({super.key});

  static const _summary =
      'Looking for Flutter and Mobile Development opportunities.';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Text(
      _summary,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: colors.onSurfaceVariant,
        height: 1.45,
      ),
    );
  }
}
