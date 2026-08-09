import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../formatters/currency_formatter.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.boxShadow,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.cardBackground,
        borderRadius: AppRadius.cardBorder,
        boxShadow: boxShadow ?? AppShadows.soft,
        border: border ??
            Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardBorder,
        child: container,
      );
    }
    return container;
  }
}

class AppBalanceHeroCard extends StatelessWidget {
  final int totalBalance;
  final bool isBalanceHidden;
  final VoidCallback? onToggleHideBalance;
  final String title;

  const AppBalanceHeroCard({
    super.key,
    required this.totalBalance,
    this.isBalanceHidden = false,
    this.onToggleHideBalance,
    this.title = 'TOTAL SALDO KELUARGA',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: AppRadius.cardBorder,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: AppTypography.caption.copyWith(
                  color: AppColors.surface.withValues(alpha: 0.85),
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onToggleHideBalance != null)
                IconButton(
                  icon: Icon(
                    isBalanceHidden ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.surface,
                    size: 20,
                  ),
                  onPressed: onToggleHideBalance,
                  tooltip:
                      isBalanceHidden ? 'Tampilkan Saldo' : 'Sembunyikan Saldo',
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            isBalanceHidden
                ? 'Rp ••••••••'
                : CurrencyFormatter.format(totalBalance),
            style: AppTypography.displayBalance,
          ),
        ],
      ),
    );
  }
}
