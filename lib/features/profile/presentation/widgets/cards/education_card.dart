import 'package:MatchIn/features/profile/presentation/widgets/shared/profile_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EducationCard extends StatelessWidget {
  const EducationCard({
    super.key,
    required this.universityName,
    required this.degree,
    required this.years,
  });

  final String universityName;
  final String degree;
  final String years;

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
                'Education',
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
            universityName,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            degree,
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: 4.h),
          Text(
            years,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}