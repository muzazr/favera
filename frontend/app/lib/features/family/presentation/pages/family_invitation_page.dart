import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_gradient_background.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../../../shared/models/family_model.dart';
import '../../../auth/application/auth_controller.dart';
import '../../application/family_controller.dart';

class FamilyInvitationPage extends ConsumerWidget {
  const FamilyInvitationPage({super.key});

  void _showDisconnectConfirmation(
      BuildContext context, WidgetRef ref, String spaceId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        title: const Text('Putuskan Sambungan Keluarga?',
            style: AppTypography.cardTitle),
        content: const Text(
          'Tindakan ini akan menghentikan pembagian ringkasan keuangan dan target bersama dengan pasangan. Anda dapat terhubung kembali kapan saja.',
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
            child: const Text('Ya, Putuskan',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyState = ref.watch(familyControllerProvider);
    final familySpace = familyState.value;
    final currentUser = ref.watch(authControllerProvider).value;

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Status Ruang Keluarga',
              style: AppTypography.sectionTitle),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                boxShadow: AppShadows.card,
              ),
              child: familySpace != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Kode: ${familySpace.inviteCode}',
                              style: AppTypography.cardTitle,
                            ),
                            AppStatusBadge(
                              label: familySpace.status.name.toUpperCase(),
                              level: familySpace.status == FamilyStatus.active
                                  ? AppStatusLevel.stable
                                  : AppStatusLevel.warning,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s16),
                        Text(
                          'Anggota Keluarga:',
                          style: AppTypography.caption,
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primarySoft,
                            child: Text(
                              (currentUser?.name ?? 'U').substring(0, 1),
                              style:
                                  const TextStyle(color: AppColors.primaryDark),
                            ),
                          ),
                          title: Text(currentUser?.name ?? 'Saya',
                              style: AppTypography.bodyMedium),
                          subtitle: const Text('Akun Utama (Anda)',
                              style: AppTypography.caption),
                        ),
                        if (familySpace.partnerName != null) ...[
                          const Divider(),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.accentOrangeSoft,
                              child: Text('B',
                                  style:
                                      TextStyle(color: AppColors.accentOrange)),
                            ),
                            title: Text(familySpace.partnerName!,
                                style: AppTypography.bodyMedium),
                            subtitle: const Text('Pasangan Terhubung',
                                style: AppTypography.caption),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.s24),
                        AppButton(
                          text: 'Putuskan Hubungan Pasangan',
                          variant: AppButtonVariant.destructive,
                          onPressed: () {
                            _showDisconnectConfirmation(
                                context, ref, familySpace.id);
                          },
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.family_restroom_rounded,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: AppSpacing.s16),
                        const Text(
                          'Belum Terhubung Dengan Pasangan',
                          style: AppTypography.cardTitle,
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        const Text(
                          'Anda belum memiliki akun keluarga yang terhubung.',
                          style: AppTypography.helper,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.s24),
                        AppButton(
                          text: 'Hubungkan Pasangan Sekarang',
                          onPressed: () {
                            context.go(AppRoutePaths.familyConnect);
                          },
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
