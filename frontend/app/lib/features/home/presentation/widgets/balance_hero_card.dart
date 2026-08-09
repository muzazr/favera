import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/formatters/currency_formatter.dart';
import '../../application/dashboard_controller.dart';
import '../../data/dashboard_model.dart';

class BalanceHeroCard extends ConsumerWidget {
  final DashboardSummary summary;

  const BalanceHeroCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hideBalance = ref.watch(hideBalanceStateProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL SALDO KELUARGA',
                style: AppTypography.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              IconButton(
                icon: Icon(
                  hideBalance
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  ref.read(hideBalanceStateProvider.notifier).state =
                      !hideBalance;
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            hideBalance
                ? '••••••••'
                : CurrencyFormatter.format(summary.totalBalance),
            style: AppTypography.pageTitle.copyWith(
              color: Colors.white,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Divider(color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: AppSpacing.s8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.arrow_downward_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Pemasukan',
                          style: AppTypography.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hideBalance
                          ? '••••••'
                          : CurrencyFormatter.format(summary.monthlyIncome),
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 24,
                width: 1,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              const SizedBox(width: AppSpacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.arrow_upward_rounded,
                          color: AppColors.accentOrangeSoft,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Pengeluaran',
                          style: AppTypography.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hideBalance
                          ? '••••••'
                          : CurrencyFormatter.format(summary.monthlyExpense),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.accentOrangeSoft,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
