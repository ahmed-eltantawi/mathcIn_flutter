import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/overview_widgets/profile_overview_link_chip.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileOverviewSocialLinks extends StatelessWidget {
  const ProfileOverviewSocialLinks({
    this.githubUrl,
    this.linkedinUrl,
    super.key,
  });

  final String? githubUrl;
  final String? linkedinUrl;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ProfileOverviewLinkChip(
          icon: Icons.code_rounded,
          label: locale.github,
          onPressed: () => _openLink(githubUrl),
        ),
        SizedBox(width: 8.w),
        ProfileOverviewLinkChip(
          icon: Icons.link_rounded,
          label: locale.linkedin,
          onPressed: () => _openLink(linkedinUrl),
        ),
      ],
    );
  }

  Future<void> _openLink(String? value) async {
    final uri = Uri.tryParse(value?.trim() ?? '');
    if (uri == null || !{'http', 'https'}.contains(uri.scheme)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
