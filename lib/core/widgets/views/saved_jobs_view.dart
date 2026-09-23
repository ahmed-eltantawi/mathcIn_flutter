import 'package:flutter/material.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/widgets/empty/app_empty.dart';

class SavedJobsView extends StatelessWidget {
  const SavedJobsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.savedJobs)),
      body: AppEmptyWidget(
        icon: Icons.bookmark_border_rounded,
        title: context.l10n.savedJobs,
        message: 'No saved jobs yet. Bookmarked opportunities will appear here.',
      ),
    );
  }
}
