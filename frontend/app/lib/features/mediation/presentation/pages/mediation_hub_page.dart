import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_gradient_background.dart';

class MediationHubPage extends StatelessWidget {
  const MediationHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: context.canPop()
              ? IconButton(
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    color: Color(0xFF111827),
                    size: 28,
                  ),
                  onPressed: () => context.pop(),
                )
              : null,
          centerTitle: true,
          title: const Text(
            'Ruang Mediasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtitle Text
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Apapun situasinya, kami hadir untuk membantu Anda dan keluarga berdiskusi dan mengambil keputusan dengan tenang.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Card 0: Ruang Pemulihan Bersama (Modul 8 & 9)
              _buildMediationCard(
                context: context,
                assetPath: '',
                fallbackIcon: Icons.handshake_rounded,
                iconBgColor: const Color(0xFFEEF2FF),
                title: 'Ruang Pemulihan & Komitmen Bersama',
                description:
                    'Mediasi terpandu saat terjadi konflik emosional atau finansial, serta penyusunan komitmen bersama pasangan.',
                buttonText: 'Buka Pemulihan ➔',
                buttonBgColor: const Color(0xFFE0E7FF),
                buttonTextColor: const Color(0xFF4338CA),
                onTap: () {
                  context.push(AppRoutePaths.recoverySessions);
                },
              ),
              const SizedBox(height: 16),

              // Card 1: Konselor AI Empatik
              _buildMediationCard(
                context: context,
                assetPath: AppAssets.aiEmpatikLogo,
                fallbackIcon: Icons.smart_toy_rounded,
                iconBgColor: const Color(0xFFFEF9C3),
                title: 'Konselor AI Empatik',
                description:
                    'Ceritakan masalah keuangan keluarga tanpa takut dihakimi. Tersedia 24/7.',
                buttonText: 'Mulai Chat ➔',
                buttonBgColor: const Color(0xFFFEF3C7),
                buttonTextColor: const Color(0xFF111827),
                onTap: () {
                  context.push('/app/mediation/chat/session-demo-001');
                },
              ),
              const SizedBox(height: 16),

              // Card 2: Bicara dengan Ahli
              _buildMediationCard(
                context: context,
                assetPath: AppAssets.bicaraAhliLogo,
                fallbackIcon: Icons.psychology_rounded,
                iconBgColor: const Color(0xFFE0F2FE),
                title: 'Bicara dengan Ahli',
                description:
                    'Jadwalkan sesi mediasi dengan psikolog pernikahan atau perencana keuangan.',
                buttonText: 'Lihat Direktori ➔',
                buttonBgColor: const Color(0xFFEFF6FF),
                buttonTextColor: const Color(0xFF1D4ED8),
                onTap: () {
                  context.push(AppRoutePaths.professionals);
                },
              ),
              const SizedBox(height: 16),

              // Card 3: Simulasi Dampak
              _buildMediationCard(
                context: context,
                assetPath: AppAssets.simulasiDampakLogo,
                fallbackIcon: Icons.query_stats_rounded,
                iconBgColor: const Color(0xFFF3E8FF),
                title: 'Simulasi Dampak',
                description:
                    'Lihat proyeksi objektif pembagian aset dan dampak logistik pada anak.',
                buttonText: 'Hitung Realita ➔',
                buttonBgColor: const Color(0xFFF3E8FF),
                buttonTextColor: const Color(0xFF6B21A8),
                onTap: () {
                  context.push(AppRoutePaths.simulationNew);
                },
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediationCard({
    required BuildContext context,
    required String assetPath,
    required IconData fallbackIcon,
    required Color iconBgColor,
    required String title,
    required String description,
    required String buttonText,
    required Color buttonBgColor,
    required Color buttonTextColor,
    required VoidCallback onTap,
  }) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Asset Icon Box
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  assetPath,
                  errorBuilder: (ctx, err, stack) => Icon(
                    fallbackIcon,
                    size: 32,
                    color: buttonTextColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Title & Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4B5563),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action Button
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 80),
              child: SizedBox(
                height: 38,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonBgColor,
                    foregroundColor: buttonTextColor,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 0,
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: buttonTextColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
