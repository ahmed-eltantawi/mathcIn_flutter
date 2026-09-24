import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/onbording/presentation/widgets/dashed_line_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CareerPathHeroWidget extends StatelessWidget {
  const CareerPathHeroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Ambient Editorial Background Glow
          Container(
            width: 288.w,
            height: 288.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEAE8E4).withValues(alpha: 0.4),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEAE8E4).withValues(alpha: 0.5),
                  blurRadius: 32,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),

          // Cards Container with Dashed Horizontal Connector
          SizedBox(
            width: 320.w,
            height: 80.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Dashed Connector Line behind cards
                Positioned(
                  left: 32.w,
                  right: 32.w,
                  child: CustomPaint(
                    size: Size(256.w, 1.h),
                    painter: const DashedLinePainter(
                      color: Color(0xFFC4C6CF),
                      dashWidth: 4,
                      dashSpace: 4,
                    ),
                  ),
                ),

                // The 3 Flat Cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFeatureCard(
                      context: context,
                      icon: Icons.description_outlined,
                      iconColor: context.colors.primary,
                      label: 'CV',
                    ),
                    _buildFeatureCard(
                      context: context,
                      icon: Icons.work_outline_rounded,
                      iconColor: context.colors.secondary,
                      label: 'Target',
                    ),
                    _buildFeatureCard(
                      context: context,
                      icon: Icons.flag_outlined,
                      iconColor: context.colors.tertiary,
                      label: 'Path',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return Container(
      width: 80.w,
      height: 80.w,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFC4C6CF).withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26.sp, color: iconColor),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
