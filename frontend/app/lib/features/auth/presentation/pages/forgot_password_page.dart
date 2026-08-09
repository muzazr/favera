import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_gradient_background.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../application/auth_controller.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _submitted = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Masukkan alamat email anda terlebih dahulu';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .forgotPassword(_emailController.text);
      setState(() {
        _submitted = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title:
              const Text('Reset Password', style: AppTypography.sectionTitle),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: _submitted
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.mark_email_read_outlined,
                          size: 64,
                          color: AppColors.success,
                        ),
                        const SizedBox(height: AppSpacing.s16),
                        const Text(
                          'Instruksi Reset Terkirim!',
                          style: AppTypography.cardTitle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        Text(
                          'Kami telah mengirimkan tautan reset password ke email ${_emailController.text}. Silakan periksa kotak masuk anda.',
                          style: AppTypography.helper,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.s24),
                        AppButton(
                          text: 'Kembali Ke Halaman Masuk',
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lupa Password Akun?',
                          style: AppTypography.cardTitle,
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        const Text(
                          'Masukkan email terdaftar anda. Kami akan mengirimkan tautan aman untuk membuat password baru.',
                          style: AppTypography.helper,
                        ),
                        const SizedBox(height: AppSpacing.s24),
                        if (_errorMessage != null) ...[
                          Text(
                            _errorMessage!,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.danger,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s8),
                        ],
                        AppTextField(
                          label: 'Email Terdaftar',
                          hintText: 'nama@domain.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        const SizedBox(height: AppSpacing.s24),
                        AppButton(
                          text: 'Kirim Link Reset Password',
                          onPressed: _handleSubmit,
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
