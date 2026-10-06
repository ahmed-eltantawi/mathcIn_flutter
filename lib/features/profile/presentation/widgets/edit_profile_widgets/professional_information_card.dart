import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/edit_profile_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/edit_profile_dropdown.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/edit_profile_field.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfessionalInformationCard extends StatelessWidget {
  const ProfessionalInformationCard({
    required this.jobTitleController,
    required this.militaryStatus,
    required this.militaryStatusItems,
    required this.onMilitaryStatusChanged,
    super.key,
  });

  final TextEditingController jobTitleController;
  final String? militaryStatus;
  final Map<String, String> militaryStatusItems;
  final ValueChanged<String?> onMilitaryStatusChanged;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return EditProfileCard(
      title: locale.professionalInformation,
      child: Column(
        children: [
          EditProfileField(
            label: locale.jobTitle,
            controller: jobTitleController,
          ),
          SizedBox(height: 16.h),
          EditProfileDropdown(
            label: locale.militaryStatus,
            value: militaryStatus,
            items: militaryStatusItems,
            onChanged: onMilitaryStatusChanged,
          ),
        ],
      ),
    );
  }
}
