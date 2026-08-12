import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/app/theme/app_spacing.dart';
import 'package:app/core/constants/app_assets.dart';
import 'package:app/core/formatters/currency_formatter.dart';
import 'package:app/core/widgets/app_async_view.dart';
import 'package:app/core/widgets/app_gradient_background.dart';
import 'package:app/features/finance/application/transaction_controller.dart';
import 'package:app/shared/models/transaction_model.dart';

class TransactionDetailPage extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailPage({
    super.key,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync =
        ref.watch(transactionDetailControllerProvider(transactionId));

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Rincian Transaksi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF111827),
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: detailAsync.when(
          loading: () =>
              const AppLoadingView(message: 'Memuat detail transaksi...'),
          error: (err, stack) => AppErrorView(
            message: err.toString(),
            onRetry: () =>
                ref.refresh(transactionDetailControllerProvider(transactionId)),
          ),
          data: (tx) {
            if (tx == null) {
              return const AppEmptyView(
                title: 'Transaksi Tidak Ditemukan',
                description:
                    'Detail transaksi tidak dapat ditemukan atau telah dihapus.',
              );
            }

            final isIncome = tx.direction == TransactionDirection.income;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Amount Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
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
                        children: [
                          Container(
                            width: 56,
                            height: 56,
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
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            tx.description.isNotEmpty
                                ? tx.description
                                : tx.category,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${isIncome ? '+' : '-'} ${CurrencyFormatter.format(tx.amount)}',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: isIncome
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),

                    // Neutral Anomaly Explanation Card (if flagged)
                    if (tx.isAnomaly) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                const Color(0xFFF59E0B).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFFD97706),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Memerlukan Konfirmasi',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    tx.anomalyReason ??
                                        'Transaksi ini berbeda dari pola sebelumnya dan perlu dikonfirmasi.',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF78350F),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                    ],

                    // Details Section List
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('Kategori', tx.category),
                          const Divider(height: 24),
                          _buildDetailRow(
                            'Jenis Transaksi',
                            isIncome ? 'Pemasukan' : 'Pengeluaran',
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            'Status',
                            tx.confirmedByPartner
                                ? 'Dikonfirmasi Pasangan'
                                : 'Tercatat Mandiri',
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            'Pencatat',
                            'Joselin',
                            trailingAvatar: AppAssets.profileWomen,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s24),

                    // Actions: Delete / Archive Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side: const BorderSide(color: Color(0xFFFECACA)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        onPressed: () {
                          _showDeleteConfirmDialog(context, ref, tx.id);
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                              color: Color(0xFFEF4444),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Hapus Transaksi Ini',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    String? trailingAvatar,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        Row(
          children: [
            if (trailingAvatar != null) ...[
              CircleAvatar(
                radius: 10,
                backgroundImage: AssetImage(trailingAvatar),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hapus Transaksi?'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus pencatatan transaksi ini dari data keluarga?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(transactionListControllerProvider.notifier)
                  .deleteTransaction(id);
              if (context.mounted) {
                context.pop();
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
