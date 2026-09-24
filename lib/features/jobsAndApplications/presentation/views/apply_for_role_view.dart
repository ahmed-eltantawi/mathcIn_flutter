import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/cv_cubit.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/apply_for_role_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ApplyForRoleView extends StatelessWidget {
  const ApplyForRoleView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CvCubit>(),
      child: const Scaffold(
        body: SafeArea(child: ApplyForRoleViewBody()),
      ),
    );
  }
}
