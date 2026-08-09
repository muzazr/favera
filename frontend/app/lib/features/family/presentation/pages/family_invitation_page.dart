import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_gradient_background.dart';
import '../../application/family_controller.dart';
import '../widgets/consent_dialog.dart';

class FamilyInvitationPage extends ConsumerWidget {
  const FamilyInvitationPage({super.key});

  void _handleAcceptConsent(BuildContext context, WidgetRef ref) {
    ConsentDialog.show(
      context,
      partnerName: 'Siti Nurbaya',
      onConsentApproved: () async {
        final success = await ref
            .read(familyControllerProvider.notifier)
            .joinSpace('S-1029-BZ');

        if (success && context.mounted) {
          context.go(AppRoutePaths.familySuccess);
        }
      },
    );
  }

  void _showRejectConfirmation(
      BuildContext context, WidgetRef ref, String spaceId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        title: const Text('Tolak Permintaan?', style: AppTypography.cardTitle),
        content: const Text(
          'Tindakan ini akan menolak permintaan koneksi ruang aman dari Siti Nurbaya.',
          style: AppTypography.helper,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal', style: AppTypography.button),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ref
                  .read(familyControllerProvider.notifier)
                  .disconnectSpace(spaceId);
              if (context.mounted) {
                context.go(AppRoutePaths.familyConnect);
              }
            },
            child:
                const Text('Ya, Tolak', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyState = ref.watch(familyControllerProvider);
    final familySpace = familyState.value;

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: AppSpacing.s16,
            ),
            child: Column(
              children: [
                // Top Header Row (Close Button top-left)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF111827),
                        size: 24,
                      ),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutePaths.familyConnect);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),

                // Main Invitation Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
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
                      // Avatar with Green Heart Badge
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Stack(
                          children: [
                            const CircleAvatar(
                              radius: 40,
                              backgroundImage:
                                  AssetImage(AppAssets.profileWomen),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF006C4C),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.favorite_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),

                      // Status Header: PERMINTAAN TERHUBUNG
                      const Text(
                        'PERMINTAAN TERHUBUNG',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006C4C),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Sender Name: Siti Nurbaya
                      const Text(
                        'Siti Nurbaya',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),

                      // ID Pill Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EDFF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.badge_outlined,
                              size: 14,
                              color: Color(0xFF6B7280),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'ID: S-1029-BZ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s20),

                      // Message Body
                      const Text(
                        'mengundang Anda untuk berbagi Ruang Aman, mengelola keuangan bersama, dan menyinkronkan Check-In Mingguan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4B5563),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Button 1 (Primary Dark Green): Terima & Hubungkan
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006C4C),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        onPressed: () => _handleAcceptConsent(context, ref),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.handshake_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Terima & Hubungkan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),

                      // Button 2 (Secondary Vibrant Orange): Tolak Permintaan
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7418),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        onPressed: () {
                          _showRejectConfirmation(
                              context, ref, familySpace?.id ?? 'fam-88219');
                        },
                        child: const Text(
                          'Tolak Permintaan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s32),

                // Footer Info Note
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: Color(0xFF6B7280),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Anda selalu dapat memutuskan koneksi kapan saja melalui menu Pengaturan.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF4B5563),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
