import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_card_widgets/job_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

///* AnimatedJobCardList — renders a list of job cards with a staggered
///* fade + slide-up entrance animation. Each card animates independently
///* so rapid scrolls remain smooth.
class AnimatedJobCardList extends StatelessWidget {
  const AnimatedJobCardList({
    super.key,
    required this.jobs,
    this.onSave,
    this.onApply,
    this.onShareJob,
    this.showShareButton = false,
    this.heroPrefix = 'feed',
  });

  final List<JobEntity> jobs;
  final void Function(String jobId)? onSave;
  final void Function(String jobId)? onApply;
  final void Function(JobEntity job)? onShareJob;
  final bool showShareButton;

  /// List-source prefix forwarded to each [JobCard] for scoped Hero tags.
  final String heroPrefix;

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 24.h,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            for (final job in jobs) ...[
              JobCard(
                job: job,
                heroPrefix: heroPrefix,
                showShareButton: showShareButton,
                onSave:
                    onSave != null ? () => onSave!(job.id) : null,
                onApply:
                    onApply != null ? () => onApply!(job.id) : null,
                onShare: onShareJob != null
                    ? () => onShareJob!(job)
                    : null,
              ),
              SizedBox(height: 12.h),
            ],
          ],
        ),
      ),
    );
  }
}
