import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_gradient_background.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../application/auth_controller.dart';

class AuthPage extends ConsumerStatefulWidget {
  final bool initialIsRegister;

  const AuthPage({
    super.key,
    this.initialIsRegister = false,
  });

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  late bool _isRegister;

  // Login form controllers
  final _loginEmailController =
      TextEditingController(text: 'joselin.demo@favera.local');
  final _loginPasswordController = TextEditingController(text: '123456');

  // Register form controllers
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  bool _privacyConsent = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isRegister = widget.initialIsRegister;
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
    });

    final success = await ref.read(authControllerProvider.notifier).login(
          _loginEmailController.text,
          _loginPasswordController.text,
        );

    if (success && mounted) {
      context.go(AppRoutePaths.profileSetup);
    } else if (mounted) {
      final state = ref.read(authControllerProvider);
      setState(() {
        _errorMessage = state.error?.toString().replaceAll('Exception: ', '') ??
            'Password salah atau kombinasi tidak ditemukan';
      });
    }
  }

  Future<void> _handleRegister() async {
    setState(() {
      _errorMessage = null;
    });

    final success = await ref.read(authControllerProvider.notifier).register(
          name: _regNameController.text,
          email: _regEmailController.text,
          password: _regPasswordController.text,
          privacyConsent: _privacyConsent,
        );

    if (success && mounted) {
      context.go(AppRoutePaths.profileSetup);
    } else if (mounted) {
      final state = ref.read(authControllerProvider);
      setState(() {
        _errorMessage = state.error?.toString().replaceAll('Exception: ', '') ??
            'Gagal mendaftarkan akun. Periksa data anda.';
      });
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
              children: [
                const SizedBox(height: AppSpacing.s24),

                // Logo Header
                Image.asset(
                  AppAssets.logo,
                  height: 48,
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  'Favera',
                  style: AppTypography.pageTitle.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ruang Aman Transparansi Keuangan Keluarga',
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s32),

                // White Card Container
                Container(
                  padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    boxShadow: AppShadows.card,
                  ),
                  child: Column(
                    children: [
                      // Segmented Control Tabs
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isRegister = false;
                                    _errorMessage = null;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.s12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: !_isRegister
                                        ? AppColors.surface
                                        : Colors.transparent,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.pill),
                                    boxShadow:
                                        !_isRegister ? AppShadows.soft : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Masuk',
                                      style: AppTypography.button.copyWith(
                                        color: !_isRegister
                                            ? AppColors.primaryDark
                                            : AppColors.textSecondary,
                                        fontWeight: !_isRegister
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isRegister = true;
                                    _errorMessage = null;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.s12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _isRegister
                                        ? AppColors.surface
                                        : Colors.transparent,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.pill),
                                    boxShadow:
                                        _isRegister ? AppShadows.soft : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Daftar Akun',
                                      style: AppTypography.button.copyWith(
                                        color: _isRegister
                                            ? AppColors.primaryDark
                                            : AppColors.textSecondary,
                                        fontWeight: _isRegister
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s24),

                      // Error Message Banner
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.s12),
                          decoration: BoxDecoration(
                            color: AppColors.dangerSoft,
                            borderRadius:
                                BorderRadius.circular(AppRadius.input),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.danger,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.s8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.danger,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s16),
                      ],

                      // Form Content
                      if (!_isRegister) ...[
                        // LOGIN FORM
                        AppTextField(
                          label: 'Email',
                          hintText: 'nama@domain.com',
                          controller: _loginEmailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        const SizedBox(height: AppSpacing.s16),
                        AppTextField(
                          label: 'Password',
                          hintText: 'Masukkan password',
                          controller: _loginPasswordController,
                          isPassword: true,
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              context.push(AppRoutePaths.forgotPassword);
                            },
                            child: Text(
                              'Lupa Password?',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s16),
                        AppButton(
                          text: 'Masuk Ke Favera',
                          onPressed: _handleLogin,
                          isLoading: isLoading,
                        ),
                      ] else ...[
                        // REGISTER FORM
                        AppTextField(
                          label: 'Nama Lengkap',
                          hintText: 'Masukkan nama panggilan / lengkap',
                          controller: _regNameController,
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        const SizedBox(height: AppSpacing.s16),
                        AppTextField(
                          label: 'Email',
                          hintText: 'nama@domain.com',
                          controller: _regEmailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        const SizedBox(height: AppSpacing.s16),
                        AppTextField(
                          label: 'Password',
                          hintText: 'Minimal 6 karakter',
                          controller: _regPasswordController,
                          isPassword: true,
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),
                        const SizedBox(height: AppSpacing.s16),

                        // Privacy Consent Checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _privacyConsent,
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _privacyConsent = val ?? false;
                                });
                              },
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Saya menyetujui Kebijakan Privasi & Privasi Pasangan Favera. Data finansial pribadi tidak akan dibagikan tanpa persetujuan.',
                                  style: AppTypography.caption,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s24),

                        AppButton(
                          text: 'Daftar Akun Baru',
                          onPressed: _handleRegister,
                          isLoading: isLoading,
                        ),
                      ],
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
