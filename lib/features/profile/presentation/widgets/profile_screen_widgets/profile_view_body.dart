import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/profile_header.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/profile_overview_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileViewBody extends StatelessWidget {
  const ProfileViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const ProfileHeader(),

        SizedBox(height: 16.h),

        const ProfileOverviewCard(),

        // Education
        // Experience
        // Skills
        // Projects
        // CV
        // Career Preferences
      ],
    );
  }
}
