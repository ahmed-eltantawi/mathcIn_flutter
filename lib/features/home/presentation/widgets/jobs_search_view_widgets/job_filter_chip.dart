import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///* JobFilterChip — a single selectable filter pill with a subtle scale
///* press-down animation for polished interaction feedback.
class JobFilterChip extends StatefulWidget {
  const JobFilterChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  State<JobFilterChip> createState() => _JobFilterChipState();
}

class _JobFilterChipState extends State<JobFilterChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? context.colors.primary
                : context.colors.surface,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: widget.isSelected
                  ? context.colors.primary
                  : context.theme.dividerColor,
            ),
          ),
          child: Text(
            widget.label,
            style: context.textTheme.labelMedium?.copyWith(
              color: widget.isSelected
                  ? context.colors.onPrimary
                  : context.colors.onSurface.withValues(alpha: 0.65),
              fontWeight: widget.isSelected
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
