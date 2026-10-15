import 'package:flutter/material.dart';
import 'package:MatchIn/generated/l10n.dart';

class ReviewCoverNoteCard extends StatelessWidget {
  const ReviewCoverNoteCard({super.key, this.coverNote});

  final String? coverNote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final hasNote = coverNote != null && coverNote!.trim().isNotEmpty;

    return Text(
      hasNote ? coverNote!.trim() : s.noCoverNoteAdded,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontStyle: hasNote ? FontStyle.normal : FontStyle.italic,
        color: theme.colorScheme.onSurface.withValues(
          alpha: hasNote ? 0.85 : 0.55,
        ),
      ),
    );
  }
}
