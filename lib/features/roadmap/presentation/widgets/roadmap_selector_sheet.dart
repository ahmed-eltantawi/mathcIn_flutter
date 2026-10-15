import 'package:MatchIn/core/extensions/bottom_sheet_extensions.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/roadmap_cubit/roadmap_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/generate_roadmap_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Bottom-sheet list of loaded roadmaps for selection.
///
/// Dumb UI over [RoadmapCubit] cached items: rows show backend title,
/// target role, status, and completion verbatim. Load More appends the
/// next page through the cubit; failures keep cached rows and show a
/// snackbar instead of disturbing the details view behind the sheet.
class RoadmapSelectorSheet extends StatelessWidget {
  const RoadmapSelectorSheet({super.key});

  /// Opens the sheet. Completes with the selected roadmap id,
  /// or null on dismiss. [cubit] is re-provided into the sheet route
  /// because pushed routes cannot see page-level providers.
  static Future<int?> show(
    BuildContext context, {
    required RoadmapCubit cubit,
  }) {
    return context.showAppBottomSheet<int>(
      title: context.l10n.selectRoadmap,
      child: BlocProvider.value(
        value: cubit,
        child: const _RoadmapSelectorContent(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Only constructed through [show].
    return const _RoadmapSelectorContent();
  }
}

class _RoadmapSelectorContent extends StatelessWidget {
  const _RoadmapSelectorContent();

  @override
  Widget build(BuildContext context) {
    final locale = context.l10n;
    final theme = Theme.of(context);

    // Material ancestor for ListTile ink effects.
    return Material(
      type: MaterialType.transparency,
      child: BlocBuilder<RoadmapCubit, RoadmapState>(
        builder: (context, state) {
          final cubit = context.read<RoadmapCubit>();
          final items = cubit.cachedRoadmaps;
          final selectedId = cubit.selectedRoadmapId;

          if (items.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Center(child: Text(locale.noRoadmaps)),
            );
          }

          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return ListView.builder(
                controller: scrollController,
                itemCount: items.length + (cubit.hasMorePages ? 1 : 0) + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      leading: Icon(
                        Icons.add_circle_outline_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        locale.generateRoadmap,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      onTap: () async {
                        final newId = await GenerateRoadmapSheet.show(
                          context,
                          cubit: cubit,
                        );
                        if (newId == null || !context.mounted) return;
                        Navigator.of(context).pop();
                      },
                    );
                  }
                  final itemIndex = index - 1;
                  if (itemIndex >= items.length) {
                    return Padding(
                      padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
                      child: Center(
                        child: TextButton.icon(
                          onPressed: () async {
                            final ok = await cubit.loadMoreRoadmaps();
                            if (!ok && context.mounted) {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(locale.somethingWentWrong),
                                  ),
                                );
                            }
                          },
                          icon: const Icon(Icons.expand_more_rounded),
                          label: Text(locale.loadMore),
                        ),
                      ),
                    );
                  }
                  final roadmap = items[itemIndex];
                  final selected = roadmap.id == selectedId;
                  return ListTile(
                    title: Text(
                      roadmap.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      _subtitle(
                        roadmap.targetRole,
                        roadmap.status,
                        roadmap.completionPercentage,
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: selected
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(roadmap.id),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _subtitle(String? targetRole, String? status, double completion) {
    final parts = [
      if (targetRole != null && targetRole.trim().isNotEmpty) targetRole.trim(),
      if (status != null && status.trim().isNotEmpty) status.trim(),
      _percent(completion),
    ];
    return parts.join(' • ');
  }

  String _percent(double completion) {
    final whole = completion.truncateToDouble() == completion;
    return '${whole ? completion.toInt() : completion}%';
  }
}
