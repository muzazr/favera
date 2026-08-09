import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';

enum AppStatusLevel {
  stable,
  warning,
  danger,
  info,
}

class AppStatusBadge extends StatelessWidget {
  final String label;
  final AppStatusLevel level;
  final IconData? icon;

  const AppStatusBadge({
    super.key,
    required this.label,
    this.level = AppStatusLevel.stable,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData defaultIcon;

    switch (level) {
      case AppStatusLevel.stable:
        backgroundColor = AppColors.primarySoft;
        textColor = AppColors.primaryDark;
        defaultIcon = Icons.check_circle_rounded;
        break;
      case AppStatusLevel.warning:
        backgroundColor = AppColors.accentOrangeSoft;
        textColor = AppColors.accentOrange;
        defaultIcon = Icons.warning_rounded;
        break;
      case AppStatusLevel.danger:
        backgroundColor = AppColors.dangerSoft;
        textColor = AppColors.danger;
        defaultIcon = Icons.error_rounded;
        break;
      case AppStatusLevel.info:
        backgroundColor = AppColors.infoSoft;
        textColor = AppColors.info;
        defaultIcon = Icons.info_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.pillBorder,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? defaultIcon,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
