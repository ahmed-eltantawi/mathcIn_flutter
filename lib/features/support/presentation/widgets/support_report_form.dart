import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:MatchIn/core/extensions/snack_bar_extensions.dart';
import 'package:MatchIn/core/utils/app_constants.dart';
import 'package:MatchIn/core/widgets/helpers/url_launcher_helper.dart';
import 'package:MatchIn/features/support/platform_version.dart';
import 'package:MatchIn/generated/l10n.dart';

class SupportReportForm extends StatefulWidget {
  const SupportReportForm({required this.emailAddress, super.key});

  final String emailAddress;

  @override
  State<SupportReportForm> createState() => _SupportReportFormState();
}

class _SupportReportFormState extends State<SupportReportForm> {
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _sendReport() async {
    final description = _descriptionController.text.trim();
    final l10n = S.of(context);
    if (description.isEmpty) {
      context.showErrorSnackBar(l10n.reportIssueDescriptionRequired);
      return;
    }

    final body = [
      '${l10n.reportIssueDescriptionLabel}:\n$description',
      '${l10n.reportIssueAppVersionLabel}: '
          '${AppConstants.appVersion}+${AppConstants.appBuildNumber}',
      '${l10n.reportIssuePlatformVersionLabel}: ${getPlatformVersion()}',
    ].join('\n\n');
    final opened = await UrlLauncherHelper.openEmail(
      widget.emailAddress,
      subject: l10n.reportIssueEmailSubject,
      body: body,
    );

    if (!opened && mounted) {
      context.showErrorSnackBar(l10n.reportIssueEmailLaunchFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = S.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Card(
      elevation: 0,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
        side: BorderSide(color: colors.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reportIssueTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 5,
              maxLength: 1200,
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              decoration: InputDecoration(
                hintText: l10n.reportIssueDescriptionHint,
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
            SizedBox(height: 6.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _sendReport,
                icon: const Icon(Icons.email_outlined),
                label: Text(l10n.reportIssueEmailButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
