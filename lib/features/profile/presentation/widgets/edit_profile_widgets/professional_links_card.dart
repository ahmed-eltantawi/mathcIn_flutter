import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/edit_profile_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/edit_profile_field.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfessionalLinksCard extends StatelessWidget {
  const ProfessionalLinksCard({
    required this.githubController,
    required this.linkedinController,
    super.key,
  });

  final TextEditingController githubController;
  final TextEditingController linkedinController;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return EditProfileCard(
      title: locale.professionalLinks,
      child: Column(
        children: [
          EditProfileField(label: locale.github, controller: githubController),
          SizedBox(height: 16.h),
          EditProfileField(
            label: locale.linkedin,
            controller: linkedinController,
          ),
        ],
      ),
    );
  }
}
