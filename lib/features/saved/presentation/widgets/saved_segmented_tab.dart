import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/core/utils/app_text_styles.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:MatchIn/features/saved/presentation/models/saved_tab_type.dart';

class SavedSegmentedTab extends StatelessWidget {
  const SavedSegmentedTab({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  final SavedTabType activeTab;
  final ValueChanged<SavedTabType> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      child: Container(
        height: 46.h,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: const Color(0xFFEBE7DF),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTabItem(
                context: context,
                title: S.of(context).savedJobs,
                isSelected: activeTab == SavedTabType.saved,
                onTap: () => onTabChanged(SavedTabType.saved),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: _buildTabItem(
                context: context,
                title: S.of(context).applications,
                isSelected: activeTab == SavedTabType.applied,
                onTap: () => onTabChanged(SavedTabType.applied),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: AppTextStyles.body14SemiBold(
            isArabic: false,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
