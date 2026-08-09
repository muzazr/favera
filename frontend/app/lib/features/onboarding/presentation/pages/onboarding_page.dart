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
import '../../../auth/application/auth_controller.dart';

class OnboardingSlide {
  final String imagePath;
  final String title;
  final String description;

  const OnboardingSlide({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const List<OnboardingSlide> slides = [
    OnboardingSlide(
      imagePath: AppAssets.onboarding1,
      title: 'Satu Ruang untuk Uang dan Perasaan',
      description:
          'Favera membantu keluarga mengenali perubahan finansial dan emosional sejak dini dalam satu tempat yang aman.',
    ),
    OnboardingSlide(
      imagePath: AppAssets.onboarding2,
      title: 'Transparansi Tanpa Menghakimi',
      description:
          'Konfirmasi pengeluaran dan transaksi tidak biasa bersama pasangan tanpa tuduhan atau praduga bersalah.',
    ),
    OnboardingSlide(
      imagePath: AppAssets.onboarding3,
      title: 'Komunikasi dan Akses Bantuan',
      description:
          'Dapatkan panduan komunikasi netral, pendampingan AI empatik, dan rujukan tenaga profesional saat dibutuhkan.',
    ),
  ];

  void _onCompleteOnboarding() {
    ref.read(authControllerProvider.notifier).completeOnboarding();
    context.go(AppRoutePaths.login);
  }

  void _onNext() {
    if (_currentIndex < slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _onCompleteOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar with Skip Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                  vertical: AppSpacing.s8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_currentIndex < slides.length - 1)
                      TextButton(
                        onPressed: _onCompleteOnboarding,
                        child: Text(
                          'Lewati',
                          style: AppTypography.button.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // PageView for Slides
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: slides.length,
                  itemBuilder: (context, index) {
                    final slide = slides[index];
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.pagePadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Image.asset(
                              slide.imagePath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom White Rounded Panel
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.r32),
                    topRight: Radius.circular(AppRadius.r32),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dot Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(slides.length, (index) {
                        final isActive = index == _currentIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                isActive ? AppColors.primary : AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: AppSpacing.s24),

                    // Title & Description
                    Text(
                      slides[_currentIndex].title,
                      style: AppTypography.pageTitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    Text(
                      slides[_currentIndex].description,
                      style: AppTypography.helper,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.s32),

                    // Primary Button
                    AppButton(
                      text: _currentIndex == slides.length - 1
                          ? 'Mulai Sekarang'
                          : 'Lanjut',
                      onPressed: _onNext,
                      icon: _currentIndex == slides.length - 1
                          ? Icons.arrow_forward_rounded
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
