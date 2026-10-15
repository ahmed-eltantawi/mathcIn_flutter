import 'package:MatchIn/core/widgets/error/app_error.dart';
import 'package:MatchIn/features/profile/domain/entities/add_candidate_project_params.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_project_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_candidate_project_params.dart';
import 'package:MatchIn/features/profile/presentation/cubits/projects_cubit/projects_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/projects_cubit/projects_state.dart';
import 'package:MatchIn/core/widgets/helpers/url_launcher_helper.dart';
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

  void _popWithResult(BuildContext context) {
    Navigator.of(context).pop(context.read<ProjectsCubit>().hasChanges);
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CandidateProjectEntity project,
  ) async {
    final locale = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(locale.deleteProject),
        content: Text(locale.deleteProjectConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(locale.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(locale.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<ProjectsCubit>().deleteProject(project.id);
    }
  }

  Future<void> _openLink(BuildContext context, String? url) async {
    if (!UrlLauncherHelper.isViewable(url)) {
      _showMessage(context, S.of(context).somethingWentWrong);
      return;
    }
    final opened = await UrlLauncherHelper.open(url);
    if (!context.mounted) return;
    if (!opened) {
      _showMessage(context, S.of(context).somethingWentWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Single-pop exit guard: programmatic pops (header Back) complete
    // directly with hasChanges, while system Back/gesture is vetoed here
    // and completed once through the same result. The didPop guard makes
    // a repeated callback a no-op, so no loop or duplicate pop is possible.
    // The delete-confirmation dialog is a separate route and is unaffected.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(context.read<ProjectsCubit>().hasChanges);
      },
      child: BlocConsumer<ProjectsCubit, ProjectsState>(
        listenWhen: (previous, current) =>
            previous is ProjectsSaving &&
            (current is ProjectsSuccess || current is ProjectsActionFailure),
        listener: (context, state) {
          final locale = S.of(context);
          if (state is ProjectsActionFailure) {
            final message = state.message.trim().isEmpty
                ? locale.somethingWentWrong
                : state.message;
            _showMessage(context, message);
            return;
          }
          if (state is ProjectsSuccess) {
            final wasDelete = context
                .read<ProjectsCubit>()
                .lastMutationWasDelete;
            _showMessage(
              context,
              wasDelete
                  ? locale.projectDeletedSuccessfully
                  : locale.projectSavedSuccessfully,
            );
          }
        },
        builder: (context, state) {
          switch (state) {
            case ProjectsInitial():
            case ProjectsLoading():
              return const Center(child: CircularProgressIndicator());
            case ProjectsFailure():
              return AppErrorWidget(
                message: state.message,
                onRetry: () => context.read<ProjectsCubit>().getProjects(),
              );
            case ProjectsSaving():
              return _ProjectsContent(
                projects: state.projects,
                formProject: state.formProject,
                isFormVisible: state.isFormVisible,
                formResetToken: state.formResetToken,
                isSaving: true,
                onBack: () => _popWithResult(context),
                onAddNew: () => context.read<ProjectsCubit>().openAddForm(),
                onEdit: (project) =>
                    context.read<ProjectsCubit>().openEditForm(project),
                onDelete: (project) => _confirmDelete(context, project),
                onAdd: (params) =>
                    context.read<ProjectsCubit>().addProject(params),
                onUpdate: (params) =>
                    context.read<ProjectsCubit>().updateProject(params),
                onCancel: () => context.read<ProjectsCubit>().closeForm(),
                onOpenLink: (url) => _openLink(context, url),
              );
            case ProjectsActionFailure():
              return _ProjectsContent(
                projects: state.projects,
                formProject: state.formProject,
                isFormVisible: state.isFormVisible,
                formResetToken: state.formResetToken,
                isSaving: false,
                onBack: () => _popWithResult(context),
                onAddNew: () => context.read<ProjectsCubit>().openAddForm(),
                onEdit: (project) =>
                    context.read<ProjectsCubit>().openEditForm(project),
                onDelete: (project) => _confirmDelete(context, project),
                onAdd: (params) =>
                    context.read<ProjectsCubit>().addProject(params),
                onUpdate: (params) =>
                    context.read<ProjectsCubit>().updateProject(params),
                onCancel: () => context.read<ProjectsCubit>().closeForm(),
                onOpenLink: (url) => _openLink(context, url),
              );
            case ProjectsSuccess():
              return _ProjectsContent(
                projects: state.projects,
                formProject: state.formProject,
                isFormVisible: state.isFormVisible,
                formResetToken: state.formResetToken,
                isSaving: false,
                onBack: () => _popWithResult(context),
                onAddNew: () => context.read<ProjectsCubit>().openAddForm(),
                onEdit: (project) =>
                    context.read<ProjectsCubit>().openEditForm(project),
                onDelete: (project) => _confirmDelete(context, project),
                onAdd: (params) =>
                    context.read<ProjectsCubit>().addProject(params),
                onUpdate: (params) =>
                    context.read<ProjectsCubit>().updateProject(params),
                onCancel: () => context.read<ProjectsCubit>().closeForm(),
                onOpenLink: (url) => _openLink(context, url),
              );
          }
        },
      ),
    );
  }
}

class _ProjectsContent extends StatelessWidget {
  const _ProjectsContent({
    required this.projects,
    required this.formProject,
    required this.isFormVisible,
    required this.formResetToken,
    required this.isSaving,
    required this.onBack,
    required this.onAddNew,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
    required this.onUpdate,
    required this.onCancel,
    required this.onOpenLink,
  });

  final List<CandidateProjectEntity> projects;
  final CandidateProjectEntity? formProject;
  final bool isFormVisible;
  final int formResetToken;
  final bool isSaving;
  final VoidCallback onBack;
  final VoidCallback onAddNew;
  final ValueChanged<CandidateProjectEntity> onEdit;
  final ValueChanged<CandidateProjectEntity> onDelete;
  final ValueChanged<AddCandidateProjectParams> onAdd;
  final ValueChanged<UpdateCandidateProjectParams> onUpdate;
  final VoidCallback onCancel;
  final ValueChanged<String?> onOpenLink;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(16.w, 8.h, 16.w, 32.h),
      children: [
        ProjectsAppBar(title: locale.projects, onBackPressed: onBack),

        SizedBox(height: 20.h),

        const ProjectsProfileCard(),

        SizedBox(height: 20.h),

        if (projects.isEmpty)
          _ProjectsEmptyState()
        else
          for (int index = 0; index < projects.length; index++) ...[
            ProjectCard(
              title: projects[index].name,
              date: ProjectDateFormatter.format(projects[index]),
              description: projects[index].description ?? '',
              skills: projects[index].technologies,
              projectUrl: projects[index].projectUrl,
              githubUrl: projects[index].githubUrl,
              onEdit: () => onEdit(projects[index]),
              onDelete: () => onDelete(projects[index]),
              onProjectPressed: () => onOpenLink(projects[index].projectUrl),
              onGithubPressed: () => onOpenLink(projects[index].githubUrl),
            ),
            if (index != projects.length - 1) SizedBox(height: 12.h),
          ],

        SizedBox(height: 8.h),

        AddProjectButton(onPressed: isSaving ? null : onAddNew),

        if (isFormVisible) ...[
          SizedBox(height: 20.h),

          ProjectForm(
            key: ValueKey(
              '${formProject?.id ?? 'new-project'}-$formResetToken',
            ),
            project: formProject,
            isSaving: isSaving,
            onAdd: onAdd,
            onUpdate: onUpdate,
            onCancel: onCancel,
          ),
        ],
      ],
    );
  }
}

class _ProjectsEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.folder_outlined,
            size: 40.r,
            color: colors.onSurfaceVariant,
          ),
          SizedBox(height: 12.h),
          Text(
            locale.noProjectsYet,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            locale.noProjectsYetDesc,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
