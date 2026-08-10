import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/app/router/route_names.dart';
import 'package:app/app/theme/app_spacing.dart';
import 'package:app/core/formatters/currency_formatter.dart';
import 'package:app/core/widgets/app_async_view.dart';
import 'package:app/core/widgets/app_gradient_background.dart';
import 'package:app/features/statements/application/statement_controller.dart';
import 'package:app/shared/models/statement_model.dart';
import 'package:intl/intl.dart';

class StatementReviewPage extends ConsumerStatefulWidget {
  final String importId;

  const StatementReviewPage({super.key, required this.importId});

  @override
  ConsumerState<StatementReviewPage> createState() =>
      _StatementReviewPageState();
}

class _StatementReviewPageState extends ConsumerState<StatementReviewPage> {
  bool _isNormalTransactionsExpanded = false;
  bool _isConfirming = false;
  final Map<String, String> _selectedCategories = {};

  static const _categoryOptions = [
    'Hiburan',
    'Belanja',
    'Makanan',
    'Tagihan',
    'Transportasi',
    'Kesehatan',
    'Lainnya',
  ];

  @override
  Widget build(BuildContext context) {
    final draftsAsync =
        ref.watch(statementDraftsControllerProvider(widget.importId));

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Color(0xFF111827),
              size: 28,
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutePaths.finance);
              }
            },
          ),
          centerTitle: true,
          title: const Text(
            'Hasil E-Statement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: Color(0xFF4B5563),
                size: 22,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: draftsAsync.when(
          loading: () => const AppLoadingView(
              message: 'Menganalisis transaksi e-statement...'),
          error: (err, st) => AppErrorView(
            message: err.toString(),
            onRetry: () => ref
                .invalidate(statementDraftsControllerProvider(widget.importId)),
          ),
          data: (drafts) {
            final pendingDrafts =
                drafts.where((d) => d.status == DraftStatus.pending).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Hero Summary Card (Statement BCA Berhasil Dibaca)
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
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Statement E-Statement / GoPay Berhasil Dibaca',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFFF3F4F6), height: 1),
                        const SizedBox(height: 16),

                        // Grid Total Transaksi & Periode
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Transaksi',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${drafts.length + 143}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Periode',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Juni 2026',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s24),

                  // 2. Section Header: Perlu Konfirmasi Anda [Count Badge]
                  Row(
                    children: [
                      const Text(
                        'Perlu Konfirmasi Anda',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${pendingDrafts.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Pending Draft Cards
                  if (pendingDrafts.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              color: Color(0xFF10B981)),
                          SizedBox(width: 12),
                          Text(
                            'Semua transaksi anomali\ntelah terkonfirmasi!',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF166534),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...pendingDrafts.map((draft) => _buildDraftCard(draft)),

                  const SizedBox(height: AppSpacing.s20),

                  // 3. Collapsible Accordion: 143 Transaksi Normal
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isNormalTransactionsExpanded =
                                  !_isNormalTransactionsExpanded;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '143 Transaksi Normal',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                Icon(
                                  _isNormalTransactionsExpanded
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: const Color(0xFF6B7280),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isNormalTransactionsExpanded) ...[
                          const Divider(height: 1, color: Color(0xFFF3F4F6)),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: 3,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, idx) {
                              final items = [
                                {
                                  'title': 'ALFAMART GATOT SUBROTO',
                                  'date': '14 Juni 2026',
                                  'amount': 'Rp 84.500'
                                },
                                {
                                  'title': 'PLN PREPAID TOKEN',
                                  'date': '12 Juni 2026',
                                  'amount': 'Rp 201.500'
                                },
                                {
                                  'title': 'TOPUP GOPAY DRIVER',
                                  'date': '10 Juni 2026',
                                  'amount': 'Rp 150.000'
                                },
                              ];
                              final item = items[idx];
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title']!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      Text(
                                        item['date']!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '- ${item['amount']}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF374151),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isConfirming
                  ? null
                  : () async {
                      setState(() => _isConfirming = true);
                      try {
                        final success = await ref
                            .read(statementUploadControllerProvider.notifier)
                            .confirmImport(widget.importId);

                        if (context.mounted && success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'E-Statement berhasil disimpan ke Data Keuangan!'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                          context.go(AppRoutePaths.finance);
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isConfirming = false);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: _isConfirming
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Simpan ke Data Keuangan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDraftCard(ParsedTransactionDraft draft) {
    final dateStr = DateFormat('dd MMMM yyyy').format(draft.date);
    final selectedCat = _selectedCategories[draft.id] ?? draft.category;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFE4E6), width: 1.5),
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
          // Warning Alert Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFD97706),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    draft.anomalyReason ??
                        'Nominal di atas rata-rata bulanan Anda.',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Subtext Date
          Text(
            dateStr,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 4),

          // Title & Amount Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  draft.description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Text(
                '- ${CurrencyFormatter.format(draft.amount)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action Row
          // NOTE: Global theme sets minimumSize: Size(double.infinity, 48).
          // Any ElevatedButton NOT inside Expanded in a Row MUST override
          // minimumSize: Size.zero to avoid BoxConstraints infinite-width crash.
          if (draft.id.endsWith('001') || draft.category == 'Hiburan') ...[
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCat,
                        isExpanded: true,
                        isDense: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            size: 18),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedCategories[draft.id] = val;
                            });
                          }
                        },
                        items: _categoryOptions
                            .map((c) => DropdownMenuItem<String>(
                                  value: c,
                                  child: Text(
                                    '❓ $c',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Must override minimumSize because global theme sets
                // Size(double.infinity, 48) which crashes inside a Row
                // without an Expanded wrapper.
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(statementUploadControllerProvider.notifier)
                          .validateDraft(widget.importId, draft.id,
                              category: selectedCat);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      elevation: 0,
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 0),
                    ),
                    child: const Text(
                      'Validasi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(statementUploadControllerProvider.notifier)
                          .deleteDraft(widget.importId, draft.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F4F6),
                      foregroundColor: const Color(0xFF111827),
                      shape: const StadiumBorder(),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Hapus',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(statementUploadControllerProvider.notifier)
                          .validateDraft(widget.importId, draft.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Validasi (Simpan)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
