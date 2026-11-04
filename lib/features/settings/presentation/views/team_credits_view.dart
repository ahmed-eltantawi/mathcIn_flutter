import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/widgets/custom_app_bar.dart';
import 'package:MatchIn/features/settings/presentation/models/team_credits_data.dart';
import 'package:MatchIn/features/settings/presentation/models/team_member_model.dart';
import 'package:MatchIn/features/settings/presentation/widgets/team_member_card.dart';

class TeamCreditsView extends StatelessWidget {
  const TeamCreditsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: CustomAppBar(title: l10n.teamCredits),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TeamIntroCard(
                title: l10n.teamIntroTitle,
                subtitle: l10n.teamIntroSubtitle,
              ),
              SizedBox(height: 24.h),
              _TeamSection(
                title: l10n.teamMembers,
                members: TeamCreditsData.members,
                icon: Icons.groups_2_outlined,
              ),
              SizedBox(height: 24.h),
              _TeamSection(
                title: l10n.supervisors,
                members: TeamCreditsData.supervisors,
                icon: Icons.workspace_premium_outlined,
                subtitle: l10n.supervisorsSubtitle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamIntroCard extends StatelessWidget {
  const _TeamIntroCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            colors.primary,
            colors.primary.withValues(alpha: 0.84),
          ],
        ),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: colors.onPrimary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              Icons.groups_2_rounded,
              color: colors.onPrimary,
              size: 25.r,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onPrimary.withValues(alpha: 0.82),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamSection extends StatelessWidget {
  const _TeamSection({
    required this.title,
    required this.members,
    required this.icon,
    this.subtitle,
  });

  final String title;
  final List<TeamMemberModel> members;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: colors.primary, size: 20.r),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(width: 8.w), // مسافة فاصلة بين العنوان والعداد
            Container(
              constraints: BoxConstraints(minWidth: 30.w, minHeight: 30.h),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '${members.length}',
                style: textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsetsDirectional.only(start: 46.w),
            child: Text(
              subtitle!,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
        SizedBox(height: 12.h),
        // إضافة مسافات فاصلة بين كل كارت والثاني لتجنب الالتصاق
        ...members.map(
          (member) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: TeamMemberCard(member: member),
          ),
        ),
      ],
    );
  }
}