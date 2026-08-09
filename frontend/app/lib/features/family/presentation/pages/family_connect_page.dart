import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../../core/widgets/app_text_field.dart';
import '../../application/family_controller.dart';
import '../widgets/consent_dialog.dart';

class FamilyConnectPage extends ConsumerStatefulWidget {
  const FamilyConnectPage({super.key});

  @override
  ConsumerState<FamilyConnectPage> createState() => _FamilyConnectPageState();
}

class _FamilyConnectPageState extends ConsumerState<FamilyConnectPage> {
  final _codeController = TextEditingController(text: 'FAV-88219');
  String? _generatedCode;
  bool _copied = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerateCode() async {
    final space =
        await ref.read(familyControllerProvider.notifier).createSpace();
    if (space != null && mounted) {
      setState(() {
        _generatedCode = space.inviteCode;
      });
    }
  }

  void _copyToClipboard() {
    if (_generatedCode != null) {
      Clipboard.setData(ClipboardData(text: _generatedCode!));
      setState(() {
        _copied = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kode undangan berhasil disalin ke clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleJoinRequest() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Masukkan kode undangan 6 karakter pasangan anda';
      });
      return;
    }

    ConsentDialog.show(
      context,
      partnerName: 'Pasangan',
      onConsentApproved: () async {
        final success =
            await ref.read(familyControllerProvider.notifier).joinSpace(code);

        if (success && mounted) {
          context.go(AppRoutePaths.home);
        } else if (mounted) {
          setState(() {
            _errorMessage = 'Kode undangan tidak valid atau telah expired';
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final familyState = ref.watch(familyControllerProvider);
    final isLoading = familyState.isLoading;

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
                  'Hubungkan Akun Pasangan',
                  style: AppTypography.pageTitle,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kelola keuangan bersama secara transparan tanpa tuduhan atau praduga.',
                  style: AppTypography.helper,
                ),
                const SizedBox(height: AppSpacing.s24),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s12),
                    decoration: BoxDecoration(
                      color: AppColors.dangerSoft,
                      borderRadius: BorderRadius.circular(AppRadius.input),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                ],

                // Option A: Generate Invite Code Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    boxShadow: AppShadows.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primarySoft,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.qr_code_rounded,
                              color: AppColors.primaryDark,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          const Text(
                            'Opsi A: Buat Kode Undangan',
                            style: AppTypography.cardTitle,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      const Text(
                        'Bagikan kode ini kepada pasangan anda untuk menghubungkan akun.',
                        style: AppTypography.helper,
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      if (_generatedCode == null) ...[
                        AppButton(
                          text: 'Buat Kode Undangan Baru',
                          variant: AppButtonVariant.outline,
                          onPressed: _handleGenerateCode,
                          isLoading: isLoading,
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s16,
                            vertical: AppSpacing.s12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius:
                                BorderRadius.circular(AppRadius.input),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _generatedCode!,
                                style: AppTypography.pageTitle.copyWith(
                                  color: AppColors.primaryDark,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _copied
                                      ? Icons.check_circle_rounded
                                      : Icons.content_copy_rounded,
                                  color: AppColors.primaryDark,
                                ),
                                onPressed: _copyToClipboard,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),

                // Option B: Enter Partner's Code Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    boxShadow: AppShadows.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.accentOrangeSoft,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.vpn_key_rounded,
                              color: AppColors.accentOrange,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          const Text(
                            'Opsi B: Masukkan Kode Pasangan',
                            style: AppTypography.cardTitle,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      const Text(
                        'Masukkan 6 karakter kode yang dibuat oleh pasangan anda.',
                        style: AppTypography.helper,
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      AppTextField(
                        hintText: 'Contoh: FAV-88219',
                        controller: _codeController,
                        prefixIcon: const Icon(Icons.key_outlined),
                      ),
                      const SizedBox(height: AppSpacing.s24),
                      AppButton(
                        text: 'Hubungkan Akun Pasangan',
                        onPressed: _handleJoinRequest,
                        isLoading: isLoading,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),

                // Privacy Note Banner
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: AppColors.infoSoft,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Text(
                          'Catatan Privasi: Data pribadi (refleksi pribadi, chat AI, dan file e-statement asli) tidak otomatis terlihat oleh pasangan tanpa persetujuan eksplisit.',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
