import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_node.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/active_task_indicator.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/roadmap_node_depth.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/roadmap_node_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoadmapTaskNode extends StatefulWidget {
  const RoadmapTaskNode({
    super.key,
    required this.node,
    required this.onTap,
    this.circleKey,
  });

  final RoadmapNode node;
  final VoidCallback onTap;
  final Key? circleKey;

  @override
  State<RoadmapTaskNode> createState() => _RoadmapTaskNodeState();
}

class _RoadmapTaskNodeState extends State<RoadmapTaskNode> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    if (widget.node.status == RoadmapTaskStatus.locked) return;
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.node.status == RoadmapTaskStatus.locked) return;
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    if (widget.node.status == RoadmapTaskStatus.locked) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;
    final status = widget.node.status;

    final isCompleted = status == RoadmapTaskStatus.completed;
    final isActive = status == RoadmapTaskStatus.active;
    final isLocked = status == RoadmapTaskStatus.locked;

    final double circleSize = isActive
        ? 76.r
        : isCompleted
        ? 68.r
        : 64.r;
    final double depthHeight = isActive
        ? 14.h
        : isCompleted
        ? 9.h
        : 4.h;
    final double pressTranslation = _isPressed
        ? (isActive ? 11.h : depthHeight - 2.h)
        : 0.0;

    final Color baseColor = _getNodeColor(context, status);
    final Color depthColor = _getDepthColor(context, status);
    final Color iconColor = isLocked
        ? colors.onSurfaceVariant
        : colors.onPrimary;

    final double ringSize = isActive ? 84.r : circleSize;
    final double ringOffset = isActive ? (ringSize - circleSize) / 2 : 0.0;
    final double totalWidth = isActive ? ringSize : circleSize;
    final double nodeAreaHeight =
        (isActive ? ringSize : circleSize) + depthHeight;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isActive) ...[const ActiveTaskIndicator(), SizedBox(height: 10.h)],
        GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            key: widget.circleKey,
            width: totalWidth,
            height: nodeAreaHeight,
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                if (isActive)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 80),
                    curve: Curves.easeOutCubic,
                    top: ringOffset + pressTranslation,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Container(
                        width: ringSize,
                        height: ringSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.primary.withValues(alpha: 0.30),
                            width: 3.w,
                          ),
                        ),
                      ),
                    ),
                  ),

                // 3D Depth Layer
                Positioned(
                  top: ringOffset + depthHeight,
                  child: RoadmapNodeDepth(
                    size: circleSize,
                    color: depthColor,
                    isActive: isActive,
                    isPressed: _isPressed,
                  ),
                ),

                // Top Surface Layer
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 80),
                  curve: Curves.easeOutCubic,
                  top: ringOffset + pressTranslation,
                  child: RoadmapNodeSurface(
                    size: circleSize,
                    baseColor: baseColor,
                    isActive: isActive,
                    isLocked: isLocked,
                    iconData: _getNodeIcon(widget.node),
                    iconColor: iconColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 14.h),
        SizedBox(
          width: 140.w,
          child: Text(
            widget.node.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: isActive ? 15.sp : 14.sp,
              color: isLocked ? colors.onSurfaceVariant : colors.onSurface,
            ),
          ),
        ),
        if (widget.node.subtitle != null) ...[
          SizedBox(height: 2.h),
          SizedBox(
            width: 140.w,
            child: Text(
              widget.node.subtitle!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Color _getNodeColor(BuildContext context, RoadmapTaskStatus status) {
    final colors = context.colors;
    switch (status) {
      case RoadmapTaskStatus.completed:
        return const Color(0xFF4F7A5A);
      case RoadmapTaskStatus.active:
        return colors.primary;
      case RoadmapTaskStatus.locked:
        return colors.surfaceContainerHighest;
    }
  }

  Color _getDepthColor(BuildContext context, RoadmapTaskStatus status) {
    switch (status) {
      case RoadmapTaskStatus.completed:
        return const Color(0xFF196F3D);
      case RoadmapTaskStatus.active:
        return const Color(0xFF1F365C);
      case RoadmapTaskStatus.locked:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData _getNodeIcon(RoadmapNode node) {
    if (node.status == RoadmapTaskStatus.completed) {
      return Icons.check_rounded;
    }
    if (node.status == RoadmapTaskStatus.locked) {
      return Icons.lock_rounded;
    }
    if (node.icon is IconData) {
      return node.icon as IconData;
    }
    return Icons.play_arrow_rounded;
  }
}

typedef RoadmapNodeWidget = RoadmapTaskNode;
