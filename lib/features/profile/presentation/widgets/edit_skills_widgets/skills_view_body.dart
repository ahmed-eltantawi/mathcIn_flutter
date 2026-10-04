import 'package:MatchIn/features/profile/domain/entities/candidate_skill_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/skill_search_result_entity.dart';
import 'package:MatchIn/features/profile/presentation/cubits/skills_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/skills_state.dart';
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

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return BlocConsumer<SkillsCubit, SkillsState>(
      listener: (context, state) {
        if (state is SkillsActionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is SkillsLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is SkillsFailure) {
          return Center(child: Text(state.message));
        }

        final skills = _skillsFromState(state);
        final suggestions = _suggestionsFromState(state);

        return ListView(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            bottom: 32.h,
          ),
          children: [
            SizedBox(height: 8.h),

            SkillsAppBar(
              title: locale.skills,
              onBackPressed: () {
                Navigator.maybePop(context);
              },
            ),

            SizedBox(height: 24.h),

            const SkillsProfileCard(),

            SizedBox(height: 24.h),

            AddSkillForm(suggestions: suggestions),

            SizedBox(height: 24.h),

            BuildSkillsContent(
              skills: skills,
              onRemoveSkill: (candidateSkillId) {
                context.read<SkillsCubit>().removeSkill(
                  candidateSkillId,
                );
              },
            ),
          ],
        );
      },
    );
  }

  List<CandidateSkillEntity> _skillsFromState(
    SkillsState state,
  ) {
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

  List<SkillSearchResultEntity> _suggestionsFromState(
    SkillsState state,
  ) {
    if (state is SkillsSearchSuccess) {
      return state.suggestions;
    }

    return const [];
  }
}
