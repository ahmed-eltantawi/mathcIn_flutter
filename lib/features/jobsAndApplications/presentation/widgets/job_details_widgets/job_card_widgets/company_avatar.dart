import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_card_widgets/initial_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompanyAvatar extends StatelessWidget {
  const CompanyAvatar({
    super.key,
    required this.companyName,
    this.logoUrl,
  });

  final String companyName;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.r,
      height: 48.r,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: context.theme.dividerColor,
        ),
      ),
      child: (logoUrl == null || logoUrl!.isEmpty)
          ? InitialsText(companyName: companyName)
          : Image.network(
              logoUrl!,
              fit: BoxFit.cover,
              // لو الصورة فشلت تحميل، نرجع للـ initials تلقائيًا
              errorBuilder: (context, error, stackTrace) {
                return InitialsText(
                  companyName: companyName,
                );
              },
              // Loading placeholder بسيط لحد ما الصورة تحمل
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return SizedBox(
                  width: 20.r,
                  height: 20.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.colors.primary,
                  ),
                );
              },
            ),
    );
  }
}
