import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/features/home/presentation/widgets/setting_view_widgets/settings_header.dart';
import 'package:MatchIn/features/home/presentation/widgets/setting_view_widgets/settings_section.dart';
import 'package:MatchIn/features/home/presentation/widgets/setting_view_widgets/settings_tile.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SettingsViewBody extends StatelessWidget {
  const SettingsViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Column(
      children: [
        const SettingsHeader(),

        const Divider(height: 1),

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
                  title: s.account,
                  children: [
                    SettingsTile(
                      icon: Icons.lock_outline_rounded,
                      title: s.changePassword,
                      onTap: () {
                        context.go(AppRoutes.kChangePasswordView);
                      },
                    ),
                  ],
                ),

                SizedBox(height: 22.h),

                SettingsSection(
                  title: s.preferences,
                  children: [
                    SettingsTile(
                      icon:
                          Icons.notifications_none_rounded,
                      title: s.notifications,
                      trailing: Switch(
                        value: true,
                        onChanged: (_) {
                          // Integration:
                          // Connect to settings state later.
                        },
                      ),
                    ),
                    SettingsTile(
                      icon: Icons.language_rounded,
                      title: s.language,
                      trailingText: s.english,
                      onTap: () {
                        // Integration:
                        // Language selection later.
                      },
                    ),
                    SettingsTile(
                      icon: Icons.palette_outlined,
                      title: s.theme,
                      trailingText: s.light,
                      onTap: () {
                        // Integration:
                        // Theme selection later.
                      },
                    ),
                  ],
                ),

                SizedBox(height: 22.h),

                SettingsSection(
                  title: s.privacyAndSupport,
                  children: [
                    SettingsTile(
                      icon: Icons.verified_user_outlined,
                      title: s.privacyPolicy,
                      onTap: () {},
                    ),
                    SettingsTile(
                      icon:
                          Icons.chat_bubble_outline_rounded,
                      title: s.contactUs,
                      onTap: () {},
                    ),
                    SettingsTile(
                      icon: Icons.share_outlined,
                      title: s.followUs,
                      onTap: () {},
                    ),
                  ],
                ),

                SizedBox(height: 26.h),

                Card(
                  margin: EdgeInsets.zero,
                  child: SettingsTile(
                    icon: Icons.logout_rounded,
                    title: s.logOut,
                    isDestructive: true,
                    onTap: () {
                      // Integration:
                      // Logout logic later.
                    },
                  ),
                ),

                SizedBox(height: 48.h),

                Text(
                  s.copyright,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
