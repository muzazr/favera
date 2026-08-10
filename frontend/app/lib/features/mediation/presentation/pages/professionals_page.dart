import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_async_view.dart';
import '../../../../core/widgets/app_gradient_background.dart';
import '../../../../shared/models/professional_model.dart';
import '../../application/professional_controller.dart';

class ProfessionalsPage extends ConsumerStatefulWidget {
  final String? initialCategory;

  const ProfessionalsPage({
    super.key,
    this.initialCategory,
  });

  @override
  ConsumerState<ProfessionalsPage> createState() => _ProfessionalsPageState();
}

class _ProfessionalsPageState extends ConsumerState<ProfessionalsPage> {
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      _selectedCategory = widget.initialCategory!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final queryCategory = _selectedCategory == 'all' ? null : _selectedCategory;
    final professionalsAsync =
        ref.watch(professionalListProvider(queryCategory));

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
                context.go(AppRoutePaths.mediation);
              }
            },
          ),
          centerTitle: true,
          title: const Text(
            'Konseling Digital',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF111827),
                size: 24,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            // Filter Chips Horizontal Row matching Screenshot 1
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  _buildFilterChip('Semua Ahli', 'all'),
                  const SizedBox(width: 10),
                  _buildFilterChip('Psikolog Pernikahan', 'psikolog'),
                  const SizedBox(width: 10),
                  _buildFilterChip('Konselor Finansial', 'konselor_finansial'),
                  const SizedBox(width: 10),
                  _buildFilterChip('Mediator', 'mediator'),
                ],
              ),
            ),

            // Main List View
            Expanded(
              child: professionalsAsync.when(
                loading: () =>
                    const AppLoadingView(message: 'Memuat daftar ahli...'),
                error: (err, st) => AppErrorView(
                  message: err.toString(),
                  onRetry: () => ref.invalidate(
                    professionalListProvider(queryCategory),
                  ),
                ),
                data: (professionals) {
                  if (professionals.isEmpty) {
                    return const AppEmptyView(
                      title: 'Tidak Ada Ahli',
                      description:
                          'Belum ada konselor yang tersedia untuk kategori ini.',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    itemCount: professionals.length,
                    itemBuilder: (ctx, idx) {
                      final item = professionals[idx];
                      return _buildProfessionalCard(context, item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedCategory == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : const Color(0xFF374151),
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF10B981),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
      ),
      shape: const StadiumBorder(),
      elevation: 0,
      showCheckmark: false,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedCategory = value);
        }
      },
    );
  }

  Widget _buildProfessionalCard(BuildContext context, Professional item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0E7FF),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  item.name.isNotEmpty ? item.name[0] : 'P',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Info Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.specialization,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF59E0B),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.rating}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• ${item.experienceYears} Tahun Pengalaman',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Practice Schedule Box matching Screenshot 1
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 15,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Jadwal Praktek: ${item.schedule}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF374151),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Full-width Detail Button matching Screenshot 1
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                _showProfessionalDetailModal(context, item);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
                minimumSize: Size.zero,
              ),
              child: const Text(
                'Detail',
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

  void _showProfessionalDetailModal(BuildContext context, Professional item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).padding.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Informasi Layanan Ahli',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Profile Overview
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0E7FF),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      item.name.isNotEmpty ? item.name[0] : 'P',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.specialization,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Intermediary Notice Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: Color(0xFF3B82F6), size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Favera menyediakan informasi perantara. Hubungi konselor secara langsung melalui saluran resmi di bawah ini.',
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

              // Bio Text
              if (item.bio != null) ...[
                const Text(
                  'Profil & Keahlian',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.bio!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Practice Schedule
              const Text(
                'Jadwal Konsultasi',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.schedule,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 24),

              // External Contact Buttons (WhatsApp / Instagram / Website)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final url = Uri.parse(
                      item.whatsappUrl ?? 'https://wa.me/6281234567890',
                    );
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.chat_bubble_rounded, size: 20),
                  label: const Text(
                    'Hubungi via WhatsApp',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    elevation: 0,
                    minimumSize: Size.zero,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
