import 'package:MatchIn/features/profile/presentation/cubits/skills_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/skills_state.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/add_skill_form.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/build_skilled_content.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/skills_app_bar.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/skills_profile_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SkillsViewBody extends StatelessWidget {
  const SkillsViewBody({super.key});

  // UI only until a suggestions source/endpoint is available.
  static const List<String> _suggestedSkills = <String>[
    'Testing',
    'CI/CD',
    'Clean Architecture',
  ];

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return ListView(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 32.h),
      children: [
        SizedBox(height: 8.h),

        SkillsAppBar(
          title: locale.skills,
          onBackPressed: () => Navigator.maybePop(context),
        ),

        SizedBox(height: 24.h),

        const SkillsProfileCard(),

        SizedBox(height: 24.h),

        const AddSkillForm(suggestions: _suggestedSkills),

        SizedBox(height: 24.h),

        BlocConsumer<SkillsCubit, SkillsState>(
          listener: (context, state) {
            if (state is SkillsActionFailure) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is SkillsLoading) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            if (state is SkillsFailure) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(child: Text(state.message)),
              );
            }

            if (state is SkillsSuccess) {
              return BuildSkillsContent(
                skills: state.skills,
                onRemoveSkill: (candidateSkillId) {
                  context.read<SkillsCubit>().removeSkill(candidateSkillId);
                },
              );
            }

            if (state is SkillsActionFailure) {
              return BuildSkillsContent(
                skills: state.skills,
                onRemoveSkill: (candidateSkillId) {
                  context.read<SkillsCubit>().removeSkill(candidateSkillId);
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
