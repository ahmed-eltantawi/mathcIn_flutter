import 'package:MatchIn/features/profile/domain/entities/career_preference_entity.dart';
import 'package:MatchIn/features/profile/presentation/cubits/career_preferences_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/career_preferences_state.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/career_preferences_form.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/career_preferences_header.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/career_preferences_intro_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CareerPreferencesViewBody extends StatelessWidget {
  const CareerPreferencesViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    return BlocConsumer<CareerPreferencesCubit, CareerPreferencesState>(
      listener: (context, state) {
        if (state is CareerPreferencesActionFailure) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }

        if (state is CareerPreferencesSaveSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(locale.careerPreferencesSavedSuccessfully)),
          );
        }
      },
      builder: (context, state) {
        if (state is CareerPreferencesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CareerPreferencesFailure) {
          return Center(child: Text(state.message));
        }

        final preferences = _preferencesFromState(state);

        return ListView(
          padding: EdgeInsetsDirectional.fromSTEB(16.w, 8.h, 16.w, 32.h),
          children: [
            CareerPreferencesHeader(
              onBackPressed: () {
                Navigator.maybePop(context);
              },
              onMenuPressed: () {},
            ),

            SizedBox(height: 20.h),

            const CareerPreferencesIntroCard(),

            SizedBox(height: 16.h),

            CareerPreferencesForm(
              key: ValueKey(preferences?.id ?? 'new-preferences'),
              preferences: preferences,
            ),
          ],
        );
      },
    );
  }

  CareerPreferenceEntity? _preferencesFromState(CareerPreferencesState state) {
    if (state is CareerPreferencesSuccess) {
      return state.preferences;
    }

    if (state is CareerPreferencesSaving) {
      return state.preferences;
    }

    if (state is CareerPreferencesSaveSuccess) {
      return state.preferences;
    }

    if (state is CareerPreferencesActionFailure) {
      return state.preferences;
    }

    return null;
  }
}
