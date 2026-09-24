import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnimatedLogoWidget extends StatefulWidget {
  const AnimatedLogoWidget({super.key});

  @override
  State<AnimatedLogoWidget> createState() => _AnimatedLogoWidgetState();
}

class _AnimatedLogoWidgetState extends State<AnimatedLogoWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 150.w,
        height: 150.h,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size(150.w, 150.h),
              painter: LogoPainter(_controller.value),
            );
          },
        ),
      ),
    );
  }
}

class LogoPainter extends CustomPainter {
  LogoPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final bgPaint = Paint()
      ..color = const Color(0xFF14294F)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(30.r),
      ),
      bgPaint,
    );

    if (progress < 0.1) return;
    final p = (progress - 0.1) / 0.9;

    final greenPaint = Paint()
      ..color = const Color(0xFF5BA75B)
      ..strokeWidth = 8.w
      ..strokeCap = StrokeCap.round;

    final lineStart = Offset(size.width * 0.25, size.height * 0.75);
    final lineEnd = Offset(size.width * 0.75, size.height * 0.25);
    final currentEnd = Offset(
      lineStart.dx + (lineEnd.dx - lineStart.dx) * p,
      lineStart.dy + (lineEnd.dy - lineStart.dy) * p,
    );
    canvas.drawLine(lineStart, currentEnd, greenPaint);

    if (p > 0.5) {
      final p2 = ((p - 0.5) * 2).clamp(0.0, 1.0);

      final whiteStroke = Paint()
        ..color = Colors.white.withValues(alpha: p2)
        ..strokeWidth = 6.w
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

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
      canvas.drawPath(path, whiteStroke);

      canvas.drawCircle(
        Offset(size.width * 0.35, size.height * 0.35),
        18.w * p2,
        Paint()..color = const Color(0xFFFF6B35),
      );
      canvas.drawCircle(
        Offset(size.width * 0.65, size.height * 0.65),
        18.w * p2,
        Paint()..color = const Color(0xFFFFC107),
      );
      canvas.drawCircle(center, 12.w * p2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant LogoPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
