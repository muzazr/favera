import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 36,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF00875A),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF00B37E),
            Color(0xFF00875A),
          ],
        ),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00875A).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'TOTAL SALDO KELUARGA',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              ref.read(hideBalanceStateProvider.notifier).state = !hideBalance;
            },
            child: Text(
              hideBalance
                  ? '••••••••'
                  : CurrencyFormatter.format(summary.totalBalance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
