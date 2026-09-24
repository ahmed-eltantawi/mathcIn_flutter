import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_card_widgets/job_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class RecommendedJobsSection extends StatelessWidget {
  const RecommendedJobsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: دي dummy data مؤقتة لحد ما نربط الـ Cubit بالباك إند
    final dummyJobs = [
      JobEntity(
        id: '1',
        title: 'Junior Flutter Developer',
        companyName: 'TechNova',
        location: 'Cairo',
        workMode: 'Hybrid',
        experienceLevel: '0–2 years',
        employmentType: 'Full-time',
        postedDate: DateTime.now().subtract(
          const Duration(days: 2),
        ),
        skills: const ['Flutter', 'REST API', 'Bloc'],
        matchPercentage: 92,
        isSaved: true,
      ),
      JobEntity(
        id: '2',
        title: 'Mobile Developer Intern',
        companyName: 'CodeHub',
        location: 'Remote',
        workMode: 'Remote',
        experienceLevel: 'Entry Level',
        employmentType: 'Internship',
        postedDate: DateTime.now(),
        skills: const ['Flutter', 'Firebase', 'Git'],
        matchPercentage: 86,
      ),
      JobEntity(
        id: '3',
        title: 'Junior Software Engineer',
        companyName: 'NextStack',
        location: 'Giza',
        workMode: 'On-site',
        experienceLevel: 'Entry Level',
        employmentType: 'Full-time',
        postedDate: DateTime.now().subtract(
          const Duration(days: 3),
        ),
        skills: const ['Dart', 'Flutter'],
        matchPercentage: 74,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16).w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.recommendedForYou,
                  style: context.textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: () =>
                    context.push(AppRoutes.kJobsSearchView),
                child: Text(context.l10n.seeAll),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          for (final job in dummyJobs) ...[
            JobCard(job: job, showShareButton: true),
            SizedBox(height: 12.h),
          ],
        ],
      ),
    );
  }
}
