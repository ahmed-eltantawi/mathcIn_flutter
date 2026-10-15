import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/profile/presentation/cubits/education_cubit/edit_education_cubit.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_education_widgets/edit_education_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditEducationView extends StatelessWidget {
  const EditEducationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EditEducationCubit>(
      create: (_) => getIt<EditEducationCubit>()..loadEducations(),
      child: const Scaffold(body: SafeArea(child: EditEducationViewBody())),
    );
  }
}
