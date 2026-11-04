import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:MatchIn/core/utils/app_assets.dart';
import 'package:MatchIn/core/widgets/helpers/url_launcher_helper.dart';
import 'package:MatchIn/features/settings/presentation/models/team_member_model.dart';
import 'package:MatchIn/generated/l10n.dart';

class TeamMemberCard extends StatelessWidget {
  const TeamMemberCard({required this.member, super.key});

  final TeamMemberModel member;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = S.of(context);
    final socialIconSize = 23.r;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final displayName = isArabic ? member.arabicName : member.name;
    final nameParts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    final initials = nameParts.length > 1
        ? '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase()
        : nameParts.first[0].toUpperCase();

    return Card(
      margin: EdgeInsets.only(bottom: 9.h),
      elevation: 0,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
        side: BorderSide(color: colors.outline.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(14.w, 12.h, 8.w, 12.h),
        child: Row(
          children: [
            Container(
              width: 46.r,
              height: 46.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Text(
                initials,
                style: textTheme.labelLarge?.copyWith(
                  color: colors.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              tooltip: l10n.openLinkedInProfile,
              onPressed: () => UrlLauncherHelper.open(member.linkedInUrl),
              style: IconButton.styleFrom(
                backgroundColor: colors.primary.withValues(alpha: 0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              icon: SvgPicture.asset(
                Assets.linkedinLogo,
                width: socialIconSize,
                height: socialIconSize,
              ),
            ),
            if (member.facebookUrl != null) ...[
              SizedBox(width: 8.w),
              IconButton(
                tooltip: l10n.openFacebookProfile,
                onPressed: () => UrlLauncherHelper.open(member.facebookUrl),
                style: IconButton.styleFrom(
                  backgroundColor: colors.primary.withValues(alpha: 0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                icon: Icon(
                  Icons.facebook_rounded,
                  color: const Color(0xFF1877F2),
                  size: socialIconSize,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
