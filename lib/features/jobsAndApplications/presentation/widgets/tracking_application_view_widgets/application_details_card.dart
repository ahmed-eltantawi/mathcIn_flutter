import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ApplicationDetailsCard extends StatelessWidget {
  const ApplicationDetailsCard({super.key, this.onCvTap});

  final VoidCallback? onCvTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.applicationDetails,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16.h),

            _DetailRow(label: s.applied, value: s.today),

            const Divider(height: 20),

            _DetailRow(
              label: s.cv,
              customValue: InkWell(
                onTap: onCvTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 17.sp,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        'Ahmed_Mohamed_CV.pdf',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(
                              color:
                                  theme.colorScheme.primary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 20),

            _DetailRow(
              label: s.applicationMethod,
              value: 'SkillMatch',
            ),

            const Divider(height: 20),

            _DetailRow(label: s.source, value: 'LinkedIn'),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    this.value,
    this.customValue,
  });

  final String label;
  final String? value;
  final Widget? customValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(
                alpha: 0.6,
              ),
            ),
          ),
        ),
        const Spacer(),
        Flexible(
          fit: FlexFit.tight,
          child:
              customValue ??
              Text(
                value ?? '',
                textAlign: TextAlign.end,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
        ),
      ],
    );
  }
}
