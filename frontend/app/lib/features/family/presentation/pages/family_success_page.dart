import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_gradient_background.dart';
import '../../../auth/application/auth_controller.dart';
import '../../application/family_controller.dart';

class FamilySuccessPage extends ConsumerWidget {
  const FamilySuccessPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familySpace = ref.watch(familyControllerProvider).value;
    final user = ref.watch(authControllerProvider).value;
    final displayCode = familySpace?.inviteCode ?? 'TERHUBUNG';
    final partnerName = familySpace?.partnerName ?? 'Pasangan';
    final displayNameText = '${user?.name ?? 'Anda'} & $partnerName';

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: AppSpacing.s24,
            ),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.s16),

                // Top Card: Budi & Pasangan
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Overlapping Avatars
                      SizedBox(
                        width: 110,
                        height: 64,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              left: 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: const CircleAvatar(
                                  radius: 28,
                                  backgroundImage:
                                      AssetImage(AppAssets.profileMen),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: const CircleAvatar(
                                  radius: 28,
                                  backgroundImage:
                                      AssetImage(AppAssets.profileWomen),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),

                      // Title: Budi & Pasangan
                      Text(
                        displayNameText,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),

                      // ID Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B2FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'ID: $displayCode',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),

                      // Encrypted Connection Pill Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F7F0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.link_rounded,
                              size: 16,
                              color: Color(0xFF00875A),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Akun Terhubung secara Enkripsi',
                              style: TextStyle(
                                color: Color(0xFF00875A),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),

                // Middle Card: Ruang Aman Kalian Sudah Siap!
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Ruang Aman Kalian Sudah Siap!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),

                      const Text(
                        'Akun Anda kini terhubung secara aman dengan Siti Nurbaya. Semua data keuangan, target tabungan dan Check-In mingguan akan disinkronkan secara real-time.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4B5563),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s20),

                      // Encryption Protection Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F4ED),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_rounded,
                              size: 15,
                              color: Color(0xFF006C4C),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Dilindungi enkripsi end-to-end',
                              style: TextStyle(
                                color: Color(0xFF006C4C),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s32),

                // Primary Action Button: Masuk Beranda
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B37E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  onPressed: () {
                    context.go(AppRoutePaths.home);
                  },
                  child: const Text(
                    'Masuk Beranda',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
