import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/app/theme/app_spacing.dart';
import 'package:app/core/formatters/currency_formatter.dart';
import 'package:app/core/widgets/app_gradient_background.dart';
import 'package:app/features/finance/application/transaction_controller.dart';
import 'package:app/shared/models/transaction_model.dart';

class TransactionFormPage extends ConsumerStatefulWidget {
  const TransactionFormPage({super.key});

  @override
  ConsumerState<TransactionFormPage> createState() =>
      _TransactionFormPageState();
}

class _TransactionFormPageState extends ConsumerState<TransactionFormPage> {
  TransactionDirection _type = TransactionDirection.expense;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Belanja';
  String _visibility = 'shared';
  bool _isSaving = false;

  static const _incomeCategories = [
    {'name': 'Gaji Bulanan', 'icon': '💼'},
    {'name': 'Bonus', 'icon': '💳'},
    {'name': 'Hasil Usaha', 'icon': '🏪'},
    {'name': 'Investasi', 'icon': '📈'},
    {'name': 'Lainnya', 'icon': '•••'},
  ];

  static const _expenseCategories = [
    {'name': 'Belanja', 'icon': '🛒'},
    {'name': 'Tagihan', 'icon': '⚡'},
    {'name': 'Hiburan', 'icon': '🎬'},
    {'name': 'Transportasi', 'icon': '🚗'},
    {'name': 'Kesehatan', 'icon': '🏥'},
    {'name': 'Lainnya', 'icon': '•••'},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final amountText =
        _amountController.text.replaceAll('.', '').replaceAll('Rp', '').trim();
    final amount = int.tryParse(amountText) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal transaksi yang valid')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(transactionListControllerProvider.notifier).addTransaction(
            direction: _type,
            amount: amount,
            category: _selectedCategory,
            description: _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : _selectedCategory,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_type == TransactionDirection.income
                ? 'Pemasukan berhasil dicatat!'
                : 'Pengeluaran berhasil dicatat!'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan transaksi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _type == TransactionDirection.income;
    final currentCategories = isIncome ? _incomeCategories : _expenseCategories;

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Tambah Transaksi',
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
              Icons.close_rounded,
              color: Color(0xFF111827),
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Segmented Control (Pengeluaran vs Pemasukan)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _type = TransactionDirection.expense;
                                    _selectedCategory = 'Belanja';
                                  });
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !isIncome
                                        ? const Color(0xFF10B981)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Pengeluaran',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: !isIncome
                                          ? Colors.white
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _type = TransactionDirection.income;
                                    _selectedCategory = 'Gaji Bulanan';
                                  });
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isIncome
                                        ? const Color(0xFF10B981)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Pemasukan',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isIncome
                                          ? Colors.white
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s24),

                      // Amount Input Card (Mint container for income)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color:
                              isIncome ? const Color(0xFFE6F7F0) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isIncome
                                ? const Color(0xFFA7F3D0)
                                : const Color(0xFFE5E7EB),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isIncome
                                  ? 'Nominal Pemasukan'
                                  : 'Nominal Pengeluaran',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isIncome
                                    ? const Color(0xFF059669)
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Rp ',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: isIncome
                                        ? const Color(0xFF059669)
                                        : const Color(0xFF111827),
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      ThousandsSeparatorInputFormatter(),
                                    ],
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: isIncome
                                          ? const Color(0xFF059669)
                                          : const Color(0xFF111827),
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      hintText: '5.500.000',
                                      hintStyle: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: isIncome
                                            ? const Color(0xFF059669)
                                                .withValues(alpha: 0.35)
                                            : const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s24),

                      // Category Chips
                      Text(
                        isIncome ? 'Sumber Pemasukan' : 'Kategori Pengeluaran',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: currentCategories.map((catObj) {
                          final name = catObj['name']!;
                          final icon = catObj['icon']!;
                          final isSelected = name == _selectedCategory;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = name;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF059669)
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.25)
                                          : const Color(0xFFE5E7EB),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      icon,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF374151),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.s24),

                      // Description Input
                      Text(
                        isIncome
                            ? 'Deskripsi Pemasukan'
                            : 'Deskripsi Pengeluaran',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: isIncome
                                ? 'Tulis detail pemasukan di sini (opsional)...'
                                : 'Tulis detail pengeluaran di sini (opsional)...',
                            border: InputBorder.none,
                            hintStyle: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s24),

                      // Visibilitas Transaksi (Privat vs Dibagikan)
                      const Text(
                        'Visibilitas Transaksi',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _visibility = 'shared'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 14),
                                decoration: BoxDecoration(
                                  color: _visibility == 'shared'
                                      ? const Color(0xFFE6F7F0)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: _visibility == 'shared'
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFE5E7EB),
                                    width: _visibility == 'shared' ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.people_outline_rounded,
                                      size: 18,
                                      color: _visibility == 'shared'
                                          ? const Color(0xFF047857)
                                          : const Color(0xFF6B7280),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Dibagikan',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: _visibility == 'shared'
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: _visibility == 'shared'
                                            ? const Color(0xFF047857)
                                            : const Color(0xFF374151),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _visibility = 'private'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 14),
                                decoration: BoxDecoration(
                                  color: _visibility == 'private'
                                      ? const Color(0xFFFEF2F2)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: _visibility == 'private'
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFFE5E7EB),
                                    width: _visibility == 'private' ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.lock_outline_rounded,
                                      size: 18,
                                      color: _visibility == 'private'
                                          ? const Color(0xFFB91C1C)
                                          : const Color(0xFF6B7280),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Privat Saya',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: _visibility == 'private'
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: _visibility == 'private'
                                            ? const Color(0xFFB91C1C)
                                            : const Color(0xFF374151),
                                      ),
                                    ),
                                  ],
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

              // Sticky Save Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
                    ),
                    onPressed: _isSaving ? null : _submitForm,
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline_rounded,
                                  size: 20),
                              const SizedBox(width: 8),
                              Text(
                                isIncome
                                    ? 'Simpan Pemasukan'
                                    : 'Simpan Pengeluaran',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
