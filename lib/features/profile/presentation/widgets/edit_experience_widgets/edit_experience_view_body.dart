import 'package:MatchIn/core/widgets/error/app_error.dart';
import 'package:MatchIn/features/profile/domain/entities/add_experience_params.dart';
import 'package:MatchIn/features/profile/domain/entities/experience_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_experience_params.dart';
import 'package:MatchIn/features/profile/presentation/cubits/experience_cubit/edit_experience_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/experience_cubit/edit_experience_state.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/experience_current_records.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/experience_form.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/experience_management_header.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/experience_summary_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditExperienceViewBody extends StatelessWidget {
  const EditExperienceViewBody({super.key});

  void _popWithResult(BuildContext context) {
    Navigator.of(context).pop(context.read<EditExperienceCubit>().hasChanges);
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ExperienceEntity experience,
  ) async {
    final locale = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(locale.deleteExperience),
        content: Text(locale.deleteExperienceConfirm),
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
      context.read<EditExperienceCubit>().deleteExperience(experience.id);
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
        Navigator.of(context)
            .pop(context.read<EditExperienceCubit>().hasChanges);
      },
      child: BlocConsumer<EditExperienceCubit, EditExperienceState>(
        listenWhen: (previous, current) =>
            previous is EditExperienceSaving &&
            (current is EditExperienceSuccess ||
                current is EditExperienceActionFailure),
        listener: (context, state) {
          final locale = S.of(context);
          if (state is EditExperienceActionFailure) {
            final message = state.message.trim().isEmpty
                ? locale.somethingWentWrong
                : state.message;
            _showMessage(context, message);
            return;
          }
          if (state is EditExperienceSuccess) {
            final wasDelete = context
                .read<EditExperienceCubit>()
                .lastMutationWasDelete;
            _showMessage(
              context,
              wasDelete
                  ? locale.experienceDeletedSuccessfully
                  : locale.experienceSavedSuccessfully,
            );
          }
        },
        builder: (context, state) {
          switch (state) {
            case EditExperienceInitial():
            case EditExperienceLoading():
              return const Center(child: CircularProgressIndicator());
            case EditExperienceFailure():
              return AppErrorWidget(
                message: state.message,
                onRetry: () =>
                    context.read<EditExperienceCubit>().loadExperiences(),
              );
            case EditExperienceSaving():
              return _ExperienceContent(
                experiences: state.experiences,
                editingExperience: state.editingExperience,
                formResetToken: state.formResetToken,
                isSaving: true,
                onBack: () => _popWithResult(context),
                onAddNew: () =>
                    context.read<EditExperienceCubit>().cancelEdit(),
                onEdit: (experience) =>
                    context.read<EditExperienceCubit>().startEdit(experience),
                onDelete: (experience) => _confirmDelete(context, experience),
                onAdd: (params) =>
                    context.read<EditExperienceCubit>().addExperience(params),
                onUpdate: (params) => context
                    .read<EditExperienceCubit>()
                    .updateExperience(params),
                onCancel: () =>
                    context.read<EditExperienceCubit>().cancelEdit(),
              );
            case EditExperienceActionFailure():
              return _ExperienceContent(
                experiences: state.experiences,
                editingExperience: state.editingExperience,
                formResetToken: state.formResetToken,
                isSaving: false,
                onBack: () => _popWithResult(context),
                onAddNew: () =>
                    context.read<EditExperienceCubit>().cancelEdit(),
                onEdit: (experience) =>
                    context.read<EditExperienceCubit>().startEdit(experience),
                onDelete: (experience) => _confirmDelete(context, experience),
                onAdd: (params) =>
                    context.read<EditExperienceCubit>().addExperience(params),
                onUpdate: (params) => context
                    .read<EditExperienceCubit>()
                    .updateExperience(params),
                onCancel: () =>
                    context.read<EditExperienceCubit>().cancelEdit(),
              );
            case EditExperienceSuccess():
              return _ExperienceContent(
                experiences: state.experiences,
                editingExperience: state.editingExperience,
                formResetToken: state.formResetToken,
                isSaving: false,
                onBack: () => _popWithResult(context),
                onAddNew: () =>
                    context.read<EditExperienceCubit>().cancelEdit(),
                onEdit: (experience) =>
                    context.read<EditExperienceCubit>().startEdit(experience),
                onDelete: (experience) => _confirmDelete(context, experience),
                onAdd: (params) =>
                    context.read<EditExperienceCubit>().addExperience(params),
                onUpdate: (params) => context
                    .read<EditExperienceCubit>()
                    .updateExperience(params),
                onCancel: () =>
                    context.read<EditExperienceCubit>().cancelEdit(),
              );
          }
        },
      ),
    );
  }
}

class _ExperienceContent extends StatelessWidget {
  const _ExperienceContent({
    required this.experiences,
    required this.editingExperience,
    required this.formResetToken,
    required this.isSaving,
    required this.onBack,
    required this.onAddNew,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
    required this.onUpdate,
    required this.onCancel,
  });

  final List<ExperienceEntity> experiences;
  final ExperienceEntity? editingExperience;
  final int formResetToken;
  final bool isSaving;
  final VoidCallback onBack;
  final VoidCallback onAddNew;
  final ValueChanged<ExperienceEntity> onEdit;
  final ValueChanged<ExperienceEntity> onDelete;
  final ValueChanged<AddExperienceParams> onAdd;
  final ValueChanged<UpdateExperienceParams> onUpdate;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
      children: [
        ExperienceManagementHeader(onBack: onBack),

        SizedBox(height: 20.h),

        const ExperienceSummaryCard(),

        SizedBox(height: 22.h),

        if (experiences.isEmpty)
          _ExperienceEmptyState()
        else
          ExperienceCurrentRecords(
            experiences: experiences,
            onEdit: onEdit,
            onDelete: onDelete,
          ),

        SizedBox(height: 16.h),

        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: FilledButton.icon(
            onPressed: isSaving ? null : onAddNew,
            icon: Icon(Icons.add_rounded, size: 20.r),
            label: Text(locale.addExperience),
          ),
        ),

        SizedBox(height: 18.h),

        ExperienceForm(
          key: ValueKey('experience-form-$formResetToken'),
          initialExperience: editingExperience,
          isSaving: isSaving,
          onAdd: onAdd,
          onUpdate: onUpdate,
          onCancel: onCancel,
        ),
      ],
    );
  }
}

class _ExperienceEmptyState extends StatelessWidget {
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
            Icons.work_outline_rounded,
            size: 40.r,
            color: colors.onSurfaceVariant,
          ),
          SizedBox(height: 12.h),
          Text(
            locale.noExperienceYet,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            locale.noExperienceYetDesc,
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
