import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_scaffold.dart';
import 'route_names.dart';

class RouteCatalogGroup {
  final String title;
  final List<RouteCatalogItem> items;

  const RouteCatalogGroup({
    required this.title,
    required this.items,
  });
}

class RouteCatalogItem {
  final String name;
  final String path;
  final String description;

  const RouteCatalogItem({
    required this.name,
    required this.path,
    required this.description,
  });
}

class RouteCatalogPage extends StatelessWidget {
  const RouteCatalogPage({super.key});

  static const List<RouteCatalogGroup> routeGroups = [
    RouteCatalogGroup(
      title: '1. Onboarding & Auth',
      items: [
        RouteCatalogItem(
          name: AppRouteNames.onboarding,
          path: AppRoutePaths.onboarding,
          description: 'Onboarding 3 slide intro',
        ),
        RouteCatalogItem(
          name: AppRouteNames.login,
          path: AppRoutePaths.login,
          description: 'Halaman login pengguna',
        ),
        RouteCatalogItem(
          name: AppRouteNames.register,
          path: AppRoutePaths.register,
          description: 'Registrasi akun baru',
        ),
        RouteCatalogItem(
          name: AppRouteNames.forgotPassword,
          path: AppRoutePaths.forgotPassword,
          description: 'Lupa password & reset link',
        ),
        RouteCatalogItem(
          name: AppRouteNames.profileSetup,
          path: AppRoutePaths.profileSetup,
          description: 'Lengkapi profil awal',
        ),
      ],
    ),
    RouteCatalogGroup(
      title: '2. Family Pairing',
      items: [
        RouteCatalogItem(
          name: AppRouteNames.familyConnect,
          path: AppRoutePaths.familyConnect,
          description: 'Hubungkan akun keluarga / pasangan',
        ),
        RouteCatalogItem(
          name: AppRouteNames.familyInvitation,
          path: AppRoutePaths.familyInvitation,
          description: 'Undangan pairing pending/diterima',
        ),
      ],
    ),
    RouteCatalogGroup(
      title: '3. Root Application Shell Tabs',
      items: [
        RouteCatalogItem(
          name: AppRouteNames.home,
          path: AppRoutePaths.home,
          description: 'Tab 1: Home Dashboard Keluarga',
        ),
        RouteCatalogItem(
          name: AppRouteNames.finance,
          path: AppRoutePaths.finance,
          description: 'Tab 2: Finance Dashboard',
        ),
        RouteCatalogItem(
          name: AppRouteNames.mediation,
          path: AppRoutePaths.mediation,
          description: 'Tab 3: Mediation & Recovery Hub',
        ),
        RouteCatalogItem(
          name: AppRouteNames.profile,
          path: AppRoutePaths.profile,
          description: 'Tab 4: Profile & Settings Home',
        ),
      ],
    ),
    RouteCatalogGroup(
      title: '4. Domain Finance',
      items: [
        RouteCatalogItem(
          name: AppRouteNames.transactions,
          path: AppRoutePaths.transactions,
          description: 'Riwayat transaksi manual & parsing',
        ),
        RouteCatalogItem(
          name: AppRouteNames.transactionNew,
          path: AppRoutePaths.transactionNew,
          description: 'Tambah transaksi pemasukan/pengeluaran',
        ),
        RouteCatalogItem(
          name: AppRouteNames.statementUpload,
          path: AppRoutePaths.statementUpload,
          description: 'Upload e-statement PDF/CSV',
        ),
        RouteCatalogItem(
          name: AppRouteNames.statementReview,
          path: '/app/finance/statements/stm-demo-001/review',
          description: 'Review draft transaksi anomali',
        ),
        RouteCatalogItem(
          name: AppRouteNames.goals,
          path: AppRoutePaths.goals,
          description: 'Daftar financial goals bersama',
        ),
        RouteCatalogItem(
          name: AppRouteNames.goalNew,
          path: AppRoutePaths.goalNew,
          description: 'Buat target keuangan baru',
        ),
      ],
    ),
    RouteCatalogGroup(
      title: '5. Domain Mediasi & Pemulihan',
      items: [
        RouteCatalogItem(
          name: AppRouteNames.chatSessions,
          path: AppRoutePaths.chatSessions,
          description: 'Sesi AI Chat Empatik',
        ),
        RouteCatalogItem(
          name: AppRouteNames.recoverySessions,
          path: AppRoutePaths.recoverySessions,
          description: 'Ruang Pemulihan Bersama',
        ),
        RouteCatalogItem(
          name: AppRouteNames.professionals,
          path: AppRoutePaths.professionals,
          description: 'Direktori Tenaga Profesional',
        ),
        RouteCatalogItem(
          name: AppRouteNames.consultations,
          path: AppRoutePaths.consultations,
          description: 'Jadwal & catatan konsultasi',
        ),
        RouteCatalogItem(
          name: AppRouteNames.simulationNew,
          path: AppRoutePaths.simulationNew,
          description: 'Simulasi dampak finansial & anak',
        ),
      ],
    ),
    RouteCatalogGroup(
      title: '6. Domain Profil & Pengaturan',
      items: [
        RouteCatalogItem(
          name: AppRouteNames.settings,
          path: AppRoutePaths.settings,
          description: 'Pengaturan aplikasi & privasi',
        ),
        RouteCatalogItem(
          name: AppRouteNames.privacy,
          path: AppRoutePaths.privacy,
          description: 'Kebijakan privasi & enkripsi',
        ),
        RouteCatalogItem(
          name: AppRouteNames.familySettings,
          path: AppRoutePaths.familySettings,
          description: 'Pengaturan ruang keluarga & consent',
        ),
      ],
    ),
    RouteCatalogGroup(
      title: '7. Debug Tools',
      items: [
        RouteCatalogItem(
          name: AppRouteNames.debugGallery,
          path: AppRoutePaths.debugGallery,
          description: 'Component Gallery Design System',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Katalog Route Debug'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.s12),
            const Text('Daftar Route Terdaftar',
                style: AppTypography.pageTitle),
            const SizedBox(height: 4),
            const Text(
              'Gunakan katalog ini untuk menguji navigasi cepat seluruh halaman',
              style: AppTypography.helper,
            ),
            const SizedBox(height: AppSpacing.s24),
            ...routeGroups.map((group) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.title, style: AppTypography.sectionTitle),
                  const SizedBox(height: AppSpacing.s12),
                  ...group.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                      child: AppCard(
                        onTap: () {
                          final previewPath = item.path.contains('?')
                              ? '${item.path}&preview=true'
                              : '${item.path}?preview=true';
                          context.push(previewPath);
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.link_rounded,
                                color: AppColors.primaryDark,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name,
                                      style: AppTypography.bodyMedium),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.path} · ${item.description}',
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: AppSpacing.s16),
                ],
              );
            }),
            AppButton(
              text: 'Buka Pratinjau Component Gallery',
              variant: AppButtonVariant.outline,
              onPressed: () => context.push(AppRoutePaths.debugGallery),
              icon: Icons.palette_outlined,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
