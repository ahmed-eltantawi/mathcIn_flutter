import 'package:MatchIn/core/widgets/error/app_error.dart';
import 'package:MatchIn/features/profile/domain/entities/career_preference_entity.dart';
import 'package:MatchIn/features/profile/presentation/cubits/career_cubit/career_preferences_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/career_cubit/career_preferences_state.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/career_preferences_form.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/career_preferences_header.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/career_preferences_intro_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CareerPreferencesViewBody extends StatelessWidget {
  const CareerPreferencesViewBody({super.key});

  void _popWithResult(BuildContext context) {
    Navigator.of(context)
        .pop(context.read<CareerPreferencesCubit>().hasChanges);
  }

  @override
  Widget build(BuildContext context) {
    // Single-pop exit guard: programmatic pops (header Back, form
    // Cancel) complete directly with hasChanges, while system
    // Back/gesture is vetoed here and completed once through the same
    // result. The didPop guard makes a repeated callback a no-op, so
    // no loop or duplicate pop is possible.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context)
            .pop(context.read<CareerPreferencesCubit>().hasChanges);
      },
      child: BlocConsumer<CareerPreferencesCubit, CareerPreferencesState>(
        listenWhen: (previous, current) =>
            current is CareerPreferencesActionFailure ||
            current is CareerPreferencesSaveSuccess,
        listener: (context, state) {
          final locale = S.of(context);
          if (state is CareerPreferencesActionFailure) {
            final message = state.message.trim().isEmpty
                ? locale.somethingWentWrong
                : state.message;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
            return;
          }
          if (state is CareerPreferencesSaveSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(locale.careerPreferencesSavedSuccessfully),
                ),
              );
          }
        },
        builder: (context, state) {
          switch (state) {
            case CareerPreferencesInitial():
            case CareerPreferencesLoading():
              return const Center(child: CircularProgressIndicator());
            case CareerPreferencesFailure():
              return ListView(
                padding: EdgeInsetsDirectional.fromSTEB(16.w, 8.h, 16.w, 32.h),
                children: [
                  CareerPreferencesHeader(
                    onBackPressed: () => _popWithResult(context),
                  ),
                  SizedBox(height: 20.h),
                  AppErrorWidget(
                    message: state.message,
                    onRetry: () => context
                        .read<CareerPreferencesCubit>()
                        .getCareerPreferences(),
                  ),
                ],
              );
            case CareerPreferencesSaving():
              return _CareerPreferencesContent(
                preferences: state.preferences,
                isSaving: true,
                onBack: () => _popWithResult(context),
              );
            case CareerPreferencesActionFailure():
              return _CareerPreferencesContent(
                preferences: state.preferences,
                isSaving: false,
                onBack: () => _popWithResult(context),
              );
            case CareerPreferencesSuccess():
              return _CareerPreferencesContent(
                preferences: state.preferences,
                isSaving: false,
                onBack: () => _popWithResult(context),
              );
            case CareerPreferencesSaveSuccess():
              return _CareerPreferencesContent(
                preferences: state.preferences,
                isSaving: false,
                onBack: () => _popWithResult(context),
              );
          }
        },
      ),
    );
  }
}

class _CareerPreferencesContent extends StatelessWidget {
  const _CareerPreferencesContent({
    required this.preferences,
    required this.isSaving,
    required this.onBack,
  });

  final CareerPreferenceEntity? preferences;
  final bool isSaving;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(16.w, 8.h, 16.w, 32.h),
      children: [
        CareerPreferencesHeader(onBackPressed: onBack),

        SizedBox(height: 20.h),

        const CareerPreferencesIntroCard(),

        SizedBox(height: 16.h),

        CareerPreferencesForm(
          key: ValueKey(preferences?.id ?? 'new-preferences'),
          preferences: preferences,
          isSaving: isSaving,
        ),
      ],
    );
  }
}
