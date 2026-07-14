import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:litera_ai_mobile/app/router/route_names.dart';
import 'package:litera_ai_mobile/core/connectivity/network_mode.dart';
import 'package:litera_ai_mobile/core/sync/outbox_queue.dart';
import 'package:litera_ai_mobile/features/auth/application/auth_controller.dart';
import 'package:litera_ai_mobile/features/auth/application/auth_state.dart';
import 'package:litera_ai_mobile/shared/widgets/app_navigation.dart';
import 'package:litera_ai_mobile/shared/widgets/app_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Settings States
  String _selectedLanguage = 'Bahasa Indonesia';
  bool _darkMode = false;
  String _selectedTheme = 'Biru Indigo';
  String _selectedFontSize = 'Sedang';

  bool _pushNotification = true;
  bool _emailNotification = true;
  bool _soundEnabled = true;

  bool _pinEnabled = false;
  bool _fingerprintEnabled = false;
  bool _twoFactorEnabled = false;

  String _cacheSize = '24.5 MB';
  int _downloadedModulesCount = 5;
  String _mediaStorageSize = '12.8 MB';
  bool _cameraPermission = true;
  bool _photoPermission = true;
  bool _notificationPermission = true;

  void _clearCache() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hapus Cache', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin menghapus cache aplikasi? Aksi ini akan mengunduh ulang gambar & modul dari server.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _cacheSize = '0.0 MB';
              });
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache aplikasi berhasil dibersihkan! 🧹'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    final oldController = TextEditingController();
    final newController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Ganti Password', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password Lama', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password Baru', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password berhasil diubah!'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showReportBug() {
    final bugController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Laporkan Bug', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: bugController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Jelaskan masalah atau bug yang Anda temukan...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Laporan bug berhasil dikirim! Terima kasih atas feedback Anda.'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  void _showDeveloperDetails() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Detail Pengembang', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Developed by:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
              const Text('Team UNITECH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.indigo)),
              const Text('Faculty of Teacher Training and Education (FKIP)', style: TextStyle(fontSize: 12)),
              const Text('Universitas Riau', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const Divider(height: 16),
              const Text('Project Team:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 4),
              const Text('• Muhammad Lutfi Muzaki (Project Leader)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const Text('• Suci Aulia Sya\'ban', style: TextStyle(fontSize: 12)),
              const Text('• M. Rafli Maulana', style: TextStyle(fontSize: 12)),
              const Text('• Murni Syakira', style: TextStyle(fontSize: 12)),
              const Divider(height: 16),
              const Text('Academic Supervisor:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
              const Text('Zulhafizh, S.Pd., M.Pd.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const Divider(height: 16),
              const Text('© 2026 LITERA-AI. All Rights Reserved.', style: TextStyle(fontSize: 10, color: Colors.grey)),
              const Text('Version v2.2.26', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigo)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  bool isBelowAndroid10() {
    if (!Platform.isAndroid) return false;
    try {
      final osVersion = Platform.operatingSystemVersion.toLowerCase();
      final match = RegExp(r'android\s+(\d+)').firstMatch(osVersion);
      if (match != null) {
        final versionNum = int.tryParse(match.group(1) ?? '');
        if (versionNum != null && versionNum < 10) {
          return true;
        }
      }
      final apiMatch = RegExp(r'api\s+(\d+)').firstMatch(osVersion);
      if (apiMatch != null) {
        final apiLevel = int.tryParse(apiMatch.group(1) ?? '');
        if (apiLevel != null && apiLevel < 29) {
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  Widget _buildProfileHeader(BuildContext context, AuthState auth) {
    final displayName = auth.fullName != null && auth.fullName!.isNotEmpty ? auth.fullName! : 'Muhammad';
    final email = auth.email != null && auth.email!.isNotEmpty ? auth.email! : 'siswa@litera-ai.id';
    final firstLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'M';
    final photoPath = auth.photoPath;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade800, Colors.purple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 42,
              backgroundColor: Colors.indigo.shade100,
              backgroundImage: photoPath != null ? FileImage(File(photoPath)) : null,
              child: photoPath == null
                  ? Text(
                      firstLetter,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            displayName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
          ),
          const SizedBox(height: 2),
          Text(
            email,
            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.85)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user, color: Colors.amber, size: 14),
                SizedBox(width: 6),
                Text(
                  'Akun LITERA-AI Aktif',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final isTeacher = auth.status == AuthStatus.teacherReady;
    final networkMode = ref.watch(networkModeControllerProvider);
    final pendingCount = ref.watch(outboxQueueProvider).length;

    return AppScreen(
      title: 'Pengaturan Lengkap',
      bottomNavigationBar: isTeacher
          ? const TeacherNavigationBar(selectedIndex: 3)
          : const StudentNavigationBar(selectedIndex: 3),
      children: [
        _buildProfileHeader(context, auth),
        const SizedBox(height: 20),

        // 1. KATEGORI: AKUN
        _buildSectionHeader('Akun & Profil'),
        _buildListTile(Icons.person_outline, 'Edit Profil', 'Ubah informasi pribadi, biodata, dan foto profil.', () {
          context.push(RouteNames.completeProfile);
        }),
        _buildListTile(Icons.lock_outline, 'Ganti Password', 'Perbarui password keamanan akun Anda.', _changePassword),
        _buildListTile(Icons.mark_email_read_outlined, 'Verifikasi Email', 'Cek status verifikasi email Anda.', () {
          context.push(RouteNames.verifyEmail);
        }),
        const Divider(),

        // 2. KATEGORI: APLIKASI
        _buildSectionHeader('Preferensi Aplikasi'),
        _buildDropdownTile(
          icon: Icons.language,
          title: 'Bahasa',
          value: _selectedLanguage,
          options: const ['Bahasa Indonesia', 'English'],
          onChanged: (val) => setState(() => _selectedLanguage = val!),
        ),
        _buildSwitchTile(Icons.dark_mode_outlined, 'Dark Mode', _darkMode, (val) => setState(() => _darkMode = val)),
        _buildDropdownTile(
          icon: Icons.palette_outlined,
          title: 'Tema Visual',
          value: _selectedTheme,
          options: const ['Biru Indigo', 'Hijau Emerald', 'Royal Navy'],
          onChanged: (val) => setState(() => _selectedTheme = val!),
        ),
        _buildDropdownTile(
          icon: Icons.format_size_outlined,
          title: 'Ukuran Font',
          value: _selectedFontSize,
          options: const ['Kecil', 'Sedang', 'Besar'],
          onChanged: (val) => setState(() => _selectedFontSize = val!),
        ),
        const Divider(),

        // 3. KATEGORI: NOTIFIKASI
        _buildSectionHeader('Pengaturan Notifikasi'),
        _buildSwitchTile(Icons.notifications_active_outlined, 'Push Notification', _pushNotification, (val) => setState(() => _pushNotification = val)),
        _buildSwitchTile(Icons.mail_outline, 'Email Notification', _emailNotification, (val) => setState(() => _emailNotification = val)),
        _buildSwitchTile(Icons.volume_up_outlined, 'Efek Suara', _soundEnabled, (val) => setState(() => _soundEnabled = val)),
        const Divider(),

        // 4. KATEGORI: KEAMANAN
        _buildSectionHeader('Keamanan Akun'),
        _buildSwitchTile(Icons.security, 'Two Factor Authentication (2FA)', _twoFactorEnabled, (val) => setState(() => _twoFactorEnabled = val)),
        _buildSwitchTile(Icons.pin_outlined, 'PIN Aplikasi', _pinEnabled, (val) => setState(() => _pinEnabled = val)),
        _buildSwitchTile(Icons.fingerprint, 'Biometrik (Fingerprint/Face ID)', _fingerprintEnabled, (val) => setState(() => _fingerprintEnabled = val)),
        const Divider(),

        // 5. KATEGORI: DATA & MEMORI
        _buildSectionHeader('Data & Penyimpanan'),
        ListTile(
          leading: const Icon(Icons.cleaning_services_outlined, color: Colors.indigo),
          title: const Text('Pembersihan Cache', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text('Ukuran penyimpanan sementara: $_cacheSize'),
          trailing: TextButton(onPressed: _clearCache, child: const Text('HAPUS')),
        ),
        ListTile(
          leading: const Icon(Icons.download_for_offline_outlined, color: Colors.indigo),
          title: const Text('Riwayat Unduhan Modul', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text('$_downloadedModulesCount modul tersimpan offline'),
          trailing: _downloadedModulesCount > 0
              ? TextButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        title: const Text('Hapus Unduhan', style: TextStyle(fontWeight: FontWeight.bold)),
                        content: const Text('Apakah Anda yakin ingin menghapus semua modul yang diunduh secara offline?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {
                                _downloadedModulesCount = 0;
                              });
                              HapticFeedback.mediumImpact();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua unduhan offline berhasil dihapus!')));
                            },
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('HAPUS'),
                )
              : null,
        ),
        ListTile(
          leading: const Icon(Icons.storage_outlined, color: Colors.indigo),
          title: const Text('Penyimpanan Media', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text('Penggunaan memori: $_mediaStorageSize'),
          trailing: TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  title: const Text('Kelola Penyimpanan', style: TextStyle(fontWeight: FontWeight.bold)),
                  content: const Text('Kosongkan file media pendukung pembelajaran untuk menghemat ruang penyimpanan perangkat Anda.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _mediaStorageSize = '0.0 MB';
                        });
                        HapticFeedback.mediumImpact();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File media dibersihkan!')));
                      },
                      child: const Text('Bersihkan'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('BERSIHKAN'),
          ),
        ),
        _buildSwitchTile(Icons.cloud_off_outlined, 'Mode Offline', !networkMode.isOnline, (enabled) {
          ref.read(networkModeControllerProvider.notifier).setOfflineEnabled(enabled);
          if (!enabled) {
            ref.read(outboxQueueProvider.notifier).syncNow();
          }
        }),
        _buildListTile(Icons.sync_outlined, 'Sinkronisasi Outbox', '$pendingCount aksi antrean offline.', () {
          if (networkMode.isOnline && pendingCount > 0) {
            ref.read(outboxQueueProvider.notifier).syncNow();
          }
        }),
        const Divider(),

        // 6. KATEGORI: PRIVASI
        _buildSectionHeader('Kebijakan & Privasi'),
        _buildListTile(Icons.privacy_tip_outlined, 'Kebijakan Privasi', 'Baca kebijakan data pengguna LITERA-AI.', () {
          _showTextDialog('Kebijakan Privasi', 'LITERA-AI berkomitmen untuk menjaga keamanan data pembelajaran Anda. Data evaluasi Anda hanya digunakan oleh sistem AI untuk mempersonalisasi materi belajar secara adaptif.');
        }),
        _buildListTile(Icons.description_outlined, 'Syarat & Ketentuan', 'Persyaratan layanan penggunaan aplikasi.', () {
          _showTextDialog('Syarat & Ketentuan', 'Dengan menggunakan LITERA-AI, Anda menyetujui analisis progres akademik adaptif guna mendapatkan rekomendasi belajar berstandar kurikulum.');
        }),
        _buildListTile(Icons.api_outlined, 'Perizinan Aplikasi', 'Kelola izin akses kamera, file, dan notifikasi.', () {
          showDialog(
            context: context,
            builder: (context) => StatefulBuilder(
              builder: (context, setDialogState) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                title: const Text('Izin Akses Aplikasi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      title: const Text('Akses Kamera', style: TextStyle(fontSize: 13)),
                      value: _cameraPermission,
                      activeColor: Colors.indigo,
                      onChanged: (val) {
                        setDialogState(() => _cameraPermission = val);
                        setState(() => _cameraPermission = val);
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Galeri Foto & Berkas', style: TextStyle(fontSize: 13)),
                      value: _photoPermission,
                      activeColor: Colors.indigo,
                      onChanged: (val) {
                        setDialogState(() => _photoPermission = val);
                        setState(() => _photoPermission = val);
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Notifikasi Push', style: TextStyle(fontSize: 13)),
                      value: _notificationPermission,
                      activeColor: Colors.indigo,
                      onChanged: (val) {
                        setDialogState(() => _notificationPermission = val);
                        setState(() => _notificationPermission = val);
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        }),
        const Divider(),

        // 7. KATEGORI: BANTUAN
        _buildSectionHeader('Bantuan & Hubungi Kami'),
        _buildListTile(Icons.help_center_outlined, 'Pusat Bantuan & FAQ', 'Hubungi kami via Chat Live, WhatsApp, Email, FAQ, & Feedback.', () {
          context.push(RouteNames.helpCenter);
        }),
        _buildListTile(Icons.bug_report_outlined, 'Laporkan Bug', 'Beri tahu kami masalah teknis di aplikasi.', _showReportBug),
        const Divider(),

        // 8. KATEGORI: TENTANG APLIKASI
        _buildSectionHeader('Tentang Aplikasi'),
        _buildTextOnlyTile('Versi Aplikasi', 'v2.2.26'),
        _buildTextOnlyTile(
          'Status Perangkat',
          isBelowAndroid10()
              ? 'Android < 10 (Kurang Optimal - Rekomendasi Android 10+)'
              : 'Android 10+ (Optimal & Lancar)',
        ),
        _buildListTile(Icons.info_outline, 'Detail Pengembang', 'Team UNITECH - Universitas Riau', _showDeveloperDetails),
        _buildTextOnlyTile('Changelog Rilis', 'Rilis stabil v2.2.26: Perombakan halaman detail modul, pusat riwayat multi-kategori, & profil AI adaptif.'),
        _buildTextOnlyTile('Lisensi Perangkat Lunak', 'Apache License v2.0'),
        const SizedBox(height: 24),

        // 9. LOGOUT BUTTON
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            label: const Text('Logout / Keluar Akun'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 6.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.indigo, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo, size: 20),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      onTap: onTap,
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo, size: 20),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      trailing: DropdownButton<String>(
        value: value,
        items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt, style: const TextStyle(fontSize: 12)))).toList(),
        onChanged: onChanged,
        underline: Container(),
      ),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      secondary: Icon(icon, color: Colors.indigo, size: 20),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.indigo,
    );
  }

  Widget _buildTextOnlyTile(String title, String trailingText) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      trailing: Text(trailingText, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
    );
  }

  void _showTextDialog(String title, String body) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
        content: SingleChildScrollView(child: Text(body, style: const TextStyle(fontSize: 13, height: 1.4))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }
}
