import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/profile/presentation/cubits/skills_cubit.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/skills_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditSkillsView extends StatelessWidget {
  const EditSkillsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SkillsCubit>()..getCandidateSkills(),
      child: const Scaffold(body: SafeArea(child: SkillsViewBody())),
    );
  }
}
