import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/edit_experience_view_body.dart';
import 'package:flutter/material.dart';

class EditExperienceView extends StatelessWidget {
  const EditExperienceView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: EditExperienceViewBody()),
    );
  }
}
