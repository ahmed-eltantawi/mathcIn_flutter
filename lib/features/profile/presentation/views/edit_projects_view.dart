import 'package:MatchIn/features/profile/presentation/widgets/edit_projects_widgets/projects_view_body.dart';
import 'package:flutter/material.dart';

class EditProjectsView extends StatelessWidget {
  const EditProjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: ProjectsViewBody()),
    );
  }
}
