import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/skills_view_body.dart';
import 'package:flutter/material.dart';

class EditSkillsView extends StatelessWidget {
  const EditSkillsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: SkillsViewBody()),
    );
  }
}
