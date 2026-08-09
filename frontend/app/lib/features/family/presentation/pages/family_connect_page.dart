import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_gradient_background.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../shared/models/family_model.dart';
import '../../application/family_controller.dart';
import '../widgets/consent_dialog.dart';
import 'family_success_page.dart';

class FamilyConnectPage extends ConsumerStatefulWidget {
  const FamilyConnectPage({super.key});

  @override
  ConsumerState<FamilyConnectPage> createState() => _FamilyConnectPageState();
}

class _FamilyConnectPageState extends ConsumerState<FamilyConnectPage> {
  final _codeController = TextEditingController(text: 'S-1029-BZ');
  bool _copied = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code));
    setState(() {
      _copied = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ID Ruang Aman berhasil disalin ke clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleJoinRequest() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Masukkan ID pasangan Anda';
      });
      return;
    }

    ConsentDialog.show(
      context,
      partnerName: 'Siti Nurbaya',
      onConsentApproved: () async {
        final success =
            await ref.read(familyControllerProvider.notifier).joinSpace(code);

        if (success && mounted) {
          context.go(AppRoutePaths.familySuccess);
        } else if (mounted) {
          setState(() {
            _errorMessage = 'ID Pasangan tidak ditemukan atau tidak valid';
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final familyState = ref.watch(familyControllerProvider);
    final familySpace = familyState.value;
    final isLoading = familyState.isLoading;

    // If family space is already active, show the active paired space view (Screenshot 3)
    if (familySpace != null && familySpace.status == FamilyStatus.active) {
      return const FamilySuccessPage();
    }

    final myInviteCode = familySpace?.inviteCode ?? 'R-8392-AX';

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row (Back Button & Help Icon)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Circular White Back Button
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          color: Color(0xFF111827),
                          size: 24,
                        ),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(AppRoutePaths.home);
                          }
                        },
                      ),
                    ),

                    // Circular White Help Button
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.help_outline_rounded,
                          color: Color(0xFF111827),
                          size: 20,
                        ),
                        onPressed: () {
                          // Help info tooltip
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s24),

                // Title & Subtitle
                const Text(
                  'Hubungkan Akun',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                const Text(
                  'Masukkan ID Pasanganmu untuk mulai mengelola keuangan dan membangun ruang aman bersama.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                    height: 1.4,
                  ),
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

                // Main White Card
                Container(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label: ID Ruang Aman Anda
                      const Text(
                        'ID Ruang Aman Anda',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),

                      // Blue Soft Pill Container with Code & Salin Button
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCE4FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              myInviteCode,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                                letterSpacing: 1.5,
                              ),
                            ),

                            // White Salin Button
                            InkWell(
                              onTap: () => _copyToClipboard(myInviteCode),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Salin',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      _copied
                                          ? Icons.check_rounded
                                          : Icons.copy_rounded,
                                      size: 14,
                                      color: const Color(0xFF111827),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s24),

                      // Divider — ATAU —
                      Row(
                        children: [
                          const Expanded(
                              child: Divider(color: Color(0xFFE5E7EB))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'ATAU',
                              style: AppTypography.caption.copyWith(
                                color: const Color(0xFF9CA3AF),
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const Expanded(
                              child: Divider(color: Color(0xFFE5E7EB))),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s20),

                      // Label: Masukkan ID Pasangan
                      const Text(
                        'Masukkan ID Pasangan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),

                      AppTextField(
                        hintText: 'Ketik atau tempel ID di sini...',
                        controller: _codeController,
                        prefixIcon: const Icon(
                          Icons.link_rounded,
                          color: Color(0xFF6B7280),
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s24),

                      // Primary Button: Kirim Permintaan →
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
                        onPressed: isLoading ? null : _handleJoinRequest,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isLoading)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            else ...[
                              const Text(
                                'Kirim Permintaan',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),

                // Button below Card: Cek Permintaan Ruang Aman
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () {
                    context.push(AppRoutePaths.familyInvitation);
                  },
                  child: const Text(
                    'Cek Permintaan Ruang Aman',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s32),

                // Footer text
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.aspect_ratio_rounded,
                      size: 14,
                      color: Color(0xFF006C4C),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Koneksi diamankan dengan enkripsi end-to-end.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF4B5563),
                        fontWeight: FontWeight.w500,
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
