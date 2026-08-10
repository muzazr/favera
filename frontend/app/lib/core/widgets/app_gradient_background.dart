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
        // Top-left soft lavender/purple ambient blur circle
        Positioned(
          top: -60,
          left: -60,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFDDD6FE).withValues(alpha: 0.35),
            ),
          ),
        ),
        // Top-right soft sky blue/cyan ambient blur circle
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFBAE6FD).withValues(alpha: 0.30),
            ),
          ),
        ),
        // Bottom-left soft mint green ambient blur circle
        Positioned(
          bottom: -80,
          left: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFA7F3D0).withValues(alpha: 0.35),
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
