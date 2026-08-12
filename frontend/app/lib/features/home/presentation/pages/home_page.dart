import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/formatters/currency_formatter.dart';
import '../../../../core/widgets/app_async_view.dart';
import '../../../../core/widgets/app_gradient_background.dart';
import '../../application/dashboard_controller.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../../shared/models/transaction_model.dart';
import '../widgets/balance_hero_card.dart';
import '../widgets/check_in_banner.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardControllerProvider);
    final user = ref.watch(authControllerProvider).value;

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: dashboardAsync.when(
          loading: () =>
              const AppLoadingView(message: 'Memuat ringkasan dashboard...'),
          error: (err, stack) => AppErrorView(
            message: err.toString(),
            onRetry: () =>
                ref.read(dashboardControllerProvider.notifier).refreshSummary(),
          ),
          data: (summary) {
            final displayName = user?.name ?? summary.userName;
            final firstName = displayName.split(' ').first;
            final activeGoal = summary.activeGoal;

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
                                'Halo,',
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
                          // Right Profile Avatar
                          const CircleAvatar(
                            radius: 22,
                            backgroundImage: AssetImage(AppAssets.profileWomen),
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
                      bottom: 80,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 2. Family Status Badge (Centered Output from Model 2)
                        Center(
                          child: InkWell(
                            onTap: () {
                              context.push(AppRoutePaths.familyCondition);
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6F7F0),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0xFF10B981)
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.shield_rounded,
                                    size: 16,
                                    color: Color(0xFF00875A),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Status Keluarga : Aman Terkendali',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s16),

                        // 3. Total Saldo Keluarga Green Hero Card
                        BalanceHeroCard(summary: summary),
                        const SizedBox(height: AppSpacing.s16),

                        // 4. Dana Darurat (Active Goal Card - Solid Minimalist White)
                        if (activeGoal != null) ...[
                          Container(
                            padding: const EdgeInsets.all(20),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      activeGoal.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.more_horiz_rounded,
                                      color: Color(0xFF9CA3AF),
                                      size: 20,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Progress Bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: activeGoal.targetAmount > 0
                                        ? (activeGoal.currentAmount /
                                                activeGoal.targetAmount)
                                            .clamp(0.0, 1.0)
                                        : 0.0,
                                    minHeight: 10,
                                    backgroundColor: const Color(0xFFE0E7FF),
                                    valueColor: const AlwaysStoppedAnimation(
                                      Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Subtext Progress
                                Text(
                                  '${CurrencyFormatter.format(activeGoal.currentAmount)} / ${CurrencyFormatter.format(activeGoal.targetAmount)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF4B5563),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s16),
                        ],

                        // 5. Check-In Minggu ke–3 Banner
                        const CheckInBanner(),
                        const SizedBox(height: AppSpacing.s24),

                        // 6. Pusat Bantuan Section (Horizontal Scroll — Exactly 3 Cards)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Pusat Bantuan',
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
                                context.push(AppRoutePaths.mediation);
                              },
                              child: const Text(
                                'Selengkapnya',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s12),

                        // 3 Horizontal Cards (Tanya AI, Konseling Digital, Simulasi Finansial)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // Card 1: Tanya AI
                              _buildHelpCenterCard(
                                backgroundColor: const Color(0xFFFFFBEB),
                                iconPath: AppAssets.robotAi,
                                title: 'Tanya AI',
                                subtitle: 'Konseling finansial',
                                onTap: () =>
                                    context.push(AppRoutePaths.chatSessions),
                              ),
                              const SizedBox(width: 12),

                              // Card 2: Konseling Digital
                              _buildHelpCenterCard(
                                backgroundColor: const Color(0xFFEFF6FF),
                                iconPath: AppAssets.counselingService,
                                title: 'Konseling\nDigital',
                                subtitle: 'Bicara dgn ahli',
                                onTap: () =>
                                    context.push(AppRoutePaths.professionals),
                              ),
                              const SizedBox(width: 12),

                              // Card 3: Simulasi Finansial
                              _buildHelpCenterCard(
                                backgroundColor: const Color(0xFFFFF1F2),
                                iconPath: AppAssets.simulationFinance,
                                title: 'Simulasi\nFinansial',
                                subtitle: 'Dampak...',
                                onTap: () =>
                                    context.push(AppRoutePaths.simulationNew),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s24),

                        // 7. Aktivitas Terbaru Section
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
                              onPressed: () =>
                                  context.push(AppRoutePaths.transactions),
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

                        // Transaction Items Card (with Background)
                        if (summary.recentTransactions.isEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
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
                            child: const Center(
                              child: Text(
                                'Belum ada transaksi bulan ini',
                                style: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          ...summary.recentTransactions.map((tx) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Icon Circle
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFF7ED),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.shopping_cart_outlined,
                                        color: Color(0xFFFF7418),
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Title & Date
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
                                            'Hari ini, 10:42',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF9CA3AF),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Amount
                                    Builder(
                                      builder: (context) {
                                        final isInc = tx.direction == TransactionDirection.income;
                                        return Text(
                                          '${isInc ? "+" : "-"} ${CurrencyFormatter.format(tx.amount)}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: isInc
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFF111827),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                        const SizedBox(height: AppSpacing.s24),

                        // 8. Floating Center Action Button (+ Catat Transaksi Baru)
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              shadowColor: const Color(0xFF10B981)
                                  .withValues(alpha: 0.3),
                            ),
                            onPressed: () {
                              context.push(AppRoutePaths.transactionNew);
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Catat Transaksi Baru',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
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

  Widget _buildHelpCenterCard({
    required Color backgroundColor,
    required String iconPath,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // White Circle Badge with Asset Icon
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  iconPath,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),

              // Subtitle
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
