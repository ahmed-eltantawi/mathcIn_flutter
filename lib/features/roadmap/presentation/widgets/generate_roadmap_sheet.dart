import 'package:MatchIn/core/extensions/bottom_sheet_extensions.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/roadmap/domain/entities/generate_roadmap_params.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/roadmap_cubit/roadmap_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Bottom-sheet form for AI roadmap generation.
///
/// Collects `target_role` (required in UI) and `notes` (optional);
/// `target_type` stays fixed to the only confirmed value and job IDs
/// are never sent (see [GenerateRoadmapParams]). Completes with the
/// new roadmap id on success, or null on cancel/dismiss. Validation
/// and server errors display inline; entered values are preserved.
class GenerateRoadmapSheet extends StatelessWidget {
  const GenerateRoadmapSheet({super.key});

  /// Opens the sheet. [cubit] is re-provided because pushed routes
  /// cannot see page-level providers.
  static Future<int?> show(
    BuildContext context, {
    required RoadmapCubit cubit,
  }) {
    return context.showAppBottomSheet<int>(
      title: context.l10n.generateRoadmap,
      child: BlocProvider.value(
        value: cubit,
        child: const GenerateRoadmapSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const _GenerateRoadmapForm();
  }
}

class _GenerateRoadmapForm extends StatefulWidget {
  const _GenerateRoadmapForm();

  @override
  State<_GenerateRoadmapForm> createState() => _GenerateRoadmapFormState();
}

class _GenerateRoadmapFormState extends State<_GenerateRoadmapForm> {
  late final TextEditingController _roleController;
  late final TextEditingController _notesController;
  late final ValueNotifier<String?> _roleError;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _roleController = TextEditingController();
    _notesController = TextEditingController();
    _roleError = ValueNotifier<String?>(null);
  }

  @override
  void dispose() {
    _roleController.dispose();
    _notesController.dispose();
    _roleError.dispose();
    super.dispose();
  }

  void _submit() {
    final cubit = context.read<RoadmapCubit>();
    final locale = context.l10n;
    final role = _roleController.text.trim();
    if (role.isEmpty) {
      _roleError.value = locale.required;
      return;
    }
    _roleError.value = null;
    _submitted = true;
    final notes = _notesController.text.trim();
    cubit.generateRoadmap(
      GenerateRoadmapParams(
        targetRole: role,
        notes: notes.isEmpty ? null : notes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.l10n;
    final theme = Theme.of(context);

    return Material(
      type: MaterialType.transparency,
      child: BlocConsumer<RoadmapCubit, RoadmapState>(
        listenWhen: (previous, current) =>
            _submitted &&
            (current is RoadmapDetailsSuccess ||
                current is RoadmapGenerateFailure),
        listener: (context, state) {
          if (state is RoadmapDetailsSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(locale.generationSuccess)));
            Navigator.of(context).pop(state.details.id);
          }
        },
        builder: (context, state) {
          final generating = state is RoadmapGenerating;
          final failure = state is RoadmapGenerateFailure ? state : null;
          final roleServerErrors =
              failure?.fieldErrors['target_role'] ?? const [];
          final notesServerErrors = failure?.fieldErrors['notes'] ?? const [];

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ValueListenableBuilder<String?>(
                  valueListenable: _roleError,
                  builder: (context, roleError, _) {
                    final errors = [
                      if (roleError != null && roleError.isNotEmpty) roleError,
                      ...roleServerErrors,
                    ];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          locale.targetRole,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        TextFormField(
                          controller: _roleController,
                          decoration: InputDecoration(
                            hintText: locale.targetRoleHint,
                            errorText: errors.isEmpty
                                ? null
                                : errors.join('\n'),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 16.h),
                Text(
                  locale.notes,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: locale.notesHint,
                    errorText: notesServerErrors.isEmpty
                        ? null
                        : notesServerErrors.join('\n'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                if (failure != null && failure.message.trim().isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Text(
                    failure.message.trim(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                SizedBox(height: 20.h),
                FilledButton(
                  onPressed: generating ? null : _submit,
                  child: generating
                      ? SizedBox(
                          width: 24.r,
                          height: 24.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(locale.generateRoadmap),
                ),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(locale.cancel),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
