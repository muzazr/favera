import 'dart:ui';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class AppGradientBackground extends StatelessWidget {
  final Widget child;

  const AppGradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base off-white background
        Container(
          color: AppColors.background,
        ),
        // Top-right green blur circle glow
        Positioned(
          top: -70,
          right: -70,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF10B981).withValues(alpha: 0.28),
            ),
          ),
        ),
        // Bottom-left soft mint/sky blue blur circle glow
        Positioned(
          bottom: -90,
          left: -90,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6EE7B7).withValues(alpha: 0.20),
            ),
          ),
        ),
        // Soft backdrop filter blur for seamless glass feel
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60.0, sigmaY: 60.0),
          child: Container(color: Colors.transparent),
        ),
        child,
      ],
    );
  }
}
