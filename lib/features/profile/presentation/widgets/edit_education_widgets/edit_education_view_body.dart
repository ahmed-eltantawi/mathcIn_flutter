import 'package:MatchIn/core/widgets/error/app_error.dart';
import 'package:MatchIn/features/profile/domain/entities/add_education_params.dart';
import 'package:MatchIn/features/profile/domain/entities/education_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_education_params.dart';
import 'package:MatchIn/features/profile/presentation/cubits/education_cubit/edit_education_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/education_cubit/edit_education_state.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_education_widgets/education_academic_history_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_education_widgets/education_form.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_education_widgets/education_management_header.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_education_widgets/education_management_record.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_education_widgets/education_recruiter_visibility_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditEducationViewBody extends StatelessWidget {
  const EditEducationViewBody({super.key});

  void _popWithResult(BuildContext context) {
    Navigator.of(context).pop(context.read<EditEducationCubit>().hasChanges);
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmDelete(
    BuildContext context,
    EducationEntity education,
  ) async {
    final locale = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(locale.deleteEducation),
        content: Text(locale.deleteEducationConfirm),
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
      context.read<EditEducationCubit>().deleteEducation(education.id);
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
            .pop(context.read<EditEducationCubit>().hasChanges);
      },
      child: BlocConsumer<EditEducationCubit, EditEducationState>(
        listenWhen: (previous, current) =>
            previous is EditEducationSaving &&
            (current is EditEducationSuccess ||
                current is EditEducationActionFailure),
        listener: (context, state) {
          final locale = S.of(context);
          if (state is EditEducationActionFailure) {
            final message = state.message.trim().isEmpty
                ? locale.somethingWentWrong
                : state.message;
            _showMessage(context, message);
            return;
          }
          if (state is EditEducationSuccess) {
            final wasDelete = context
                .read<EditEducationCubit>()
                .lastMutationWasDelete;
            _showMessage(
              context,
              wasDelete
                  ? locale.educationDeletedSuccessfully
                  : locale.educationSavedSuccessfully,
            );
          }
        },
        builder: (context, state) {
          switch (state) {
            case EditEducationInitial():
            case EditEducationLoading():
              return const Center(child: CircularProgressIndicator());
            case EditEducationFailure():
              return AppErrorWidget(
                message: state.message,
                onRetry: () =>
                    context.read<EditEducationCubit>().loadEducations(),
              );
            case EditEducationSaving():
              return _EducationContent(
                educations: state.educations,
                editingEducation: state.editingEducation,
                formResetToken: state.formResetToken,
                isSaving: true,
                onBack: () => _popWithResult(context),
                onEdit: (education) =>
                    context.read<EditEducationCubit>().startEdit(education),
                onDelete: (education) => _confirmDelete(context, education),
                onAdd: (params) =>
                    context.read<EditEducationCubit>().addEducation(params),
                onUpdate: (params) =>
                    context.read<EditEducationCubit>().updateEducation(params),
                onCancel: () => context.read<EditEducationCubit>().cancelEdit(),
              );
            case EditEducationActionFailure():
              return _EducationContent(
                educations: state.educations,
                editingEducation: state.editingEducation,
                formResetToken: state.formResetToken,
                isSaving: false,
                onBack: () => _popWithResult(context),
                onEdit: (education) =>
                    context.read<EditEducationCubit>().startEdit(education),
                onDelete: (education) => _confirmDelete(context, education),
                onAdd: (params) =>
                    context.read<EditEducationCubit>().addEducation(params),
                onUpdate: (params) =>
                    context.read<EditEducationCubit>().updateEducation(params),
                onCancel: () => context.read<EditEducationCubit>().cancelEdit(),
              );
            case EditEducationSuccess():
              return _EducationContent(
                educations: state.educations,
                editingEducation: state.editingEducation,
                formResetToken: state.formResetToken,
                isSaving: false,
                onBack: () => _popWithResult(context),
                onEdit: (education) =>
                    context.read<EditEducationCubit>().startEdit(education),
                onDelete: (education) => _confirmDelete(context, education),
                onAdd: (params) =>
                    context.read<EditEducationCubit>().addEducation(params),
                onUpdate: (params) =>
                    context.read<EditEducationCubit>().updateEducation(params),
                onCancel: () => context.read<EditEducationCubit>().cancelEdit(),
              );
          }
        },
      ),
    );
  }
}

class _EducationContent extends StatelessWidget {
  const _EducationContent({
    required this.educations,
    required this.editingEducation,
    required this.formResetToken,
    required this.isSaving,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
    required this.onUpdate,
    required this.onCancel,
  });

  final List<EducationEntity> educations;
  final EducationEntity? editingEducation;
  final int formResetToken;
  final bool isSaving;
  final VoidCallback onBack;
  final ValueChanged<EducationEntity> onEdit;
  final ValueChanged<EducationEntity> onDelete;
  final ValueChanged<AddEducationParams> onAdd;
  final ValueChanged<UpdateEducationParams> onUpdate;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final theme = Theme.of(context);

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
      children: [
        EducationManagementHeader(onBack: onBack),
        SizedBox(height: 24.h),
        const EducationAcademicHistoryCard(),
        SizedBox(height: 28.h),
        Row(
          children: [
            Expanded(
              child: Text(
                locale.verifiedQualifications,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        if (educations.isEmpty)
          _EducationEmptyState()
        else
          for (int index = 0; index < educations.length; index++) ...[
            EducationManagementRecord(
              education: educations[index],
              onEdit: () => onEdit(educations[index]),
              onDelete: () => onDelete(educations[index]),
            ),
            if (index != educations.length - 1) SizedBox(height: 14.h),
          ],
        SizedBox(height: 24.h),
        EducationForm(
          key: ValueKey('education-form-$formResetToken'),
          initialEducation: editingEducation,
          isSaving: isSaving,
          onAdd: onAdd,
          onUpdate: onUpdate,
          onCancel: onCancel,
        ),
        SizedBox(height: 24.h),
        const EducationRecruiterVisibilityCard(),
      ],
    );
  }
}

class _EducationEmptyState extends StatelessWidget {
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
            Icons.school_outlined,
            size: 40.r,
            color: colors.onSurfaceVariant,
          ),
          SizedBox(height: 12.h),
          Text(
            locale.noEducationYet,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            locale.noEducationYetDesc,
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
