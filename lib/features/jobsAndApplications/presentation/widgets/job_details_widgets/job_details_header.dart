import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JobDetailsHeader extends StatelessWidget {
  const JobDetailsHeader({
    super.key,
    this.isSaved = true,
    this.onSave,
    this.onShare,
  });

  final bool isSaved;
  final VoidCallback? onSave;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 8.h,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              S.of(context).jobDetails,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: onSave ?? () {},
            visualDensity: VisualDensity.compact,
            icon: Icon(
              isSaved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: isSaved
                  ? context.colors.secondary
                  : context.colors.onSurface.withValues(
                      alpha: 0.6,
                    ),
            ),
          ),
          IconButton(
            onPressed: onShare ?? () {},
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
    );
  }
}
