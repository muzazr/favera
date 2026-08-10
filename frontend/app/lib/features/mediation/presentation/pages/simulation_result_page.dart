import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_async_view.dart';
import '../../../../core/widgets/app_gradient_background.dart';
import '../../application/simulation_controller.dart';

class SimulationResultPage extends ConsumerStatefulWidget {
  const SimulationResultPage({super.key});

  @override
  ConsumerState<SimulationResultPage> createState() =>
      _SimulationResultPageState();
}

class _SimulationResultPageState extends ConsumerState<SimulationResultPage> {
  int _selectedTabIndex = 0; // 0 = Dampak Keuangan, 1 = Dampak Anak

  @override
  Widget build(BuildContext context) {
    final simulationAsync = ref.watch(impactSimulationProvider);

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
                context.go(AppRoutePaths.mediation);
              }
            },
          ),
          centerTitle: true,
          title: const Text(
            'Hasil Simulasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF111827),
                size: 22,
              ),
              onPressed: () {
                _showDisclaimerModal(context);
              },
            ),
          ],
        ),
        body: simulationAsync.when(
          loading: () =>
              const AppLoadingView(message: 'Menghitung simulasi dampak...'),
          error: (err, st) => AppErrorView(
            message: err.toString(),
            onRetry: () => ref.invalidate(impactSimulationProvider),
          ),
          data: (sim) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Auto Data Banner matching Screenshots 2 & 3
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: Color(0xFF3B82F6),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Berdasarkan Data Saat Ini',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E3A8A),
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Simulasi ditarik otomatis dari Saldo Bersama (Rp 12.500.000) dan rata-rata pengeluaran bulanan Anda.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF2563EB),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Segmented Tab Switch matching Screenshots 2 & 3
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFE0E7FF).withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedTabIndex = 0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _selectedTabIndex == 0
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: _selectedTabIndex == 0
                                          ? [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.04),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Dampak Keuangan',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: _selectedTabIndex == 0
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: _selectedTabIndex == 0
                                            ? const Color(0xFF111827)
                                            : const Color(0xFF4B5563),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedTabIndex = 1),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _selectedTabIndex == 1
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: _selectedTabIndex == 1
                                          ? [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.04),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Dampak Anak',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: _selectedTabIndex == 1
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: _selectedTabIndex == 1
                                            ? const Color(0xFF111827)
                                            : const Color(0xFF4B5563),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // TAB CONTENT RENDERER
                        if (_selectedTabIndex == 0)
                          _buildFinancialImpactTab(context)
                        else
                          _buildChildImpactTab(context),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Bottom Fixed Sticky CTA Button matching Screenshots 2 & 3
                Container(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 12,
                    bottom: MediaQuery.of(context).padding.bottom + 12,
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
                      onPressed: () {
                        context.push(AppRoutePaths.professionals);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        elevation: 0,
                        minimumSize: Size.zero,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedTabIndex == 0
                                ? Icons.favorite_rounded
                                : Icons.medical_services_rounded,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedTabIndex == 0
                                ? 'Cari Solusi Bersama Ahli'
                                : 'Konsultasi Bersama Psikolog Anak',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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

  // TAB 1: Dampak Keuangan matching Screenshot 2
  Widget _buildFinancialImpactTab(BuildContext context) {
    return Column(
      children: [
        // Card 1: Proyeksi Saldo Individu
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
              const Row(
                children: [
                  Icon(
                    Icons.account_balance_rounded,
                    color: Color(0xFFD97706),
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Proyeksi Saldo Individu',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildValueRow('Hak Saldo', 'Rp 6.250.000', Colors.black87),
              const SizedBox(height: 10),
              _buildValueRow(
                'Estimasi Biaya Hukum',
                '- Rp 2.500.000',
                const Color(0xFFEF4444),
              ),
              const SizedBox(height: 14),
              const Divider(color: Color(0xFFE5E7EB)),
              const SizedBox(height: 14),

              // Soft Orange Net Balance Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sisa Saldo Bersih Anda',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB45309),
                      ),
                    ),
                    Text(
                      'Rp 3.750.000',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Card 2: Penyesuaian Biaya Hidup
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
              const Row(
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    color: Color(0xFFDC2626),
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Penyesuaian Biaya Hidup',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Cream Note Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Kehilangan status pasangan berpotensi menaikkan biaya asuransi, pajak, dan utilitas rumah tangga yang tadinya ditanggung bersama.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF92400E),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Single Living Increase Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kenaikan Pengeluaran Single',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '+ 30%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Danger Alert Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFDC2626),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Ketahanan Dana Darurat',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Dengan sisa bersih Rp 3.750.000, dana Anda diproyeksikan hanya bertahan 0.8 bulan tanpa sumber pendapatan baru.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7F1D1D),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // TAB 2: Dampak Anak matching Screenshot 3
  Widget _buildChildImpactTab(BuildContext context) {
    return Column(
      children: [
        // Card 1: Kewajiban Logistik Anak
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
              const Row(
                children: [
                  Icon(
                    Icons.groups_rounded,
                    color: Color(0xFF059669),
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Kewajiban Logistik Anak',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildValueRow(
                'Histori Pengeluaran Anak',
                'Rp 2.000.000 / bln',
                Colors.black87,
              ),
              const SizedBox(height: 10),
              _buildValueRow(
                'Biaya Tambahan (2 Rumah/Transpor)',
                '+ Rp 800.000',
                const Color(0xFFEF4444),
              ),
              const SizedBox(height: 14),
              const Divider(color: Color(0xFFE5E7EB)),
              const SizedBox(height: 14),
              _buildValueRow(
                'Total Kebutuhan Baru',
                'Rp 2.800.000 / bln',
                const Color(0xFF111827),
                isBold: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Card 2: Kesejahteraan Emosional Anak
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
              const Row(
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFF7C3AED),
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Kesejahteraan Emosional Anak',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Purple Border Note Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDDD6FE)),
                ),
                child: const Text(
                  'Anak akan membutuhkan waktu adaptasi 6–12 bulan. Perubahan perilaku atau penurunan fokus belajar adalah respons wajar yang sering memerlukan pendampingan profesional.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5B21B6),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              _buildValueRow(
                'Waktu Harian dgn Masing-Masing Orang Tua',
                'Berkurang ~50%',
                const Color(0xFFD97706),
              ),
              const SizedBox(height: 10),
              _buildValueRow(
                'Estimasi Sesi Konseling Anak',
                'Rp 500rb – 1Jt / sesi',
                const Color(0xFF374151),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Card 3: Dampak pada Sisa Saldo Anda
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
              const Text(
                'Dampak pada Sisa Saldo Anda',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFDC2626),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Ketahanan Dana Darurat Anda',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Beban Kritis: Kebutuhan anak (Rp 2.800.000) dan potensi terapi akan memakan >75% dari estimasi sisa saldo bersih individu Anda (Rp 3.750.000). Ketahanan dana keluarga sangat rentan.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7F1D1D),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValueRow(String label, String val, Color valColor,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: const Color(0xFF4B5563),
            ),
          ),
        ),
        Text(
          val,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valColor,
          ),
        ),
      ],
    );
  }

  void _showDisclaimerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Penjelasan Formula Simulasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Simulasi ini dihitung secara otomatis berdasarkan saldo bersama terdaftar dan rata-rata pengeluaran bulanan. Hasil ini bersifat proyeksi indikatif netral untuk membantu pengambilan keputusan keluarga, bukan nasihat hukum atau prediksi perceraian.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4B5563),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    elevation: 0,
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Saya Mengerti'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
