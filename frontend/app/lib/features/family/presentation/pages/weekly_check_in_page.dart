import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_async_view.dart';
import '../../../../core/widgets/app_gradient_background.dart';
import '../../application/family_controller.dart';

class WeeklyCheckInPage extends ConsumerStatefulWidget {
  const WeeklyCheckInPage({super.key});

  @override
  ConsumerState<WeeklyCheckInPage> createState() => _WeeklyCheckInPageState();
}

class _WeeklyCheckInPageState extends ConsumerState<WeeklyCheckInPage> {
  String _selectedEmotion = 'damai';
  String _selectedConcern = 'keuangan';
  double _communicationRating = 4.5;
  bool _isSubmitting = false;

  final List<Map<String, String>> _emotions = [
    {'key': 'tertekan', 'emoji': '😫', 'label': 'Tertekan'},
    {'key': 'lelah', 'emoji': '😮‍💨', 'label': 'Lelah'},
    {'key': 'damai', 'emoji': '😌', 'label': 'Damai'},
    {'key': 'senang', 'emoji': '😊', 'label': 'Senang'},
    {'key': 'hebat', 'emoji': '🤩', 'label': 'Hebat'},
  ];

  final List<Map<String, String>> _concerns = [
    {'key': 'keuangan', 'label': 'Keuangan 💸'},
    {'key': 'pekerjaan', 'label': 'Pekerjaan 💻'},
    {'key': 'parenting', 'label': 'Anak & Parenting 👶'},
    {'key': 'rumah', 'label': 'Urusan Rumah 🧹'},
    {'key': 'hubungan', 'label': 'Hubungan 💑'},
    {'key': 'lainnya', 'label': 'Lainnya'},
  ];

  @override
  Widget build(BuildContext context) {
    final checkInAsync = ref.watch(weeklyCheckInControllerProvider);

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFF111827),
              size: 26,
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutePaths.home);
              }
            },
          ),
          centerTitle: true,
          title: const Column(
            children: [
              Text(
                'Check-In Mingguan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Minggu ke-3, Juli 2026',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        body: checkInAsync.when(
          loading: () =>
              const AppLoadingView(message: 'Memuat check-in mingguan...'),
          error: (err, st) => AppErrorView(
            message: err.toString(),
            onRetry: () => ref.invalidate(weeklyCheckInControllerProvider),
          ),
          data: (checkIn) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Emotion Section
                  const Center(
                    child: Text(
                      'Bagaimana perasaanmu secara\nkeseluruhan minggu ini?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Emotion Selector Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _emotions.map((emo) {
                      final isSelected = _selectedEmotion == emo['key'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedEmotion = emo['key']!;
                          });
                        },
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF10B981)
                                      : Colors.transparent,
                                  width: isSelected ? 2.5 : 0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                        alpha: isSelected ? 0.08 : 0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                emo['emoji']!,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              emo['label']!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // 2. Main Concern Chips Section
                  const Text(
                    'Apa yang paling menyita pikiranmu akhir–akhir ini?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 10,
                    runSpacing: 12,
                    children: _concerns.map((cnc) {
                      final isSelected = _selectedConcern == cnc['key'];
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedConcern = cnc['key']!;
                          });
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF10B981)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                    alpha: isSelected ? 0.08 : 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            cnc['label']!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF111827),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // 3. Communication Quality Slider Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kualitas komunikasi dengan pasangan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Custom Styled Slider
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 12,
                            activeTrackColor: const Color(0xFFE0E7FF),
                            inactiveTrackColor: const Color(0xFFF3F4F6),
                            thumbColor: Colors.white,
                            overlayColor:
                                const Color(0xFF10B981).withValues(alpha: 0.1),
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 14,
                              elevation: 4,
                            ),
                          ),
                          child: Slider(
                            value: _communicationRating,
                            min: 1.0,
                            max: 5.0,
                            onChanged: (val) {
                              setState(() {
                                _communicationRating = val;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 4),

                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Banyak Miskom',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                            Text(
                              'Sangat Lancar',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. Reflection Quote Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      '"Keseimbangan bukan tentang pembagian waktu yang sama, tapi tentang kehadiran yang utuh."',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF4B5563),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            );
          },
        ),

        // 5. Sticky Bottom Button: Simpan Jurnal ➢
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final router = GoRouter.of(context);
                      setState(() => _isSubmitting = true);
                      try {
                        final checkIn =
                            ref.read(weeklyCheckInControllerProvider).value;
                        final checkInId = checkIn?.id ?? 'chk-week-32';

                        await ref
                            .read(familyControllerProvider.notifier)
                            .submitCheckIn(
                              checkInId: checkInId,
                              emotion: _selectedEmotion,
                              concern: _selectedConcern,
                            );

                        messenger.showSnackBar(
                          const SnackBar(
                            content:
                                Text('Check-In Mingguan berhasil disimpan!'),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                        router.go(AppRoutePaths.familyCondition);
                      } finally {
                        if (mounted) {
                          setState(() => _isSubmitting = false);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
                minimumSize: Size.zero,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Simpan Jurnal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.send_rounded,
                          size: 18,
                          color: Colors.white,
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
