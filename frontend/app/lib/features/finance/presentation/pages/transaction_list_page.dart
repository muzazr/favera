import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/app/router/route_names.dart';
import 'package:app/core/constants/app_assets.dart';
import 'package:app/core/formatters/currency_formatter.dart';
import 'package:app/core/widgets/app_async_view.dart';
import 'package:app/core/widgets/app_gradient_background.dart';
import 'package:app/features/finance/application/transaction_controller.dart';
import 'package:app/shared/models/transaction_model.dart';

class TransactionListPage extends ConsumerWidget {
  const TransactionListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionListControllerProvider);
    final filter = ref.watch(transactionFilterProvider);

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Riwayat Transaksi',
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
          actions: [
            IconButton(
              icon: const Icon(
                Icons.add_rounded,
                color: Color(0xFF10B981),
                size: 28,
              ),
              onPressed: () {
                context.push(AppRoutePaths.transactionNew);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Filter Pills Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  _buildFilterChip(
                    context,
                    ref,
                    label: 'Semua',
                    isSelected: filter.category == 'Semua' &&
                        filter.type == null &&
                        filter.isAnomaly == null,
                    onTap: () {
                      ref.read(transactionFilterProvider.notifier).state =
                          const TransactionListFilter(category: 'Semua');
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    ref,
                    label: 'Pengeluaran',
                    isSelected: filter.type == TransactionType.expense,
                    onTap: () {
                      ref.read(transactionFilterProvider.notifier).state =
                          const TransactionListFilter(
                        category: 'Semua',
                        type: TransactionType.expense,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    ref,
                    label: 'Pemasukan',
                    isSelected: filter.type == TransactionType.income,
                    onTap: () {
                      ref.read(transactionFilterProvider.notifier).state =
                          const TransactionListFilter(
                        category: 'Semua',
                        type: TransactionType.income,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    ref,
                    label: 'Perlu Konfirmasi',
                    isSelected: filter.isAnomaly == true,
                    onTap: () {
                      ref.read(transactionFilterProvider.notifier).state =
                          const TransactionListFilter(
                        category: 'Semua',
                        isAnomaly: true,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Transactions List
            Expanded(
              child: transactionsAsync.when(
                loading: () => const AppLoadingView(
                    message: 'Memuat riwayat transaksi...'),
                error: (err, stack) => AppErrorView(
                  message: err.toString(),
                  onRetry: () => ref
                      .read(transactionListControllerProvider.notifier)
                      .refreshList(),
                ),
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return AppEmptyView(
                      title: 'Belum Ada Transaksi',
                      description: 'Belum ada transaksi pada kategori ini',
                      actionText: 'Tambah Transaksi',
                      onAction: () {
                        context.push(AppRoutePaths.transactionNew);
                      },
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => ref
                        .read(transactionListControllerProvider.notifier)
                        .refreshList(),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 8,
                        bottom: 40,
                      ),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        final isIncome = tx.type == TransactionType.income;

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
                          child: InkWell(
                            onTap: () {
                              context.push(
                                AppRoutePaths.transactionDetailWithId(tx.id),
                              );
                            },
                            child: Row(
                              children: [
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
                                      Text(
                                        tx.category,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }
}
