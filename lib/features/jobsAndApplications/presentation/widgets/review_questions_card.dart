import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReviewQuestionsCard extends StatelessWidget {
  const ReviewQuestionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReviewAnswer(
          label: s.preferredWorkModeLabel,
          value: s.hybrid,
        ),
        SizedBox(height: 14.h),
        const Divider(height: 1),
        SizedBox(height: 14.h),
        _ReviewAnswer(
          label: s.expectedSalary,
          value: '15,000 EGP / month',
        ),
        SizedBox(height: 14.h),
        const Divider(height: 1),
        SizedBox(height: 14.h),
        Text(
          s.technologies,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: const [
            _TechnologyChip(label: 'Flutter'),
            _TechnologyChip(label: 'REST APIs'),
            _TechnologyChip(label: 'Firebase'),
          ],
        ),
      ],
    );
  }
}

class _ReviewAnswer extends StatelessWidget {
  const _ReviewAnswer({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Text(value, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}

class _TechnologyChip extends StatelessWidget {
  const _TechnologyChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
