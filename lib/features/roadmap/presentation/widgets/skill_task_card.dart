import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/roadmap/data/models/skill_task.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/resource_button.dart';

class SkillTaskCard extends StatefulWidget {
  const SkillTaskCard({
    super.key,
    required this.task,
    this.onToggleComplete,
    this.isBusy = false,
  });

  final SkillTask task;

  /// Null disables completion interaction: completed tasks, tasks without
  /// a backend id, and tasks with a request in flight pass null.
  final VoidCallback? onToggleComplete;

  /// Shows a progress indicator in the checkbox. Interaction stays
  /// disabled while true.
  final bool isBusy;

  @override
  State<SkillTaskCard> createState() => _SkillTaskCardState();
}

class _SkillTaskCardState extends State<SkillTaskCard> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCompleted = widget.task.isCompleted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isCompleted
            ? colors.surfaceContainerHighest.withValues(alpha: 0.6)
            : colors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF4F7A5A).withValues(alpha: 0.4)
              : colors.outline,
          width: 1.w,
        ),
        boxShadow: [
          if (!_isExpanded)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6.r,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleExpanded,
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TaskHeaderRow(
                  task: widget.task,
                  isExpanded: _isExpanded,
                  onToggleComplete: widget.onToggleComplete,
                  isBusy: widget.isBusy,
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: _isExpanded
                      ? _TaskExpandedDetails(task: widget.task)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskHeaderRow extends StatelessWidget {
  const _TaskHeaderRow({
    required this.task,
    required this.isExpanded,
    this.onToggleComplete,
    this.isBusy = false,
  });

  final SkillTask task;
  final bool isExpanded;
  final VoidCallback? onToggleComplete;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;
    final isCompleted = task.isCompleted;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: isBusy ? null : onToggleComplete,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 26.r,
            height: 26.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? const Color(0xFF4F7A5A) : Colors.transparent,
              border: Border.all(
                color: isCompleted ? const Color(0xFF4F7A5A) : colors.outline,
                width: 2.w,
              ),
            ),
            child: isBusy
                ? Padding(
                    padding: EdgeInsets.all(5.r),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      color: colors.primary,
                    ),
                  )
                : isCompleted
                ? Icon(Icons.check_rounded, size: 16.r, color: Colors.white)
                : null,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: isCompleted
                      ? colors.onSurfaceVariant
                      : colors.onSurface,
                  decoration: isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14.r,
                    color: colors.onSurfaceVariant,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    task.duration,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 12.sp,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        AnimatedRotation(
          turns: isExpanded ? 0.25 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Icon(
            Icons.chevron_right_rounded,
            size: 24.r,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _TaskExpandedDetails extends StatelessWidget {
  const _TaskExpandedDetails({required this.task});

  final SkillTask task;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),
        Divider(color: colors.outline, height: 1.h),
        SizedBox(height: 12.h),
        if (task.description != null && task.description!.isNotEmpty) ...[
          Text(
            task.description!,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 13.sp,
              color: colors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          SizedBox(height: 14.h),
        ],
        if (task.resources.isNotEmpty) ...[
          Text(
            'Resources',
            style: textTheme.labelMedium?.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: colors.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: task.resources.map((res) {
              return ResourceButton(resource: res);
            }).toList(),
          ),
        ],
      ],
    );
  }
}
