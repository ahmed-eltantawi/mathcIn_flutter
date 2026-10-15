import 'package:flutter/material.dart';

import 'package:share_plus/share_plus.dart';

import 'package:MatchIn/core/extensions/snack_bar_extensions.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/generated/l10n.dart';

//* Shares the real website URL attached to [job] through the native
//* share sheet. Shows a localized message when the URL is missing or
//* invalid instead of sharing a fabricated link.
Future<void> shareJob(BuildContext context, JobEntity job) async {
  final rawUrl = job.websiteUrl?.trim() ?? '';

  final uri = Uri.tryParse(rawUrl);
  final isValid =
      uri != null &&
      uri.isAbsolute &&
      (uri.scheme == 'http' || uri.scheme == 'https');

  if (!isValid) {
    if (context.mounted) {
      context.showErrorSnackBar(S.of(context).shareJobLinkUnavailable);
    }
    return;
  }

  await SharePlus.instance.share(
    ShareParams(text: '${job.title}\n$rawUrl', subject: job.title),
  );
}
