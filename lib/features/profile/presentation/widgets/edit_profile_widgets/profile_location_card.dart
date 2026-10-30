import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/edit_profile_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/edit_profile_field.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';

class ProfileLocationCard extends StatelessWidget {
  const ProfileLocationCard({
    required this.controller,
    super.key,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return EditProfileCard(
      title: locale.location,
      child: EditProfileField(
        label: locale.location,
        hintText: locale.location,
        controller: controller,
      ),
    );
  }
}
