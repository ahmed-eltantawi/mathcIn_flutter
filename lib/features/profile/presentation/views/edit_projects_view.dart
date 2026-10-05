import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/profile/presentation/cubits/projects_cubit.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_projects_widgets/projects_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProjectsView extends StatelessWidget {
  const EditProjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProjectsCubit>()..getProjects(),
      child: const Scaffold(
        body: SafeArea(child: ProjectsViewBody()),
      ),
    );
  }
}
