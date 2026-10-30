import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/edit_profile_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/edit_profile_field.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfessionalLinksCard extends StatelessWidget {
  const ProfessionalLinksCard({
    required this.githubController,
    required this.linkedinController,
    required this.githubValidator,
    required this.linkedinValidator,
    required this.githubFieldKey,
    required this.linkedinFieldKey,
    super.key,
  });

  final TextEditingController githubController;
  final TextEditingController linkedinController;
  final FormFieldValidator<String> githubValidator;
  final FormFieldValidator<String> linkedinValidator;
  final GlobalKey<FormFieldState<String>> githubFieldKey;
  final GlobalKey<FormFieldState<String>> linkedinFieldKey;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return EditProfileCard(
      title: locale.professionalLinks,
      child: Column(
        children: [
          EditProfileField(
            label: locale.github,
            controller: githubController,
            validator: githubValidator,
            fieldKey: githubFieldKey,
          ),
          SizedBox(height: 16.h),
          EditProfileField(
            label: locale.linkedin,
            controller: linkedinController,
            validator: linkedinValidator,
            fieldKey: linkedinFieldKey,
          ),
        ],
      ),
    );
  }
}
