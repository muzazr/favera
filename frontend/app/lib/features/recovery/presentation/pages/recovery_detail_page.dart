import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_async_view.dart';
import '../../../../core/widgets/app_gradient_background.dart';
import '../../../../shared/models/recovery_model.dart';
import '../../application/recovery_controller.dart';

class RecoveryDetailPage extends ConsumerStatefulWidget {
  final String sessionId;

  const RecoveryDetailPage({
    super.key,
    required this.sessionId,
  });

  @override
  ConsumerState<RecoveryDetailPage> createState() => _RecoveryDetailPageState();
}

class _RecoveryDetailPageState extends ConsumerState<RecoveryDetailPage> {
  final _reflectionController = TextEditingController();
  final _statementController = TextEditingController();
  final _commitmentTitleController = TextEditingController(
    text: 'Batas Pengeluaran Hiburan Rp 1.5M/Bulan',
  );
  final _commitmentDescController = TextEditingController(
    text:
        'Menyetujui alokasi pengeluaran hiburan keluarga maksimal Rp 1.500.000 per bulan dan meninjau bersama di akhir bulan.',
  );

  bool _initializedTexts = false;

  @override
  void dispose() {
    _reflectionController.dispose();
    _statementController.dispose();
    _commitmentTitleController.dispose();
    _commitmentDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync =
        ref.watch(recoverySessionDetailProvider(widget.sessionId));

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Color(0xFF111827),
              size: 28,
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutePaths.recoverySessions);
              }
            },
          ),
          centerTitle: true,
          title: const Text(
            'Sesi Pemulihan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
        ),
        body: sessionAsync.when(
          loading: () =>
              const AppLoadingView(message: 'Memuat sesi pemulihan...'),
          error: (err, st) => AppErrorView(
            message: err.toString(),
            onRetry: () =>
                ref.invalidate(recoverySessionDetailProvider(widget.sessionId)),
          ),
          data: (session) {
            if (session == null) {
              return const AppEmptyView(
                title: 'Sesi Tidak Ditemukan',
                description: 'Sesi pemulihan yang dicari tidak ditemukan.',
              );
            }

            if (!_initializedTexts) {
              _initializedTexts = true;
              if (session.privateReflection != null) {
                _reflectionController.text = session.privateReflection!;
              } else {
                _reflectionController.text =
                    'Saya merasa perlu lebih terbuka mengenai pos pengeluaran hiburan agar kita bisa capai target tabungan rumah bersama.';
              }

              if (session.publishedStatement != null) {
                _statementController.text = session.publishedStatement!;
              } else {
                _statementController.text =
                    'Saya ingin kita menetapkan batas pengeluaran hiburan bulanan dan fokus menambah tabungan darurat secara bertahap.';
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Topic Header Card
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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0E7FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                session.topic.displayLabel,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4F46E5),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          session.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // STEP ROUTER & STATE MACHINE RENDERER
                  if (session.status == RecoverySessionStatus.readinessCheck)
                    _buildReadinessStep(context, session)
                  else if (session.status ==
                      RecoverySessionStatus.mediationRecommended)
                    _buildSafetyOverrideStep(context)
                  else if (session.status ==
                      RecoverySessionStatus.privateReflection)
                    _buildReflectionStep(context, session)
                  else if (session.status ==
                      RecoverySessionStatus.waitingForPartner)
                    _buildWaitingStep(context, session)
                  else if (session.status == RecoverySessionStatus.alignment)
                    _buildAlignmentStep(context, session)
                  else if (session.status ==
                          RecoverySessionStatus.commitmentActive ||
                      session.status == RecoverySessionStatus.completed)
                    _buildCommitmentActiveStep(context, session),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // STEP 1: Readiness & Safety Check
  Widget _buildReadinessStep(BuildContext context, RecoverySession session) {
    return Container(
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
            'Langkah 1: Cek Kesiapan & Keselamatan Emosional',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sebelum memulai diskusi, Favera ingin memastikan Anda berada dalam kondisi tenang dan merasa aman untuk berkomunikasi.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Option 1: Ready & Safe
          _buildReadinessOption(
            icon: Icons.check_circle_outline_rounded,
            color: const Color(0xFF10B981),
            title: 'Saya Siap & Merasa Aman',
            subtitle: 'Saya tenang dan bersedia berdiskusi secara sehat.',
            onTap: () async {
              await ref
                  .read(recoveryControllerProvider.notifier)
                  .submitReadiness(
                    sessionId: session.id,
                    level: ReadinessLevel.ready,
                  );
              ref.invalidate(recoverySessionDetailProvider(session.id));
            },
          ),
          const SizedBox(height: 12),

          // Option 2: Need Time
          _buildReadinessOption(
            icon: Icons.timer_outlined,
            color: const Color(0xFFF59E0B),
            title: 'Saya Butuh Waktu Sejenak',
            subtitle: 'Saya ingin jeda sejenak untuk menenangkan pikiran.',
            onTap: () async {
              await ref
                  .read(recoveryControllerProvider.notifier)
                  .submitReadiness(
                    sessionId: session.id,
                    level: ReadinessLevel.needTime,
                  );
              ref.invalidate(recoverySessionDetailProvider(session.id));
            },
          ),
          const SizedBox(height: 12),

          // Option 3: Unsafe / Distressed (SAFETY OVERRIDE TRIGGER)
          _buildReadinessOption(
            icon: Icons.shield_outlined,
            color: const Color(0xFFEF4444),
            title: 'Saya Merasa Tidak Aman / Tertekan',
            subtitle:
                'Hentikan diskusi ini dan dapatkan arahan ke tenaga profesional.',
            onTap: () async {
              await ref
                  .read(recoveryControllerProvider.notifier)
                  .submitReadiness(
                    sessionId: session.id,
                    level: ReadinessLevel.unsafe,
                  );
              ref.invalidate(recoverySessionDetailProvider(session.id));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReadinessOption({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SAFETY OVERRIDE STEP
  Widget _buildSafetyOverrideStep(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_rounded, color: Color(0xFFDC2626), size: 28),
              SizedBox(width: 10),
              Text(
                'Dukungan Profesional Diperlukan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF991B1B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Demi keamanan dan kesejahteraan emosional Anda, Favera menghentikan alur mediasi mandiri ini. Anda berhak mendapatkan ruang yang aman dan pendampingan profesional.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF7F1D1D),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () {
                context.push(AppRoutePaths.professionals);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
                minimumSize: Size.zero,
              ),
              child: const Text(
                'Lihat Direktori Konselor & Psikolog',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 2 & 3: Private Reflection & Statement Publish
  Widget _buildReflectionStep(BuildContext context, RecoverySession session) {
    return Container(
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
            'Langkah 2: Refleksi Privat & Draf Pernyataan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),

          // Privacy Badge
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline_rounded,
                    color: Color(0xFF3B82F6), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Refleksi ini bersifat privat dan hanya tersimpan di perangkat Anda. Tidak akan otomatis dikirimkan ke pasangan.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1E40AF),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Catatan Refleksi Pribadi',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _reflectionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Tuliskan pemikiran pribadi Anda di sini...',
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Pernyataan Yang Akan Dibagikan Ke Pasangan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _statementController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Tuliskan pesan netral & konstruktif untuk pasangan...',
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                final statement = _statementController.text.trim();
                final reflection = _reflectionController.text.trim();

                await ref
                    .read(recoveryControllerProvider.notifier)
                    .saveReflection(
                      sessionId: session.id,
                      reflection: reflection,
                    );

                await ref
                    .read(recoveryControllerProvider.notifier)
                    .publishStatement(
                      sessionId: session.id,
                      statement: statement,
                    );
                ref.invalidate(recoverySessionDetailProvider(session.id));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
                minimumSize: Size.zero,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Publikasikan ke Pasangan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.send_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 4: Waiting & Demo Partner Response Trigger
  Widget _buildWaitingStep(BuildContext context, RecoverySession session) {
    return Container(
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
            'Langkah 3: Menunggu Tanggapan Pasangan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.hourglass_top_rounded,
                    color: Color(0xFFD97706), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pernyataan Anda telah diterbitkan. Favera sedang memberikan waktu bagi pasangan untuk membaca dan merespons.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF92400E),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Published Statement Box
          const Text(
            'Pernyataan Anda:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            session.publishedStatement ?? '-',
            style: const TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 24),

          // DEMO TRIGGER BUTTON
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                await ref
                    .read(recoveryControllerProvider.notifier)
                    .simulatePartnerResponse(session.id);
                ref.invalidate(recoverySessionDetailProvider(session.id));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
                minimumSize: Size.zero,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Simulasikan Respon Pasangan (Demo)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 5: Alignment & Commitment Creation Form
  Widget _buildAlignmentStep(BuildContext context, RecoverySession session) {
    return Container(
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
            'Langkah 4: Penyelarasan & Komitmen Bersama',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 14),

          // Partner Response Box
          const Text(
            'Tanggapan Pasangan:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              session.partnerResponseText ?? '-',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF111827),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Alignment Summary Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F7F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF10B981), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan Kesepakatan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF065F46),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        session.alignmentSummary ?? '-',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF047857),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Buat Komitmen Bersama Baru',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: _commitmentTitleController,
            decoration: InputDecoration(
              labelText: 'Judul Komitmen',
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _commitmentDescController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Rincian Kesepakatan & Target',
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                await ref
                    .read(recoveryControllerProvider.notifier)
                    .createCommitment(
                      recoverySessionId: session.id,
                      title: _commitmentTitleController.text.trim(),
                      description: _commitmentDescController.text.trim(),
                      targetDate: DateTime.now().add(const Duration(days: 30)),
                    );
                ref.invalidate(recoverySessionDetailProvider(session.id));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
                minimumSize: Size.zero,
              ),
              child: const Text(
                'Sepakati & Aktifkan Komitmen',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 6: Active Commitment Progress
  Widget _buildCommitmentActiveStep(
      BuildContext context, RecoverySession session) {
    final commitmentsAsync = ref.watch(activeCommitmentsProvider);

    return Container(
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
          const Row(
            children: [
              Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 24),
              SizedBox(width: 10),
              Text(
                'Komitmen Berhasil Diaktifkan!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          commitmentsAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (err, st) => Text('Error: $err'),
            data: (list) {
              final cmt = list.firstWhere(
                (c) => c.recoverySessionId == session.id,
                orElse: () => list.isNotEmpty
                    ? list.first
                    : Commitment(
                        id: 'cmt-demo',
                        recoverySessionId: session.id,
                        title: _commitmentTitleController.text,
                        description: _commitmentDescController.text,
                        targetDate:
                            DateTime.now().add(const Duration(days: 30)),
                        status: CommitmentStatus.active,
                        createdBy: 'usr-joselin-001',
                        approvedByPartner: true,
                        progressPercentage: 60,
                        createdAt: DateTime.now(),
                      ),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cmt.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cmt.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kemajuan Komitmen',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        '${cmt.progressPercentage}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: cmt.progressPercentage / 100.0,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFF3F4F6),
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF10B981),
                      ),
                    ),
                  ),
                  if (!cmt.approvedByPartner || cmt.status == CommitmentStatus.pendingPartnerApproval) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                        label: const Text('Setujui Komitmen Pasangan'),
                        onPressed: () {
                          ref
                              .read(recoveryControllerProvider.notifier)
                              .approveCommitment(
                                commitmentId: cmt.id,
                                action: 'approve',
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ref
                                .read(recoveryControllerProvider.notifier)
                                .updateCommitmentProgress(
                                  commitmentId: cmt.id,
                                  progress: (cmt.progressPercentage + 20)
                                      .clamp(0, 100),
                                );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE0E7FF),
                            foregroundColor: const Color(0xFF4F46E5),
                            shape: const StadiumBorder(),
                            elevation: 0,
                            minimumSize: Size.zero,
                          ),
                          child: const Text('+20% Progress'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ref
                                .read(recoveryControllerProvider.notifier)
                                .updateCommitmentProgress(
                                  commitmentId: cmt.id,
                                  progress: 100,
                                );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            elevation: 0,
                            minimumSize: Size.zero,
                          ),
                          child: const Text('Selesaikan'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
