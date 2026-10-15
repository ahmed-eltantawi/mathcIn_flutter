import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_card_widgets/company_avatar.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_card_widgets/job_hero_tags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JobCardHeader extends StatelessWidget {
  const JobCardHeader({
    super.key,
    required this.title,
    required this.companyName,
    this.companyLogoUrl,
    required this.isSaved,
    required this.showShareButton,
    required this.onSave,
    this.onShare,
    this.heroTag,
    this.heroPrefix,
    this.jobId,
    this.avatarSize,
  });

  final String title;
  final String companyName;
  final String? companyLogoUrl;
  final bool isSaved;
  final bool showShareButton;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  /// Hero tag forwarded to [CompanyAvatar].
  /// Prefer [heroPrefix] + [jobId] (scoped tags); [heroTag] is legacy fallback.
  final String? heroTag;

  /// List-source prefix (e.g. 'home', 'feed', 'search', 'saved', 'details').
  final String? heroPrefix;

  /// Job id used together with [heroPrefix] to build scoped tags.
  final String? jobId;

  /// Optional override for the avatar size (used in details header).
  final double? avatarSize;

  @override
  Widget build(BuildContext context) {
    final scopedAvatarTag = (heroPrefix != null && jobId != null)
        ? JobHeroTags.avatar(prefix: heroPrefix!, jobId: jobId!)
        : heroTag;
    final scopedTitleTag = (heroPrefix != null && jobId != null)
        ? JobHeroTags.title(prefix: heroPrefix!, jobId: jobId!)
        : null;
    final scopedCompanyTag = (heroPrefix != null && jobId != null)
        ? JobHeroTags.company(prefix: heroPrefix!, jobId: jobId!)
        : null;

    final companyText = Text(
      companyName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.textTheme.bodyMedium?.copyWith(
        color: context.colors.onSurface.withValues(alpha: 0.6),
      ),
    );
    final titleText = Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: context.textTheme.titleLarge,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CompanyAvatar(
          companyName: companyName,
          logoUrl: companyLogoUrl,
          heroTag: scopedAvatarTag,
          size: avatarSize,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (scopedCompanyTag != null)
                JobHeroTags.maybeHero(
                  context: context,
                  tag: scopedCompanyTag,
                  child: companyText,
                )
              else
                companyText,
              SizedBox(height: 3.h),
              if (scopedTitleTag != null)
                JobHeroTags.maybeHero(
                  context: context,
                  tag: scopedTitleTag,
                  child: titleText,
                )
              else
                titleText,
            ],
          ),
        ),
        if (showShareButton)
          IconButton(
            onPressed: onShare ?? () {},
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.share_outlined),
          ),
        IconButton(
          onPressed: onSave ?? () {},
          visualDensity: VisualDensity.compact,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              key: ValueKey<bool>(isSaved),
              isSaved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: isSaved
                  ? context.colors.secondary
                  : context.colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}
