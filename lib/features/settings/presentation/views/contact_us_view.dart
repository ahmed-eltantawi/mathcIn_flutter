import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/widgets/custom_app_bar.dart';
import 'package:MatchIn/features/settings/presentation/widgets/contact_us_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContactUsView extends StatelessWidget {
  const ContactUsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = context.theme;
    final l10n = context.l10n;

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.contactUs,
      ),
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
                      'Have questions, feedback, or need assistance? Reach out to our dedicated support channels.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              ContactUsCard(
                icon: Icons.email_outlined,
                title: l10n.contactEmailTitle,
                value: l10n.contactEmailPlaceholder,
                canCopy: true,
              ),

              ContactUsCard(
                icon: Icons.phone_outlined,
                title: l10n.contactPhoneTitle,
                value: l10n.contactPhonePlaceholder,
                canCopy: true,
              ),

              ContactUsCard(
                icon: Icons.location_on_outlined,
                title: l10n.contactAddressTitle,
                value: l10n.contactAddressPlaceholder,
                canCopy: true,
              ),

              ContactUsCard(
                icon: Icons.access_time_rounded,
                title: l10n.contactHoursTitle,
                value: l10n.contactHoursPlaceholder,
                canCopy: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
