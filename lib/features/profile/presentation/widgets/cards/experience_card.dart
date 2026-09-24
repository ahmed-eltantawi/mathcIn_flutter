import 'package:MatchIn/features/profile/presentation/widgets/shared/profile_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExperienceCard extends StatelessWidget {
  const ExperienceCard({
    super.key,
    required this.jobTitle,
    required this.companyName,
    required this.duration,
  });

  final String jobTitle;
  final String companyName;
  final String duration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ProfileSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Experience',
                style: theme.textTheme.titleLarge,
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.edit_outlined,
                  color: theme.colorScheme.primary,
                  size: 24.sp,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            jobTitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            companyName,
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: 4.h),
          Text(
            duration,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}