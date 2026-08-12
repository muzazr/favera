import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/errors/app_failure.dart';
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

  String _parseError(dynamic error, String fallback) {
    if (error == null) return fallback;
    if (error is AppFailure) {
      if (error is NetworkFailure) return error.message ?? 'Koneksi terganggu. Periksa jaringan Anda.';
      if (error is AuthFailure) return error.message ?? 'Password salah atau kombinasi tidak ditemukan.';
      if (error is UnauthorizedFailure) return error.message ?? 'Sesi telah berakhir, silakan masuk kembali.';
      if (error is ValidationFailure) return error.message ?? 'Data yang dimasukkan tidak valid.';
      if (error is ServerFailure) return error.message ?? 'Terjadi kesalahan pada server.';
    }
    return error.toString().replaceAll('Exception: ', '');
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
        _errorMessage = _parseError(
          state.error,
          'Password salah atau kombinasi tidak ditemukan',
        );
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
      _loginEmailController.text = _regEmailController.text;
      _loginPasswordController.clear();
      setState(() {
        _isRegister = false;
        _errorMessage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun berhasil dibuat! Silakan masuk dengan email dan kata sandi Anda.'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      final state = ref.read(authControllerProvider);
      setState(() {
        _errorMessage = _parseError(
          state.error,
          'Gagal mendaftarkan akun. Periksa data anda.',
        );
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
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: AppSpacing.s16,
            ),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.s16),

                // 1. Logo Header inside White Squircle
                Container(
                  width: 64,
                  height: 64,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    AppAssets.logo,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),

                // 2. App Name Title in Solid Dark Text (NOT green)
                Text(
                  'Favera',
                  style: AppTypography.pageTitle.copyWith(
                    color: const Color(0xFF111827),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),

                // 3. Main Auth White Card with Top Mint Glow Shadow
                Container(
                  padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      // Top Green Glow Shadow Accent
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.20),
                        blurRadius: 24,
                        spreadRadius: 1,
                        offset: const Offset(0, -3),
                      ),
                      // Soft Drop Shadow
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Segmented Control Tabs ("Masuk" vs "Daftar")
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF0F8),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            // Tab 1: Masuk
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
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: !_isRegister
                                        ? [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.08),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Masuk',
                                      style: TextStyle(
                                        color: const Color(0xFF111827),
                                        fontWeight: !_isRegister
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Tab 2: Daftar
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
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: _isRegister
                                        ? [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.08),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Daftar',
                                      style: TextStyle(
                                        color: const Color(0xFF111827),
                                        fontWeight: _isRegister
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        fontSize: 14,
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
                        // 4. LOGIN FORM
                        AppTextField(
                          label: 'Email atau Nomor HP',
                          hintText: 'nama@email.com',
                          controller: _loginEmailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(
                            Icons.mail_outline_rounded,
                            color: Color(0xFF6B7280),
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s16),

                        AppTextField(
                          label: 'Kata Sandi',
                          hintText: '••••••••',
                          controller: _loginPasswordController,
                          isPassword: true,
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: Color(0xFF6B7280),
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s8),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              context.push(AppRoutePaths.forgotPassword);
                            },
                            child: const Text(
                              'Lupa kata sandi?',
                              style: TextStyle(
                                color: Color(0xFF00875A),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s20),

                        // Solid Dark Emerald Green Login Button
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
                          onPressed: isLoading ? null : _handleLogin,
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Masuk',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                        const SizedBox(height: AppSpacing.s24),

                        // Social Login Divider
                        Row(
                          children: [
                            const Expanded(
                                child: Divider(color: Color(0xFFE5E7EB))),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'Atau masuk dengan',
                                style: AppTypography.caption.copyWith(
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                            const Expanded(
                                child: Divider(color: Color(0xFFE5E7EB))),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s16),

                        // Dummy Social Buttons Row
                        Row(
                          children: [
                            // Google Button (Dummy)
                            Expanded(
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: () {
                                      // Dummy button - no action
                                    },
                                    child: Center(
                                      child: Image.asset(
                                        AppAssets.googleLogo,
                                        height: 24,
                                        width: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s16),

                            // Apple Button (Dummy)
                            Expanded(
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF111827),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: () {
                                      // Dummy button - no action
                                    },
                                    child: Center(
                                      child: Image.asset(
                                        AppAssets.appleLogo,
                                        height: 20,
                                        width: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // 5. REGISTER FORM
                        AppTextField(
                          label: 'Nama Panggilan',
                          hintText: 'Misal: Budi',
                          controller: _regNameController,
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            color: Color(0xFF6B7280),
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s16),

                        AppTextField(
                          label: 'Email Aktif',
                          hintText: 'nama@email.com',
                          controller: _regEmailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(
                            Icons.mail_outline_rounded,
                            color: Color(0xFF6B7280),
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s16),

                        AppTextField(
                          label: 'Buat Kata Sandi',
                          hintText: 'Minimal 8 karakter',
                          controller: _regPasswordController,
                          isPassword: true,
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: Color(0xFF6B7280),
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s16),

                        // Privacy Consent Checkbox with RichText
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _privacyConsent,
                                activeColor: const Color(0xFF10B981),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _privacyConsent = val ?? false;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    color: Color(0xFF374151),
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          'Dengan mendaftar, saya menyetujui ',
                                    ),
                                    TextSpan(
                                      text: 'Syarat & Ketentuan',
                                      style: TextStyle(
                                        color: Color(0xFF00875A),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' serta ',
                                    ),
                                    TextSpan(
                                      text: 'Kebijakan Privasi',
                                      style: TextStyle(
                                        color: Color(0xFF00875A),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' yang berlaku.',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s24),

                        // Vibrant Green "Buat Akun" Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00B37E),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          onPressed: isLoading ? null : _handleRegister,
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Buat Akun',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),

                // 6. Security & Privacy Footer Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 14,
                      color: Color(0xFF006C4C),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      !_isRegister
                          ? 'Privasi 100% Terjamin. Data dienkripsi secara aman.'
                          : 'Data Anda dienkripsi secara end-to-end.',
                      style: const TextStyle(
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
