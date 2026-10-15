import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_cached_candidate_profile_use_case.dart';
import 'package:MatchIn/generated/l10n.dart';

class ReviewCvCard extends StatefulWidget {
  const ReviewCvCard({
    super.key,
    this.fileName,
    this.fileSize,
  });

  final String? fileName;
  final String? fileSize;

  @override
  State<ReviewCvCard> createState() => _ReviewCvCardState();
}

class _ReviewCvCardState extends State<ReviewCvCard> {
  String? _loadedFileName;

  @override
  void initState() {
    super.initState();
    if (widget.fileName != null && widget.fileName!.isNotEmpty) {
      _loadedFileName = widget.fileName;
    } else {
      _loadCachedCv();
    }
  }

  @override
  void didUpdateWidget(covariant ReviewCvCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fileName != oldWidget.fileName && widget.fileName != null) {
      setState(() {
        _loadedFileName = widget.fileName;
      });
    }
  }

  Future<void> _loadCachedCv() async {
    try {
      final result = await getIt<GetCachedCandidateProfileUseCase>()();
      if (!mounted) return;
      result.fold(
        (_) {},
        (profile) {
          final doc = profile?.cvDocument;
          if (doc != null) {
            setState(() {
              _loadedFileName = doc.originalFilename ?? doc.fileName;
            });
          }
        },
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    final resolvedFileName = widget.fileName ?? _loadedFileName;
    final hasCv = resolvedFileName != null && resolvedFileName.isNotEmpty;
    final displayName = hasCv ? resolvedFileName : s.cvResume;
    final displaySubtitle = hasCv
        ? (widget.fileSize ?? 'PDF')
        : s.cvUploadRequirements;

    final badgeColor = hasCv ? AppColors.forestGreen : theme.colorScheme.error;
    final badgeText = hasCv ? '● ${s.ready}' : '● ${s.required}';

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(
              Icons.description_outlined,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  displaySubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 9.w,
              vertical: 4.h,
            ),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              badgeText,
              style: theme.textTheme.labelSmall?.copyWith(
                color: badgeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
