import 'package:flutter/material.dart';

class AnimatedLogoWidget extends StatefulWidget {
  const AnimatedLogoWidget({super.key});

  @override
  State<AnimatedLogoWidget> createState() => _AnimatedLogoWidgetState();
}

class _AnimatedLogoWidgetState extends State<AnimatedLogoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // الانيميشن هياخد 3 ثواني عشان يترسم
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(150, 150),
          painter: LogoPainter(_controller.value),
        );
      },
    );
  }
}

class LogoPainter extends CustomPainter {
  final double progress;

  LogoPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // بنجهز الفرشه اللي هنرسم بيها الخطوط
    final linePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final circlePaint = Paint()
      ..style = PaintingStyle.fill;

    // بنرسم الخط اللي في النص وبيكبر مع الوقت
    final path = Path();
    path.moveTo(center.dx - 30, center.dy + 30);
    path.lineTo(
      (center.dx - 30) + (60 * progress),
      (center.dy + 30) - (60 * progress),
    );
    canvas.drawPath(path, linePaint);

    // بنرسم الدواير وتظهر بالتدريج لما الخط يخلص نصه
    if (progress > 0.5) {
      // بنحسب الشفافيه عشان تظهر بنعومه
      final opacity = ((progress - 0.5) * 2).clamp(0.0, 1.0);

      circlePaint.color = Colors.orange.withOpacity(opacity);
      canvas.drawCircle(Offset(center.dx - 40, center.dy - 40), 25, circlePaint);

      circlePaint.color = Colors.yellow.withOpacity(opacity);
      canvas.drawCircle(Offset(center.dx + 40, center.dy + 40), 25, circlePaint);

      circlePaint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(center, 18, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant LogoPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}