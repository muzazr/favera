import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_async_view.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_gradient_background.dart';
import '../../../../core/widgets/app_progress_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../../../core/widgets/app_transaction_row.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../application/dashboard_controller.dart';
import '../widgets/balance_hero_card.dart';
import '../widgets/check_in_banner.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardControllerProvider);

    return AppGradientBackground(
      child: AppScaffold(
        body: dashboardAsync.when(
          loading: () =>
              const AppLoadingView(message: 'Memuat ringkasan dashboard...'),
          error: (err, stack) => AppErrorView(
            message: err.toString(),
            onRetry: () =>
                ref.read(dashboardControllerProvider.notifier).refreshSummary(),
          ),
          data: (summary) {
            final activeGoal = summary.activeGoal;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
                vertical: AppSpacing.s16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header Greeting & Avatar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primarySoft,
                            child: Text(
                              summary.userName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Halo, ${summary.userName}! 👋',
                                style: AppTypography.pageTitle,
                              ),
                              const Text(
                                'Selamat datang di Favera',
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () {
                          context.push(AppRoutePaths.debugRoutes);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  // 2. Family Status Badge
                  Row(
                    children: [
                      const AppStatusBadge(
                        label: 'TERHUBUNG',
                        level: AppStatusLevel.stable,
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Text(
                        'Keluarga ${summary.userName} & ${summary.partnerName ?? "Pasangan"}',
                        style: AppTypography.helper.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  // 3. Balance Hero Card
                  BalanceHeroCard(summary: summary),
                  const SizedBox(height: AppSpacing.s24),

                  // 4. Active Financial Goal Card
                  if (activeGoal != null) ...[
                    const Text('Target Keuangan Bersama',
                        style: AppTypography.sectionTitle),
                    const SizedBox(height: AppSpacing.s12),
                    AppProgressCard(
                      title: activeGoal.name,
                      currentAmount: activeGoal.currentAmount,
                      targetAmount: activeGoal.targetAmount,
                      subtitle: 'Disetujui bersama pasangan',
                    ),
                    const SizedBox(height: AppSpacing.s24),
                  ],

                  // 5. Weekly Check-In Banner
                  if (summary.hasPendingCheckIn) ...[
                    const CheckInBanner(),
                    const SizedBox(height: AppSpacing.s24),
                  ],

                  // 6. Quick Action Row
                  const Text('Aksi Cepat', style: AppTypography.sectionTitle),
                  const SizedBox(height: AppSpacing.s12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.add_rounded,
                          label: 'Tambah\nTransaksi',
                          color: AppColors.primarySoft,
                          iconColor: AppColors.primaryDark,
                          onTap: () =>
                              context.push(AppRoutePaths.transactionNew),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.upload_file_rounded,
                          label: 'Upload\nE-Statement',
                          color: AppColors.accentOrangeSoft,
                          iconColor: AppColors.accentOrange,
                          onTap: () =>
                              context.push(AppRoutePaths.statementUpload),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.handshake_outlined,
                          label: 'Mediasi &\nKonsultasi',
                          color: AppColors.infoSoft,
                          iconColor: AppColors.info,
                          onTap: () => context.push(AppRoutePaths.mediation),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s24),

                  // 7. Recent Activity List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Aktivitas Terbaru',
                          style: AppTypography.sectionTitle),
                      TextButton(
                        onPressed: () =>
                            context.push(AppRoutePaths.transactions),
                        child: const Text('Lihat Semua'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),

                  if (summary.recentTransactions.isEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Text('Belum ada transaksi bulan ini',
                            style: AppTypography.helper),
                      ),
                    ),
                  ] else ...[
                    ...summary.recentTransactions.map((tx) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                        child: AppTransactionRow(
                          title: tx.category,
                          subtitle: tx.description,
                          amount: tx.amount,
                          isExpense: tx.type == TransactionType.expense,
                          anomalyBadgeText:
                              tx.isAnomaly ? 'Perlu Konfirmasi' : null,
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
