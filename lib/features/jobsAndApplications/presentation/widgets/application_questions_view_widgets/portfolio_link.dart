import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PortfolioLink extends StatelessWidget {
  const PortfolioLink({super.key, this.onChanged});

  final ValueChanged<String>? onChanged;

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
              s.portfolioOrProjectLink,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              onChanged: onChanged,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.link_rounded),
                hintText: s.portfolioLinkHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
