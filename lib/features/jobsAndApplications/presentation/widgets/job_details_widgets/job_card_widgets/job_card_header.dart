import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_card_widgets/company_avatar.dart';
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
  });

  final String title;
  final String companyName;
  final String? companyLogoUrl;
  final bool isSaved;
  final bool showShareButton;

  final VoidCallback? onShare;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CompanyAvatar(
          companyName: companyName,
          logoUrl: companyLogoUrl,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                companyName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium
                    ?.copyWith(
                      color: context.colors.onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
              SizedBox(height: 3.h),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleLarge,
              ),
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
          icon: Icon(
            isSaved
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            color: isSaved
                ? context.colors.secondary
                : context.colors.onSurface.withValues(
                    alpha: 0.6,
                  ),
          ),
        ),
      ],
    );
  }
}
