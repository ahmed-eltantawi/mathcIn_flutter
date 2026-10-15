import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/profile/presentation/cubits/profile_cubit/edit_profile_cubit.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/edit_profile_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EditProfileCubit>(
      create: (_) =>
          getIt<EditProfileCubit>()..loadProfile(),
      child: const Scaffold(
        body: SafeArea(child: EditProfileViewBody()),
      ),
    );
  }
}
