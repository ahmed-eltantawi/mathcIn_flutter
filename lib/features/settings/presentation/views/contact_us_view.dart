import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/extensions/snack_bar_extensions.dart';
import 'package:MatchIn/core/widgets/custom_app_bar.dart';
import 'package:MatchIn/core/widgets/helpers/url_launcher_helper.dart';
import 'package:MatchIn/features/support/presentation/widgets/contact_method_card.dart';
import 'package:MatchIn/features/support/presentation/widgets/support_report_form.dart';
import 'package:MatchIn/features/support/support_contact_details.dart';

class ContactUsView extends StatelessWidget {
  const ContactUsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = context.theme;
    final l10n = context.l10n;

    Future<void> openContact(Future<bool> Function() open) async {
      final opened = await open();
      if (!context.mounted || opened) return;
      context.showErrorSnackBar(l10n.contactLaunchFailed);
    }

    return Scaffold(
      appBar: CustomAppBar(title: l10n.contactUs),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(18.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.primary.withValues(alpha: 0.1),
                      colors.primary.withValues(alpha: 0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.getInTouch,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      l10n.supportMessage,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              ContactMethodCard(
                icon: Icons.chat_bubble_rounded,
                iconColor: const Color(0xFF25D366),
                title: l10n.contactWhatsAppTitle,
                value: SupportContactDetails.phoneNumber,
                onTap: () => openContact(
                  () => UrlLauncherHelper.openWhatsApp(
                    SupportContactDetails.phoneNumber,
                  ),
                ),
              ),

              ContactMethodCard(
                icon: Icons.email_outlined,
                title: l10n.contactEmailTitle,
                value: SupportContactDetails.emailAddress,
                onTap: () => openContact(
                  () => UrlLauncherHelper.openEmail(
                    SupportContactDetails.emailAddress,
                  ),
                ),
              ),

              ContactMethodCard(
                icon: Icons.business_center_outlined,
                title: l10n.contactLinkedInTitle,
                value: SupportContactDetails.linkedInDisplay,
                onTap: () => openContact(
                  () =>
                      UrlLauncherHelper.open(SupportContactDetails.linkedInUrl),
                ),
              ),

              SizedBox(height: 12.h),
              const SupportReportForm(
                emailAddress: SupportContactDetails.emailAddress,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
