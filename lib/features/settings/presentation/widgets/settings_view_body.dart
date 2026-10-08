import 'package:MatchIn/core/extensions/bottom_sheet_extensions.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/extensions/snack_bar_extensions.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:MatchIn/features/settings/presentation/cubit/settings_state.dart';
import 'package:MatchIn/features/settings/presentation/widgets/language_selection_bottom_sheet.dart';
import 'package:MatchIn/features/settings/presentation/widgets/logout_confirmation_dialog.dart';
import 'package:MatchIn/features/settings/presentation/widgets/settings_header.dart';
import 'package:MatchIn/features/settings/presentation/widgets/settings_section.dart';
import 'package:MatchIn/features/settings/presentation/widgets/settings_tile.dart';
import 'package:MatchIn/features/settings/presentation/widgets/theme_selection_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SettingsViewBody extends StatelessWidget {
  const SettingsViewBody({super.key});

  String _getThemeLabel(BuildContext context, ThemeMode mode) {
    final l10n = context.l10n;
    switch (mode) {
      case ThemeMode.light:
        return l10n.light;
      case ThemeMode.dark:
        return l10n.dark;
      case ThemeMode.system:
        return l10n.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;
    final colors = context.colors;

    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state.isLoggedOut) {
          context.go(AppRoutes.kLoginView);
        } else if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          context.showErrorSnackBar(state.errorMessage!);
        }
      },
      builder: (context, state) {
        final cubit = context.read<SettingsCubit>();

        return Column(
          children: [
            const SettingsHeader(),

            Divider(
              height: 1,
              color: colors.outline.withValues(alpha: 0.12),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 20.h,
                ),
                child: Column(
                  children: [
                    SettingsSection(
                      title: l10n.account,
                      children: [
                        SettingsTile(
                          icon: Icons.lock_outline_rounded,
                          title: l10n.changePassword,
                          onTap: () {
                            context.push(AppRoutes.kChangePasswordView);
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 22.h),

                    SettingsSection(
                      title: l10n.preferences,
                      children: [
                        SettingsTile(
                          icon: Icons.notifications_none_rounded,
                          title: l10n.notifications,
                          trailing: Switch.adaptive(
                            value: state.isNotificationsEnabled,
                            activeThumbColor: colors.primary,
                            onChanged: (value) {
                              cubit.toggleNotifications(value);
                            },
                          ),
                        ),
                        SettingsTile(
                          icon: Icons.language_rounded,
                          title: l10n.language,
                          trailingText: state.languageCode == 'ar'
                              ? l10n.arabic
                              : l10n.english,
                          onTap: () {
                            context.showAppBottomSheet(
                              title: l10n.selectLanguage,
                              child: LanguageSelectionBottomSheet(
                                currentLanguageCode: state.languageCode,
                                onLanguageSelected: (langCode) {
                                  cubit.setLanguage(langCode);
                                },
                              ),
                            );
                          },
                        ),
                        SettingsTile(
                          icon: Icons.palette_outlined,
                          title: l10n.theme,
                          trailingText: _getThemeLabel(context, state.themeMode),
                          onTap: () {
                            context.showAppBottomSheet(
                              title: l10n.selectTheme,
                              child: ThemeSelectionBottomSheet(
                                currentThemeMode: state.themeMode,
                                onThemeSelected: (mode) {
                                  cubit.setTheme(mode);
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 22.h),

                    SettingsSection(
                      title: l10n.privacyAndSupport,
                      children: [
                        SettingsTile(
                          icon: Icons.verified_user_outlined,
                          title: l10n.privacyPolicy,
                          onTap: () {
                            context.push(AppRoutes.kPrivacyPolicyView);
                          },
                        ),
                        SettingsTile(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: l10n.contactUs,
                          onTap: () {
                            context.push(AppRoutes.kContactUsView);
                          },
                        ),
                        SettingsTile(
                          icon: Icons.share_outlined,
                          title: l10n.followUs,
                          onTap: () {
                            context.push(AppRoutes.kFollowUsView);
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 26.h),

                    Card(
                      margin: EdgeInsets.zero,
                      elevation: 0,
                      color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        side: BorderSide(
                          color: colors.outline.withValues(alpha: 0.15),
                        ),
                      ),
                      child: SettingsTile(
                        icon: Icons.logout_rounded,
                        title: l10n.logOut,
                        isDestructive: true,
                        trailing: state.isLoading
                            ? SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.error,
                                ),
                              )
                            : null,
                        onTap: state.isLoading
                            ? null
                            : () {
                                showDialog<void>(
                                  context: context,
                                  builder: (dialogContext) =>
                                      LogoutConfirmationDialog(
                                    onConfirm: () => cubit.logout(),
                                  ),
                                );
                              },
                      ),
                    ),

                    SizedBox(height: 48.h),

                    Text(
                      l10n.copyright,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),

                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
