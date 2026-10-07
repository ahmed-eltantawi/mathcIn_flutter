import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_card_widgets/initial_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///* CompanyAvatar — displays a company logo or initials fallback.
///* Accepts an optional [heroTag] to participate in Hero animations between
///* the job card in the list and the job details screen.
class CompanyAvatar extends StatelessWidget {
  const CompanyAvatar({
    super.key,
    required this.companyName,
    this.logoUrl,
    this.heroTag,
    this.size,
  });

  final String companyName;
  final String? logoUrl;

  /// Optional Hero tag for shared-element transitions.
  /// Pass `'company_avatar_${job.id}'` from the caller.
  final String? heroTag;

  /// Override the default 48×48 size when used in the details header.
  final double? size;

  @override
  Widget build(BuildContext context) {
    final dimension = size ?? 48.r;
    final avatar = Container(
      width: dimension,
      height: dimension,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: context.theme.dividerColor,
        ),
      ),
      child: (logoUrl == null || logoUrl!.isEmpty)
          ? InitialsText(companyName: companyName)
          : Image.network(
              logoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return InitialsText(companyName: companyName);
              },
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return SizedBox(
                  width: 20.r,
                  height: 20.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.colors.primary,
                  ),
                );
              },
            ),
    );

    if (heroTag == null) return avatar;

    return Hero(
      tag: heroTag!,
      // Keep the border-radius intact during the flight.
      flightShuttleBuilder: (_, animation, __, ___, ____) => AnimatedBuilder(
        animation: animation,
        builder: (ctx, child) => Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          child: avatar,
        ),
      ),
      child: avatar,
    );
  }
}
