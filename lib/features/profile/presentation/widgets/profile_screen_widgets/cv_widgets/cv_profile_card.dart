import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/cv_widgets/cv_empty_content.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/cv_widgets/cv_file_content.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/cv_widgets/cv_profile_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CvProfileCard extends StatelessWidget {
  const CvProfileCard({
    required this.hasCv,
    this.fileName,
    this.status,
    this.updatedText,
    this.onUpload,
    this.onView,
    this.onReplace,
    super.key,
  });

  final bool hasCv;

  final String? fileName;
  final String? status;
  final String? updatedText;

  final VoidCallback? onUpload;
  final VoidCallback? onView;
  final VoidCallback? onReplace;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CvProfileHeader(hasCv: hasCv, onEdit: onReplace),

          SizedBox(height: 12.h),

          Divider(height: 1, color: context.theme.dividerColor),

          SizedBox(height: 16.h),

          if (hasCv)
            CvFileContent(
              fileName: fileName ?? '',
              status: status,
              updatedText: updatedText,
              onView: onView,
              onReplace: onReplace,
            )
          else
            CvEmptyContent(onUpload: onUpload),
        ],
      ),
    );
  }
}
