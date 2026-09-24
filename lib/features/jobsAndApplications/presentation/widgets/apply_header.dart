import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ApplyHeader extends StatelessWidget {
  const ApplyHeader({
    super.key,
    required this.title,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
  });

  final String title;
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 10.h,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed:
                onBack ??
                () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 52.w,
            child: Text(
              '$currentStep ${S.of(context).stepOf} $totalSteps',
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
