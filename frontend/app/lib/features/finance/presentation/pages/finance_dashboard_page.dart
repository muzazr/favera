import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/app/router/route_names.dart';
import 'package:app/app/theme/app_spacing.dart';
import 'package:app/core/constants/app_assets.dart';
import 'package:app/core/formatters/currency_formatter.dart';
import 'package:app/core/widgets/app_async_view.dart';
import 'package:app/core/widgets/app_gradient_background.dart';
import 'package:app/features/home/application/dashboard_controller.dart';
import 'package:app/features/home/presentation/widgets/balance_hero_card.dart';

class FinanceDashboardPage extends ConsumerWidget {
  const FinanceDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardControllerProvider);

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: dashboardAsync.when(
          loading: () =>
              const AppLoadingView(message: 'Memuat data keuangan...'),
          error: (err, stack) => AppErrorView(
            message: err.toString(),
            onRetry: () =>
                ref.read(dashboardControllerProvider.notifier).refreshSummary(),
          ),
          data: (summary) {
            final firstName = summary.userName.split(' ').first;

            return Column(
              children: [
                // 1. Top White Header Banner (Flush to Top & Edges)
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Selamat Pagi,',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                firstName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                          // Right Profile Avatar with Active Green Badge Dot
                          Stack(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: const CircleAvatar(
                                  radius: 22,
                                  backgroundImage:
                                      AssetImage(AppAssets.profileWomen),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. Scrollable Body Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 16,
                      bottom: 110,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Total Saldo Keluarga Card
                        BalanceHeroCard(summary: summary),
                        const SizedBox(height: AppSpacing.s24),

                        // Target Keuangan Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Target Keuangan',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add_rounded,
                                color: Color(0xFF10B981),
                                size: 24,
                              ),
                              onPressed: () {
                                context.push(AppRoutePaths.goalNew);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s8),

                        // Horizontal Goal Cards Carousel
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // Goal 1: Dana Darurat
                              _buildGoalCard(
                                title: 'Dana Darurat',
                                assetPath: AppAssets.danaDarurat,
                                currentAmount: 6000000,
                                targetAmount: 10000000,
                                progressColor: const Color(0xFF10B981),
                              ),
                              const SizedBox(width: 12),

                              // Goal 2: Pendidikan
                              _buildGoalCard(
                                title: 'Pendidikan',
                                icon: Icons.school_rounded,
                                iconColor: const Color(0xFFFF7418),
                                currentAmount: 12000000,
                                targetAmount: 20000000,
                                progressColor: const Color(0xFFFF7418),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s24),

                        // Action Buttons Stack (3 Buttons)
                        // Button 1: + Tambah Target Keuangan
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            onPressed: () {
                              context.push(AppRoutePaths.goalNew);
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_rounded, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Tambah Target Keuangan',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Button 2: + Tambah Transaksi
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            onPressed: () {
                              context.push(AppRoutePaths.transactionNew);
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_rounded, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Tambah Transaksi',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Button 3: Upload e-Statement (Soft Orange)
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFE5D5),
                              foregroundColor: const Color(0xFFC2410C),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            onPressed: () {
                              context.push(AppRoutePaths.statementUpload);
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.file_upload_outlined,
                                  size: 20,
                                  color: Color(0xFFC2410C),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Upload e-Statement',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFC2410C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s24),

                        // Aktivitas Terbaru Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Aktivitas Terbaru',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                context.push(AppRoutePaths.transactions);
                              },
                              child: const Text(
                                'Lihat Semua',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s12),

                        // Transactions List Items
                        if (summary.recentTransactions.isEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Center(
                              child: Text(
                                'Belum ada aktivitas transaksi',
                                style: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          ...summary.recentTransactions.map((tx) {
                            final isIncome = tx.type.name == 'income';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Category Icon Circle
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isIncome
                                          ? const Color(0xFFE6F7F0)
                                          : const Color(0xFFFFF7ED),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isIncome
                                          ? Icons.arrow_downward_rounded
                                          : Icons.shopping_cart_outlined,
                                      color: isIncome
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFFF7418),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Category & Time
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tx.description.isNotEmpty
                                              ? tx.description
                                              : tx.category,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF111827),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Hari ini, 09:41',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF9CA3AF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Amount & Partner Avatar
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${isIncome ? '+' : '-'} ${CurrencyFormatter.format(tx.amount)}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isIncome
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFF111827),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const CircleAvatar(
                                        radius: 10,
                                        backgroundImage:
                                            AssetImage(AppAssets.profileWomen),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGoalCard({
    required String title,
    IconData? icon,
    String? assetPath,
    Color? iconColor,
    required int currentAmount,
    required int targetAmount,
    required Color progressColor,
  }) {
    final progress =
        targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
    final currentK = '${(currentAmount / 1000).toStringAsFixed(0)}k';
    final targetK = '${(targetAmount / 1000).toStringAsFixed(0)}k';

    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              if (assetPath != null)
                Image.asset(assetPath, width: 22, height: 22)
              else if (icon != null)
                Icon(icon, color: iconColor, size: 20),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE0E7FF),
              valueColor: AlwaysStoppedAnimation(progressColor),
            ),
          ),
          const SizedBox(height: 12),

          // Amount subtext
          Text(
            'Rp $currentK / Rp $targetK',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
