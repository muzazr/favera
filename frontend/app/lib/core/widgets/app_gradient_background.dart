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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.lavender,
            AppColors.sky,
            AppColors.mint,
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: child,
    );
  }
}
