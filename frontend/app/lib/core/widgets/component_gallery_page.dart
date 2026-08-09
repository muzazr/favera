import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import 'app_amount_field.dart';
import 'app_async_view.dart';
import 'app_bottom_nav_bar.dart';
import 'app_button.dart';
import 'app_card.dart';
import 'app_pill_choice.dart';
import 'app_progress_card.dart';
import 'app_scaffold.dart';
import 'app_status_badge.dart';
import 'app_text_field.dart';
import 'app_transaction_row.dart';

class ComponentGalleryPage extends StatefulWidget {
  const ComponentGalleryPage({super.key});

  @override
  State<ComponentGalleryPage> createState() => _ComponentGalleryPageState();
}

class _ComponentGalleryPageState extends State<ComponentGalleryPage> {
  bool _isBalanceHidden = false;
  int _selectedTab = 0;
  String _selectedPill = 'all';
  List<String> _selectedCategories = ['food'];
  int _enteredAmount = 1500000;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Favera Design System'),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _selectedTab,
        onTap: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.s12),
            // Header / Intro
            const Text(
              'Design System & Component Gallery',
              style: AppTypography.pageTitle,
            ),
            const SizedBox(height: 4),
            const Text(
              'Pratinjau token visual dan komponen reusable Part 01',
              style: AppTypography.helper,
            ),
            const SizedBox(height: AppSpacing.s24),

            // 1. Balance Hero Card
            const Text('Hero Balance Card', style: AppTypography.sectionTitle),
            const SizedBox(height: AppSpacing.s12),
            AppBalanceHeroCard(
              totalBalance: 12500000,
              isBalanceHidden: _isBalanceHidden,
              onToggleHideBalance: () {
                setState(() {
                  _isBalanceHidden = !_isBalanceHidden;
                });
              },
            ),
            const SizedBox(height: AppSpacing.s24),

            // 2. Status Badges
            const Text('Family Status Badges',
                style: AppTypography.sectionTitle),
            const SizedBox(height: AppSpacing.s12),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppStatusBadge(
                  label: 'Status Keluarga · Aman Terkendali',
                  level: AppStatusLevel.stable,
                ),
                AppStatusBadge(
                  label: 'Memerlukan Perhatian',
                  level: AppStatusLevel.warning,
                ),
                AppStatusBadge(
                  label: 'Dukungan Keselamatan',
                  level: AppStatusLevel.danger,
                ),
                AppStatusBadge(
                  label: 'Info Pemulihan',
                  level: AppStatusLevel.info,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s24),

            // 3. App Buttons
            const Text('Buttons & States', style: AppTypography.sectionTitle),
            const SizedBox(height: AppSpacing.s12),
            AppButton(
              text: 'Tombol Utama (Primary)',
              onPressed: () {},
              icon: Icons.check_circle_outline,
            ),
            const SizedBox(height: AppSpacing.s12),
            AppButton(
              text: 'Tombol Alternatif (Secondary)',
              variant: AppButtonVariant.secondary,
              onPressed: () {},
              icon: Icons.upload_file_outlined,
            ),
            const SizedBox(height: AppSpacing.s12),
            AppButton(
              text: 'Tombol Riset / Hapus (Destructive)',
              variant: AppButtonVariant.destructive,
              onPressed: () {},
              icon: Icons.delete_outline,
            ),
            const SizedBox(height: AppSpacing.s12),
            AppButton(
              text: 'Tombol Outline',
              variant: AppButtonVariant.outline,
              onPressed: () {},
            ),
            const SizedBox(height: AppSpacing.s12),
            const AppButton(
              text: 'Tombol Loading',
              isLoading: true,
              onPressed: null,
            ),
            const SizedBox(height: AppSpacing.s12),
            const AppButton(
              text: 'Tombol Nonaktif (Disabled)',
              onPressed: null,
            ),
            const SizedBox(height: AppSpacing.s24),

            // 4. Form Fields & Amount Field
            const Text('Form Input Fields', style: AppTypography.sectionTitle),
            const SizedBox(height: AppSpacing.s12),
            AppTextField(
              label: 'Nama Lengkap',
              hintText: 'Masukkan nama anda',
              prefixIcon: const Icon(Icons.person_outline, size: 20),
              onChanged: (_) {},
            ),
            const SizedBox(height: AppSpacing.s16),
            const AppTextField(
              label: 'Kata Sandi',
              hintText: 'Masukkan kata sandi',
              isPassword: true,
              prefixIcon: Icon(Icons.lock_outline, size: 20),
            ),
            const SizedBox(height: AppSpacing.s16),
            const AppTextField(
              label: 'Email (Dengan Pesan Error)',
              hintText: 'contoh@favera.id',
              errorText: 'Format email tidak valid',
            ),
            const SizedBox(height: AppSpacing.s16),
            AppAmountField(
              label: 'Nominal Transaksi (Integer Rupiah)',
              initialAmount: _enteredAmount,
              onChanged: (val) {
                setState(() {
                  _enteredAmount = val;
                });
              },
            ),
            const SizedBox(height: AppSpacing.s24),

            // 5. Pill Choice Chips
            const Text('Pill Choice Chips', style: AppTypography.sectionTitle),
            const SizedBox(height: AppSpacing.s12),
            AppPillChoice<String>(
              options: const [
                AppPillChoiceOption(
                    value: 'all', label: 'Semua', icon: Icons.grid_view),
                AppPillChoiceOption(value: 'income', label: 'Pemasukan'),
                AppPillChoiceOption(value: 'expense', label: 'Pengeluaran'),
                AppPillChoiceOption(value: 'review', label: 'Perlu Konfirmasi'),
              ],
              selectedValue: _selectedPill,
              onSelected: (val) {
                setState(() {
                  _selectedPill = val;
                });
              },
            ),
            const SizedBox(height: AppSpacing.s16),
            const Text('Multi-Select Category Chips:',
                style: AppTypography.helper),
            const SizedBox(height: AppSpacing.s8),
            AppPillChoice<String>(
              isMultiSelect: true,
              options: const [
                AppPillChoiceOption(value: 'food', label: 'Belanja Bulanan'),
                AppPillChoiceOption(
                    value: 'electric', label: 'Tagihan Listrik'),
                AppPillChoiceOption(value: 'transport', label: 'Transportasi'),
              ],
              selectedValues: _selectedCategories,
              onMultiSelected: (vals) {
                setState(() {
                  _selectedCategories = vals;
                });
              },
            ),
            const SizedBox(height: AppSpacing.s24),

            // 6. Progress Card & App Card
            const Text('Progress & Financial Goal Card',
                style: AppTypography.sectionTitle),
            const SizedBox(height: AppSpacing.s12),
            AppProgressCard(
              title: 'Dana Darurat Keluarga',
              currentAmount: 5500000,
              targetAmount: 10000000,
              subtitle: 'Disetujui oleh pasangan',
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.s24),

            // 7. Transaction List Rows
            const Text('Transaction Rows', style: AppTypography.sectionTitle),
            const SizedBox(height: AppSpacing.s12),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  AppTransactionRow(
                    title: 'Gaji Bulanan',
                    subtitle: 'Hari ini, 09:00 WIB',
                    amount: 5500000,
                    isExpense: false,
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  AppTransactionRow(
                    title: 'Belanja Bulanan Supermarket',
                    subtitle: 'Kemarin, 14:30 WIB',
                    amount: 150000,
                    isExpense: true,
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  AppTransactionRow(
                    title: 'APPLE.COM/BILL',
                    subtitle: '05 Agt, 18:20 WIB',
                    amount: 1499000,
                    isExpense: true,
                    anomalyBadgeText: 'Perlu Konfirmasi',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),

            // 8. Async Empty & Error Views
            const Text('Async States (Empty & Error)',
                style: AppTypography.sectionTitle),
            const SizedBox(height: AppSpacing.s12),
            AppCard(
              child: const AppEmptyView(
                title: 'Belum Ada Transaksi',
                description:
                    'Catat transaksi pertama anda atau upload e-statement untuk memulai.',
                actionText: 'Tambah Transaksi',
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            AppCard(
              child: AppErrorView(
                title: 'Koneksi Terganggu',
                message:
                    'Tidak dapat terhubung ke server. Periksa jaringan anda.',
                requestId: 'REQ-89412',
                onRetry: () {},
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
