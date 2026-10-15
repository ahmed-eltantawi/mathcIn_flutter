import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/extensions/snack_bar_extensions.dart';
import 'package:MatchIn/core/widgets/social_login_button.dart';
import 'package:MatchIn/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:MatchIn/features/auth/presentation/helpers/auth_success_handler.dart';
import 'package:MatchIn/generated/l10n.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return BlocConsumer<AuthCubit, AuthState>(
      // --- Cancellation is silent: no snackbar, no navigation ---
      listenWhen: (previous, current) =>
          current is GoogleSignInSuccess || current is GoogleSignInFailure,
      listener: (context, state) async {
        if (state is GoogleSignInSuccess) {
          await handleLoginSuccess(context, state.loginModel);
        } else if (state is GoogleSignInFailure) {
          if (context.mounted) context.showErrorSnackBar(state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is GoogleSignInLoading;
        return SocialLoginButton(
          text: locale.registerWithGoogle,
          icon: isLoading
              ? SizedBox(
                  width: 24.w,
                  height: 24.h,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.g_mobiledata, size: 28),
          // --- Cubit guard drops repeats; no-op keeps button idle ---
          onPressed: isLoading
              ? () {}
              : () => context.read<AuthCubit>().signInWithGoogle(),
        );
      },
    );
  }
}
