import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/profile/presentation/cubits/career_preferences_cubit.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/career_preferences_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditCareerPreferencesView extends StatelessWidget {
  const EditCareerPreferencesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CareerPreferencesCubit>()..getCareerPreferences(),
      child: const Scaffold(body: SafeArea(child: CareerPreferencesViewBody())),
    );
  }
}
