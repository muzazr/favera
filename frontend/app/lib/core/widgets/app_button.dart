import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';

enum AppButtonVariant {
  primary,
  secondary,
  destructive,
  outline,
  ghost,
}

enum AppButtonSize {
  normal,
  small,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Widget? customIcon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.normal,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor =
            isDisabled ? AppColors.disabledBackground : AppColors.primary;
        foregroundColor =
            isDisabled ? AppColors.disabledText : AppColors.surface;
        break;
      case AppButtonVariant.secondary:
        backgroundColor =
            isDisabled ? AppColors.disabledBackground : AppColors.accentOrange;
        foregroundColor =
            isDisabled ? AppColors.disabledText : AppColors.surface;
        break;
      case AppButtonVariant.destructive:
        backgroundColor =
            isDisabled ? AppColors.disabledBackground : AppColors.danger;
        foregroundColor =
            isDisabled ? AppColors.disabledText : AppColors.surface;
        break;
      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor =
            isDisabled ? AppColors.disabledText : AppColors.primary;
        borderSide = BorderSide(
          color: isDisabled ? AppColors.border : AppColors.primary,
          width: 1.5,
        );
        break;
      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor =
            isDisabled ? AppColors.disabledText : AppColors.textPrimary;
        break;
    }

    final height = size == AppButtonSize.small ? 38.0 : 48.0;
    final fontSize = size == AppButtonSize.small ? 13.0 : 15.0;

    final childContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (customIcon != null) ...[
          customIcon!,
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon,
              size: size == AppButtonSize.small ? 18 : 20,
              color: foregroundColor),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: AppTypography.button.copyWith(
            color: foregroundColor,
            fontSize: fontSize,
          ),
        ),
      ],
    );

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      side: borderSide,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.pillBorder),
      minimumSize: Size(isFullWidth ? double.infinity : 0, height),
      padding: EdgeInsets.symmetric(
        horizontal: size == AppButtonSize.small ? 16 : 24,
        vertical: 0,
      ),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: ElevatedButton(
        style: buttonStyle,
        onPressed: isDisabled ? null : onPressed,
        child: childContent,
      ),
    );
  }
}
