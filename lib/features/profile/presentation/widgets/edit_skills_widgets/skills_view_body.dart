import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/add_skill_section.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/cv_skills_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/manage_skills_button.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/manual_skills_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/skills_profile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/generated/l10n.dart';

class SkillsViewBody extends StatelessWidget {
  const SkillsViewBody({super.key});

  static const List<String> _cvSkills = <String>[
    'Flutter',
    'Dart',
    'REST APIs',
    'Git',
  ];

  static const List<String> _manualSkills = <String>[
    'Bloc',
    'Firebase',
    'GitHub',
  ];

  static const List<String> _suggestedSkills = <String>[
    'Testing',
    'CI/CD',
    'Clean Architecture',
  ];

  @override
  Widget build(BuildContext context) {
    final S locale = S.of(context);

    return ListView(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        bottom: 32.h,
      ),
      children: [
        SizedBox(height: 8.h),

        _SkillsAppBar(
          title: locale.skills,
          onBackPressed: () => Navigator.maybePop(context),
        ),

        SizedBox(height: 24.h),

        const SkillsProfileCard(),

        SizedBox(height: 24.h),

        AddSkillSection(
          suggestions: _suggestedSkills,
          onAddPressed: () {},
          onSuggestionPressed: (skill) {},
        ),

        SizedBox(height: 24.h),

        CvSkillsCard(
          skills: _cvSkills,
          onRemoveSkill: (skill) {},
        ),

        SizedBox(height: 20.h),

        ManualSkillsCard(
          skills: _manualSkills,
          onRemoveSkill: (skill) {},
        ),

        SizedBox(height: 20.h),

        ManageSkillsButton(onPressed: () {}),
      ],
    );
  }
}

class _SkillsAppBar extends StatelessWidget {
  const _SkillsAppBar({
    required this.title,
    required this.onBackPressed,
  });

  final String title;
  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context)
        .colorScheme;

    return SizedBox(
      height: 56.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(
              onPressed: onBackPressed,
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 22.sp,
              ),
              color: colors.primary,
              tooltip: MaterialLocalizations.of(context)
                  .backButtonTooltip,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
          ),
        ],
      ),
    );
  }
}
