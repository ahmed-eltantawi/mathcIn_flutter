import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoverNote extends StatelessWidget {
  const CoverNote({super.key, this.onChanged});

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                s.coverNote,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 3.h,
              ),
              decoration: BoxDecoration(
                color: theme
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Text(
                s.optional,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        TextField(
          onChanged: onChanged,
          maxLength: 300,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: s.coverNoteHint,
            counterText: '0/300 ${s.characters}',
          ),
        ),
      ],
    );
  }
}
