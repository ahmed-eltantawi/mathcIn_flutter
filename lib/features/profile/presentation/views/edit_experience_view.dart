import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/profile/presentation/cubits/experience_cubit/edit_experience_cubit.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/edit_experience_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditExperienceView extends StatelessWidget {
  const EditExperienceView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EditExperienceCubit>(
      create: (_) => getIt<EditExperienceCubit>()..loadExperiences(),
      child: const Scaffold(body: SafeArea(child: EditExperienceViewBody())),
    );
  }
}
