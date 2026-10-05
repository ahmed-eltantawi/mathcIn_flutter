import 'package:MatchIn/features/profile/domain/entities/candidate_skill_entity.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/manage_skills_button.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/manual_skills_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BuildSkillsContent extends StatelessWidget {
  const BuildSkillsContent({
    required this.skills,
    required this.onRemoveSkill,
    super.key,
  });

  final List<CandidateSkillEntity> skills;
  final ValueChanged<int> onRemoveSkill;

  @override
  Widget build(BuildContext context) {
    final manualSkills = skills
        .where((skill) => skill.source == 'manual')
        .toList();

    return Column(
      children: [
        if (manualSkills.isNotEmpty)
          ManualSkillsCard(skills: manualSkills, onRemoveSkill: onRemoveSkill),

        if (manualSkills.isNotEmpty) SizedBox(height: 20.h),

        ManageSkillsButton(onPressed: () {}),
      ],
    );
  }
}
