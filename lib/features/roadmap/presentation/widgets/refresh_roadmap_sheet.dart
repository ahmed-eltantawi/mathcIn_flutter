import 'package:MatchIn/core/extensions/bottom_sheet_extensions.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/roadmap_cubit/roadmap_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/skill_task_cubit/skill_task_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Bottom-sheet confirmation for AI roadmap refresh.
///
/// Collects an optional `reason`; blank input is omitted from the
/// request. The confirm action is disabled while a task completion is
/// in flight. The sheet closes only on success or explicit cancel;
/// entered text survives failures for manual retry.
class RefreshRoadmapSheet extends StatelessWidget {
  const RefreshRoadmapSheet({super.key});

  /// Opens the sheet. [cubit] is re-provided because pushed routes
  /// cannot see page-level providers.
  static Future<bool?> show(
    BuildContext context, {
    required RoadmapCubit cubit,
  }) {
    return context.showAppBottomSheet<bool>(
      title: context.l10n.refreshRoadmap,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: cubit),
          BlocProvider.value(value: context.read<SkillTaskCubit>()),
        ],
        child: const _RefreshRoadmapForm(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const _RefreshRoadmapForm();
  }
}

class _RefreshRoadmapForm extends StatefulWidget {
  const _RefreshRoadmapForm();

  @override
  State<_RefreshRoadmapForm> createState() => _RefreshRoadmapFormState();
}

class _RefreshRoadmapFormState extends State<_RefreshRoadmapForm> {
  late final TextEditingController _reasonController;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_submitted) return;
    _submitted = true;
    final reason = _reasonController.text.trim();
    context.read<RoadmapCubit>().aiRefreshSelectedRoadmap(
      reason: reason.isEmpty ? null : reason,
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
                current is RoadmapAiRefreshFailure),
        listener: (context, state) {
          if (!context.mounted) return;
          if (state is RoadmapDetailsSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(locale.roadmapRefreshedSuccessfully)),
              );
            Navigator.of(context).pop(true);
          } else if (state is RoadmapAiRefreshFailure) {
            // Allow manual retry with the preserved reason.
            _submitted = false;
          }
        },
        builder: (context, state) {
          final refreshing = state is RoadmapAiRefreshing;
          final failure = state is RoadmapAiRefreshFailure ? state : null;
          final reasonServerErrors = failure?.fieldErrors['reason'] ?? const [];

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  locale.refreshRoadmapDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 18.r,
                      color: theme.colorScheme.tertiary,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        locale.refreshRoadmapWarning,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  locale.refreshReasonLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 3,
                  enabled: !refreshing,
                  decoration: InputDecoration(
                    hintText: locale.refreshReasonHint,
                    errorText: reasonServerErrors.isEmpty
                        ? null
                        : reasonServerErrors.join('\n'),
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
                BlocBuilder<SkillTaskCubit, SkillTaskState>(
                  builder: (context, skillState) {
                    final busy =
                        refreshing || skillState.completingTaskIds.isNotEmpty;
                    return FilledButton(
                      onPressed: busy ? null : _confirm,
                      child: refreshing
                          ? SizedBox(
                              width: 24.r,
                              height: 24.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(locale.confirmRefresh),
                    );
                  },
                ),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: refreshing
                      ? null
                      : () => Navigator.of(context).pop(),
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
