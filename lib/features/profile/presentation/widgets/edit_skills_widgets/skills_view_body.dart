import 'package:MatchIn/core/widgets/error/app_error.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_skill_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/skill_search_result_entity.dart';
import 'package:MatchIn/features/profile/presentation/cubits/skills_cubit/skills_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/skills_cubit/skills_state.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/add_skill_form.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/build_skills_content.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/skills_app_bar.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/skills_profile_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SkillsViewBody extends StatelessWidget {
  const SkillsViewBody({super.key});

  void _popWithResult(BuildContext context) {
    Navigator.of(context).pop(context.read<SkillsCubit>().hasChanges);
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    // Single-pop exit guard: programmatic pops (header Back) complete
    // directly with hasChanges, while system Back/gesture is vetoed here
    // and completed once through the same result. The didPop guard makes
    // a repeated callback a no-op, so no loop or duplicate pop is possible.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(context.read<SkillsCubit>().hasChanges);
      },
      child: BlocConsumer<SkillsCubit, SkillsState>(
        listenWhen: (previous, current) => current is SkillsActionFailure,
        listener: (context, state) {
          if (state is SkillsActionFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is SkillsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SkillsFailure) {
            return ListView(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 32.h),
              children: [
                SizedBox(height: 8.h),
                SkillsAppBar(
                  title: locale.skills,
                  onBackPressed: () => _popWithResult(context),
                ),
                SizedBox(height: 24.h),
                AppErrorWidget(
                  message: state.message,
                  onRetry: () =>
                      context.read<SkillsCubit>().getCandidateSkills(),
                ),
              ],
            );
          }

          final skills = _skillsFromState(state);
          final suggestions = _suggestionsFromState(state);

          return ListView(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 32.h),
            children: [
              SizedBox(height: 8.h),

              SkillsAppBar(
                title: locale.skills,
                onBackPressed: () => _popWithResult(context),
              ),

              SizedBox(height: 24.h),

              const SkillsProfileCard(),

              SizedBox(height: 24.h),

              AddSkillForm(suggestions: suggestions),

              SizedBox(height: 24.h),

              BuildSkillsContent(
                skills: skills,
                onRemoveSkill: (candidateSkillId) {
                  context.read<SkillsCubit>().removeSkill(candidateSkillId);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  List<CandidateSkillEntity> _skillsFromState(SkillsState state) {
    if (state is SkillsSuccess) {
      return state.skills;
    }

    if (state is SkillsSearchSuccess) {
      return state.skills;
    }

    if (state is SkillsSearchCleared) {
      return state.skills;
    }

    if (state is SkillsActionFailure) {
      return state.skills;
    }

    return const [];
  }

  List<SkillSearchResultEntity> _suggestionsFromState(SkillsState state) {
    if (state is SkillsSearchSuccess) {
      return state.suggestions;
    }

    return const [];
  }
}
