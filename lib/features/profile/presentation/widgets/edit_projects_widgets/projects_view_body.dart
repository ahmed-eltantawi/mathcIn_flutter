import 'package:MatchIn/features/profile/presentation/widgets/edit_projects_widgets/add_project_button.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_projects_widgets/add_project_details_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_projects_widgets/project_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_projects_widgets/projects_profile_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProjectsViewBody extends StatelessWidget {
  const ProjectsViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(
        16.w,
        8.h,
        16.w,
        32.h,
      ),
      children: [
        _ProjectsAppBar(
          title: locale.projects,
          onBackPressed: () => Navigator.maybePop(context),
        ),
        SizedBox(height: 20.h),

        const ProjectsProfileCard(),

        SizedBox(height: 20.h),

        ProjectCard(
          title: 'Job Finder App',
          date: 'Jan 2025 – Mar 2025',
          description: 'Flutter application for discovering, matching and saving job opportunities.',
          skills: const [
            'Flutter',
            'Dart',
            'REST API',
            'Bloc',
          ],
          projectUrl: 'https://myproject.live',
          githubUrl:
              'https://github.com/username/job-finder',
          onEdit: () {},
          onDelete: () {},
          onProjectPressed: () {},
          onGithubPressed: () {},
        ),

        SizedBox(height: 12.h),

        ProjectCard(
          title: 'E-Commerce App',
          date: 'Oct 2024 – Dec 2024',
          description: 'Mobile shopping application built with Flutter featuring offline cart and state management.',
          skills: const ['Flutter', 'Firebase', 'Bloc'],
          githubUrl:
              'https://github.com/username/ecommerce',
          onEdit: () {},
          onDelete: () {},
          onGithubPressed: () {},
        ),

        SizedBox(height: 20.h),

        AddProjectButton(onPressed: () {}),

        SizedBox(height: 20.h),

        const AddProjectDetailsCard(),
      ],
    );
  }
}

class _ProjectsAppBar extends StatelessWidget {
  const _ProjectsAppBar({
    required this.title,
    required this.onBackPressed,
  });

  final String title;
  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 56.h,
      child: Row(
        children: [
          IconButton(
            onPressed: onBackPressed,
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 21.r,
            ),
          ),
          SizedBox(width: 105.w),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
