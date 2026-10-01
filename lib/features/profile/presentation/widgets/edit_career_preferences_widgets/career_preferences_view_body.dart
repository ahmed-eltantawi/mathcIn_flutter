import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/career_goal_section.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/career_preferences_actions.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/career_preferences_header.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/career_preferences_intro_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/experience_level_section.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/job_type_section.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/preferred_location_section.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/target_role_section.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/work_mode_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CareerPreferencesViewBody extends StatelessWidget {
  const CareerPreferencesViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(
        16.w,
        8.h,
        16.w,
        32.h,
      ),
      children: [
        CareerPreferencesHeader(
          onBackPressed: () => Navigator.maybePop(context),
          onMenuPressed: () {},
        ),
        SizedBox(height: 20.h),

        const CareerPreferencesIntroCard(),

        SizedBox(height: 16.h),

        TargetRoleSection(
          targetRole: 'Flutter Developer',
          suggestedRoles: const [
            'Mobile Developer',
            'Flutter Developer',
            'Junior Software Engineer',
          ],
          selectedSuggestedRole: 'Flutter Developer',
          onRoleChanged: (_) {},
          onClear: () {},
          onSuggestedRolePressed: (_) {},
        ),

        SizedBox(height: 16.h),

        ExperienceLevelSection(
          selectedLevel: 'Entry Level',
          onSelected: (_) {},
        ),

        SizedBox(height: 16.h),

        JobTypeSection(
          selectedTypes: const {'Full-time', 'Internship'},
          onSelected: (_, _) {},
        ),

        SizedBox(height: 16.h),

        WorkModeSection(
          selectedModes: const {'Remote', 'Hybrid'},
          onSelected: (_, _) {},
        ),

        SizedBox(height: 16.h),

        PreferredLocationSection(
          country: 'Egypt',
          state: 'Cairo',
          city: 'Cairo & Giza',
          openToAnywhere: false,
          onCountryPressed: () {},
          onStatePressed: () {},
          onCityPressed: () {},
          onOpenToAnywhereChanged: (_) {},
        ),

        SizedBox(height: 16.h),

        const CareerGoalSection(),

        SizedBox(height: 28.h),

        CareerPreferencesActions(
          onSavePressed: () {},
          onCancelPressed: () =>
              Navigator.maybePop(context),
        ),
      ],
    );
  }
}
