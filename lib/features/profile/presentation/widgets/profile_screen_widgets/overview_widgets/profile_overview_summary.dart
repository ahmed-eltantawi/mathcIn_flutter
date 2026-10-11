import 'package:flutter/material.dart';

class ProfileOverviewSummary extends StatelessWidget {
  const ProfileOverviewSummary({required this.summary, super.key});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Text(
      summary,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: colors.onSurfaceVariant,
        height: 1.45,
      ),
    );
  }
}
