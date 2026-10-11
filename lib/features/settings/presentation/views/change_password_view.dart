import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/core/widgets/custom_app_bar.dart';
import 'package:MatchIn/features/settings/presentation/cubit/change_password_cubit.dart';
import 'package:MatchIn/features/settings/presentation/widgets/change_password_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChangePasswordCubit>(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: context.l10n.changePassword,
        ),
        body: const SafeArea(
          child: ChangePasswordViewBody(),
        ),
      ),
    );
  }
}
