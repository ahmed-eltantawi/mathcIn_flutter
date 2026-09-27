import 'dart:ui';

import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class LogoPainter extends CustomPainter {
  final double progress;

  LogoPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Background
    final backgroundPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(size.width * 0.2),
      ),
      backgroundPaint,
    );

    if (progress <= 0) return;

    // Green diagonal line
    final greenPaint = Paint()
      ..color = AppColors.success
      ..strokeWidth = size.width * 0.053
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final lineStart = Offset(size.width * 0.25, size.height * 0.75);
    final lineEnd = Offset(size.width * 0.75, size.height * 0.25);

    final currentEnd = Offset(
      lineStart.dx + (lineEnd.dx - lineStart.dx) * progress,
      lineStart.dy + (lineEnd.dy - lineStart.dy) * progress,
    );

    canvas.drawLine(lineStart, currentEnd, greenPaint);

    // White curved path
    if (progress > 0.5) {
      final pathProgress = ((progress - 0.5) * 2).clamp(0.0, 1.0);
      final path = Path();

      path.moveTo(size.width * 0.35, size.height * 0.35);
      path.quadraticBezierTo(
        size.width * 0.35,
        center.dy,
        center.dx,
        center.dy,
      );
      path.quadraticBezierTo(
        size.width * 0.65,
        center.dy,
        size.width * 0.65,
        size.height * 0.65,
      );

      final pathMetrics = path.computeMetrics();
      final animatedPath = Path();

      for (final metric in pathMetrics) {
        final extractPath = metric.extractPath(0, metric.length * pathProgress);
        animatedPath.addPath(extractPath, Offset.zero);
      }

      final whitePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = size.width * 0.04
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(animatedPath, whitePaint);

      // Circles
      final circleProgress = pathProgress;

      final firstCirclePaint = Paint()..color = AppColors.secondary;
      final secondCirclePaint = Paint()..color = AppColors.accent;
      final centerCirclePaint = Paint()..color = Colors.white;

      canvas.drawCircle(
        Offset(size.width * 0.35, size.height * 0.35),
        size.width * 0.12 * circleProgress,
        firstCirclePaint,
      );

      canvas.drawCircle(
        Offset(size.width * 0.65, size.height * 0.65),
        size.width * 0.12 * circleProgress,
        secondCirclePaint,
      );

      canvas.drawCircle(
        center,
        size.width * 0.08 * circleProgress,
        centerCirclePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant LogoPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
