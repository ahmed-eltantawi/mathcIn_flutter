import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/profile/presentation/cubits/profile_cubit/profile_cubit.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/profile_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    const profile = Scaffold(body: SafeArea(child: ProfileViewBody()));
    try {
      context.read<ProfileCubit>();
      return profile;
    } on ProviderNotFoundException {
      // Keep this view usable in isolated routes and widget previews. The app
      // normally supplies the shared, app-scoped ProfileCubit above the router.
      return BlocProvider<ProfileCubit>(
        create: (_) => getIt<ProfileCubit>()..getCandidateProfile(),
        child: profile,
      );
    }
  }
}
