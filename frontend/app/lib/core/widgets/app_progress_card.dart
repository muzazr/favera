import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../formatters/currency_formatter.dart';

class AppProgressCard extends StatelessWidget {
  final String title;
  final int currentAmount;
  final int targetAmount;
  final String? subtitle;
  final VoidCallback? onTap;

  const AppProgressCard({
    super.key,
    required this.title,
    required this.currentAmount,
    required this.targetAmount,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progressRatio =
        targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
    final percentage = (progressRatio * 100).toInt();

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.cardBorder,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.cardBorder,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$percentage%',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: AppTypography.helper),
            ],
            const SizedBox(height: AppSpacing.s12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progressRatio,
                minHeight: 8,
                backgroundColor: AppColors.primarySoft.withValues(alpha: 0.5),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CurrencyFormatter.format(currentAmount),
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.primary),
                ),
                Text(
                  'Target ${CurrencyFormatter.format(targetAmount)}',
                  style: AppTypography.helper,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
