import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_gradient_background.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../family/application/family_controller.dart';
import '../../application/settings_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;
    final familyAsync = ref.watch(familyControllerProvider);
    final settings = ref.watch(settingsControllerProvider);
    final settingsNotifier = ref.read(settingsControllerProvider.notifier);

    final familySpace = familyAsync.value;
    final isPaired = familySpace != null && familySpace.isPaired;
    final String displayInviteCode;
    if (isPaired) {
      displayInviteCode = familySpace.inviteCode ?? 'TERHUBUNG';
    } else {
      displayInviteCode = ref.watch(myInviteCodeProvider).value ?? 'Memuat...';
    }

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF111827),
                size: 24,
              ),
              onPressed: () {},
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage(
                  user?.avatarUrl ?? AppAssets.profileWomen,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CARD 1: TOP PROFILE CARD matching Screenshots 1 & 2
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatars (Overlapping if paired, Single if not)
                    if (isPaired)
                      SizedBox(
                        width: 100,
                        height: 60,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    AssetImage(AppAssets.profileMen),
                              ),
                            ),
                            Positioned(
                              left: 40,
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    AssetImage(AppAssets.profileWomen),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      CircleAvatar(
                        radius: 36,
                        backgroundImage: AssetImage(
                          user?.avatarUrl ?? AppAssets.profileWomen,
                        ),
                      ),
                    const SizedBox(height: 12),

                    // Name
                    Text(
                      isPaired
                          ? '${user?.name ?? "Budi"} & Pasangan'
                          : user?.name ?? 'Budi',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // ID Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ID: $displayInviteCode',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Status Pill inside Profile Card
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isPaired
                            ? const Color(0xFFE6F7F0)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPaired
                                ? Icons.link_rounded
                                : Icons.link_off_rounded,
                            color: isPaired
                                ? const Color(0xFF10B981)
                                : const Color(0xFF6B7280),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isPaired
                                ? 'Akun Terhubung secara Enkripsi'
                                : 'Belum Terhubung Pasangan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isPaired
                                  ? const Color(0xFF047857)
                                  : const Color(0xFF4B5563),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // CARD 2: DEDICATED PARTNER CONNECTION BUTTON CARD (User's Explicit Directive: "Beda Card!")
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                child: isPaired
                    ? InkWell(
                        onTap: () {
                          context.push('/app/family/connection-detail');
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F7F0),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.favorite_rounded,
                                color: Color(0xFF10B981),
                                size: 22,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Cek Koneksi Pasangan',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF047857),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Lihat profil terhubung & kelola koneksi',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF059669),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF10B981),
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.push(AppRoutePaths.familyConnect);
                          },
                          icon: const Icon(
                            Icons.link_rounded,
                            color: Color(0xFF10B981),
                            size: 20,
                          ),
                          label: const Text(
                            'Koneksikan ke Pasangan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFE6F7F0),
                            side: const BorderSide(color: Color(0xFF10B981)),
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              // SECTION 1: PREFERENSI APLIKASI
              _buildSectionTitle('PREFERENSI APLIKASI'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      icon: Icons.notifications_active_outlined,
                      iconBgColor: const Color(0xFFFCE7F3),
                      iconColor: const Color(0xFFDB2777),
                      title: 'Pengingat Weekly Check-In',
                      value: settings.weeklyCheckInReminder,
                      onChanged: settingsNotifier.toggleWeeklyCheckInReminder,
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildSwitchTile(
                      icon: Icons.description_outlined,
                      iconBgColor: const Color(0xFFD1FAE5),
                      iconColor: const Color(0xFF059669),
                      title: 'Notifikasi E-Statement Baru',
                      value: settings.eStatementNotification,
                      onChanged: settingsNotifier.toggleEStatementNotification,
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildNavTile(
                      icon: Icons.dark_mode_outlined,
                      iconBgColor: const Color(0xFFF1F5F9),
                      iconColor: const Color(0xFF475569),
                      title: 'Tema Tampilan (Dark Mode)',
                      onTap: () {
                        settingsNotifier.toggleDarkMode(!settings.darkMode);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SECTION 2: KEAMANAN & PRIVASI
              _buildSectionTitle('KEAMANAN & PRIVASI'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _buildNavTile(
                      icon: Icons.lock_outline_rounded,
                      iconBgColor: const Color(0xFFE0E7FF),
                      iconColor: const Color(0xFF4F46E5),
                      title: 'Ubah PIN & Kata Sandi',
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildSwitchTile(
                      icon: Icons.face_rounded,
                      iconBgColor: const Color(0xFFE0E7FF),
                      iconColor: const Color(0xFF4F46E5),
                      title: 'Login Biometrik',
                      value: settings.biometricLogin,
                      onChanged: settingsNotifier.toggleBiometricLogin,
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildSwitchTile(
                      icon: Icons.visibility_off_outlined,
                      iconBgColor: const Color(0xFFE0E7FF),
                      iconColor: const Color(0xFF4F46E5),
                      title: 'Sembunyikan Saldo',
                      value: settings.hideBalance,
                      onChanged: settingsNotifier.toggleHideBalance,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SECTION 3: BANTUAN & KEBIJAKAN
              _buildSectionTitle('BANTUAN & KEBIJAKAN'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _buildNavTile(
                      icon: Icons.help_outline_rounded,
                      iconBgColor: const Color(0xFFE0F2FE),
                      iconColor: const Color(0xFF0284C7),
                      title: 'Pusat Bantuan & FAQ',
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildNavTile(
                      icon: Icons.security_rounded,
                      iconBgColor: const Color(0xFFE0F2FE),
                      iconColor: const Color(0xFF0284C7),
                      title: 'Kebijakan Privasi',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // BOTTOM ACTIONS: Log Out Button & App Version
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(authControllerProvider.notifier).logout();
                    context.go(AppRoutePaths.login);
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFF4B5563),
                    size: 20,
                  ),
                  label: const Text(
                    'Keluar (Log Out)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Center(
                child: Text(
                  'Ruang Aman App v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6B7280),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF10B981),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9CA3AF),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
