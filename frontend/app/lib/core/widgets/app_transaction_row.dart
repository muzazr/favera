import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../formatters/currency_formatter.dart';

class AppTransactionRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final int amount;
  final bool isExpense;
  final Widget? iconTile;
  final String? anomalyBadgeText;
  final VoidCallback? onTap;

  const AppTransactionRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.isExpense = true,
    this.iconTile,
    this.anomalyBadgeText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final amountPrefix = isExpense ? '-' : '+';
    final amountColor = isExpense ? AppColors.textPrimary : AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.cardBorder,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
        child: Row(
          children: [
            // Pastel Category Icon Tile
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isExpense
                    ? AppColors.accentOrangeSoft
                    : AppColors.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: iconTile ??
                  Icon(
                    isExpense
                        ? Icons.shopping_bag_outlined
                        : Icons.account_balance_wallet_outlined,
                    color: isExpense
                        ? AppColors.accentOrange
                        : AppColors.primaryDark,
                    size: 22,
                  ),
            ),
            const SizedBox(width: AppSpacing.s12),

            // Title and Subtitle / Anomaly badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(subtitle, style: AppTypography.caption),
                      if (anomalyBadgeText != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accentOrangeSoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            anomalyBadgeText!,
                            style: AppTypography.caption.copyWith(
                              fontSize: 10,
                              color: AppColors.accentOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Amount in IDR
            Text(
              '$amountPrefix${CurrencyFormatter.format(amount)}',
              style: AppTypography.bodyMedium.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
