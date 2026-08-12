import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_gradient_background.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/application/auth_controller.dart';

class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  final _nameController = TextEditingController();
  String _selectedAvatar = AppAssets.profileWomen;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).value;
    if (user != null) {
      _nameController.text = user.name;
      if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
        _selectedAvatar = user.avatarUrl!;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .updateProfile(name: name, avatarUrl: _selectedAvatar);

    if (success && mounted) {
      context.go(AppRoutePaths.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.s24),
                const Text(
                  'Lengkapi Profil Anda',
                  style: AppTypography.pageTitle,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Nama dan foto profil ini akan terlihat oleh pasangan anda setelah terhubung.',
                  style: AppTypography.helper,
                ),
                const SizedBox(height: AppSpacing.s32),

                // Card Box
                Container(
                  padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pilih Avatar / Foto Profil:',
                        style: AppTypography.sectionTitle,
                      ),
                      const SizedBox(height: AppSpacing.s16),

                      // Avatar Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedAvatar = AppAssets.profileWomen;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      _selectedAvatar == AppAssets.profileWomen
                                          ? AppColors.primary
                                          : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 44,
                                backgroundImage:
                                    AssetImage(AppAssets.profileWomen),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s24),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedAvatar = AppAssets.profileMen;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _selectedAvatar == AppAssets.profileMen
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 44,
                                backgroundImage:
                                    AssetImage(AppAssets.profileMen),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s32),

                      AppTextField(
                        label: 'Nama Panggilan Dalam Keluarga',
                        hintText: 'Misal: Joselin, Budi, Ayah, Ibu',
                        controller: _nameController,
                        prefixIcon: const Icon(Icons.badge_outlined),
                      ),
                      const SizedBox(height: AppSpacing.s32),

                      AppButton(
                        text: 'Simpan & Lanjutkan',
                        onPressed: _handleSave,
                        isLoading: isLoading,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
