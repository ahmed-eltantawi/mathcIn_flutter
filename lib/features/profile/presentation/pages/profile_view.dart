import 'package:MatchIn/features/profile/presentation/widgets/cards/education_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/cards/experience_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/cards/main_profile_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale.candidateProfile,
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: const [
            MainProfileCard(
              name: 'Eng-Amira Sultan',
              jobTitle: 'Junior Flutter Developer',
              location: 'Mansoura, Egypt',
            ),
            EducationCard(
              universityName: 'Tanta University',
              degree: 'Bachelor of Computer Science',
              years: '2021 - 2025',
            ),
            ExperienceCard(
              jobTitle: 'Junior Flutter Developer',
              companyName: 'MatchIn',
              duration: '2026 - Present',
            ),
          ],
        ),
      ),
    );
  }
}