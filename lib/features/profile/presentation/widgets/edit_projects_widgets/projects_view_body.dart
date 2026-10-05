import 'package:MatchIn/features/profile/domain/entities/candidate_project_entity.dart';
import 'package:MatchIn/features/profile/presentation/cubits/projects_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/projects_state.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_projects_widgets/add_project_button.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_projects_widgets/project_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_projects_widgets/project_date_formatter.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_projects_widgets/project_form.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_projects_widgets/projects_app_bar.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_projects_widgets/projects_profile_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProjectsViewBody extends StatelessWidget {
  const ProjectsViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return BlocConsumer<ProjectsCubit, ProjectsState>(
      listener: (context, state) {
        if (state is ProjectsActionFailure) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is ProjectsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProjectsFailure) {
          return Center(child: Text(state.message));
        }

        final projects = _projectsFromState(state);

        final bool isFormVisible;
        final CandidateProjectEntity? formProject;

        if (state is ProjectsSuccess) {
          isFormVisible = state.isFormVisible;
          formProject = state.formProject;
        } else if (state is ProjectsActionFailure) {
          isFormVisible = state.isFormVisible;
          formProject = state.formProject;
        } else {
          isFormVisible = false;
          formProject = null;
        }

        return ListView(
          padding: EdgeInsetsDirectional.fromSTEB(16.w, 8.h, 16.w, 32.h),
          children: [
            ProjectsAppBar(
              title: locale.projects,
              onBackPressed: () {
                Navigator.maybePop(context);
              },
            ),

            SizedBox(height: 20.h),

            const ProjectsProfileCard(),

            SizedBox(height: 20.h),

            ...projects.map(
              (project) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: ProjectCard(
                  title: project.name,
                  date: ProjectDateFormatter.format(project),
                  description: project.description ?? '',
                  skills: project.technologies,
                  projectUrl: project.projectUrl,
                  githubUrl: project.githubUrl,
                  onEdit: () {
                    context.read<ProjectsCubit>().openEditForm(project);
                  },
                  onDelete: () {
                    context.read<ProjectsCubit>().deleteProject(project.id);
                  },
                  onProjectPressed: () {
                    // TODO: Open project URL.
                  },
                  onGithubPressed: () {
                    // TODO: Open GitHub URL.
                  },
                ),
              ),
            ),

            SizedBox(height: 8.h),

            AddProjectButton(
              onPressed: () {
                context.read<ProjectsCubit>().openAddForm();
              },
            ),

            if (isFormVisible) ...[
              SizedBox(height: 20.h),

              ProjectForm(
                key: ValueKey(formProject?.id ?? 'new-project'),
                project: formProject,
              ),
            ],
          ],
        );
      },
    );
  }

  List<CandidateProjectEntity> _projectsFromState(ProjectsState state) {
    if (state is ProjectsSuccess) {
      return state.projects;
    }

    if (state is ProjectsActionFailure) {
      return state.projects;
    }

    return const <CandidateProjectEntity>[];
  }
}
