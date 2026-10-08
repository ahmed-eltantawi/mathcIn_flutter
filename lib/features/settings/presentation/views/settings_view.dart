import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:MatchIn/features/settings/presentation/widgets/settings_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<SettingsCubit>(),
      child: const Scaffold(
        body: SafeArea(
          child: SettingsViewBody(),
        ),
      ),
    );
  }
}
