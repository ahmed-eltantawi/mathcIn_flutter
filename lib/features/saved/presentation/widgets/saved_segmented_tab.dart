import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';
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
          color: context.colors.surfaceContainerHighest,
          border: Border.all(
            color: context.colors.outline.withValues(alpha: 0.2),
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
          color: isSelected ? context.colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.colors.shadow.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected
                ? context.colors.onPrimary
                : context.colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
