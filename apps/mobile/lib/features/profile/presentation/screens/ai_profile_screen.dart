import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:litera_ai_mobile/app/router/route_names.dart';
import 'package:litera_ai_mobile/features/auth/application/auth_controller.dart';
import 'package:litera_ai_mobile/features/auth/application/auth_state.dart';
import 'package:litera_ai_mobile/features/auth/domain/user_role.dart';
import 'package:litera_ai_mobile/shared/widgets/app_screen.dart';

class AiProfileScreen extends ConsumerStatefulWidget {
  const AiProfileScreen({super.key});

  @override
  ConsumerState<AiProfileScreen> createState() => _AiProfileScreenState();
}

class _AiProfileScreenState extends ConsumerState<AiProfileScreen> {
  // Common visual states
  String _activeChartPeriod = '30 Hari';
  String _language = 'ID'; // ID or EN
  bool _isDark = false;
  bool _biometricEnabled = true;
  String? _localPhotoPath;

  // Chatbot tutor state
  bool _showChatbot = false;
  final _chatController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'sender': 'ai',
      'text': 'Halo! Saya LITERA-AI Tutor. Ada yang bisa saya bantu dengan progres belajarmu hari ini?'
    }
  ];

  // Target checkboxes state (Siswa)
  final List<Map<String, dynamic>> _targets = [
    {'title': 'Selesaikan 4 materi minggu ini', 'completed': false, 'deadline': 'Dalam 3 hari'},
    {'title': 'Naikkan kemampuan numerasi ke 90%', 'completed': true, 'deadline': 'Selesai'},
    {'title': 'Latihan soal HOTS selama 20 menit', 'completed': false, 'deadline': 'Hari ini'},
  ];

  // Student radar scores
  final List<double> _radarScores = const [85, 78, 88, 92, 80, 85, 78, 90, 84];
  final List<String> _radarLabels = const [
    'Literasi', 'Numerasi', 'Komunikasi', 'Kolaborasi', 'STEM', 'Prob Solving', 'Kreativitas', 'Logika', 'Crit Thinking'
  ];

  // Learning history line chart (Siswa & Parent)
  final Map<String, List<double>> _chartData = {
    '7 Hari': [72, 75, 74, 78, 80, 82, 85],
    '30 Hari': [60, 62, 65, 64, 70, 72, 75, 74, 78, 80, 82, 85],
    '3 Bulan': [52, 55, 60, 58, 65, 70, 68, 72, 78, 75, 82, 85],
  };

  final Map<String, List<String>> _chartDays = {
    '7 Hari': ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
    '30 Hari': ['H-30', 'H-27', 'H-24', 'H-21', 'H-18', 'H-15', 'H-12', 'H-9', 'H-6', 'H-4', 'H-2', 'Hari Ini'],
    '3 Bulan': ['M-12', 'M-11', 'M-10', 'M-9', 'M-8', 'M-7', 'M-6', 'M-5', 'M-4', 'M-3', 'M-2', 'Minggu Ini'],
  };

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  // Pick profile picture
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
      if (pickedFile != null) {
        setState(() {
          _localPhotoPath = pickedFile.path;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil diperbarui!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui foto profil.')),
      );
    }
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Export report mock (Guru & Parent)
  void _handleExportReport(String format) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Laporan AI berhasil diekspor sebagai $format!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        });
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text('Membuat Laporan $format AI...'),
            ],
          ),
        );
      },
    );
  }

  // Send message to chatbot tutor
  void _sendMessage() {
    final query = _chatController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': query});
      _chatController.clear();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      String reply = 'Saya telah menganalisis materi tersebut. Silakan selesaikan Bab 4 sub-kategori Aljabar.';
      if (query.toLowerCase().contains('gaya belajar')) {
        reply = 'Gaya belajar dominanmu adalah Visual (55%). Saya sarankan belajar menggunakan modul infografis kami.';
      } else if (query.toLowerCase().contains('nilai') || query.toLowerCase().contains('semester')) {
        reply = 'Berdasarkan model DKT, prediksi nilai rata-rata semester ini adalah 88.5 dengan risiko learning loss rendah.';
      }
      setState(() {
        _messages.add({'sender': 'ai', 'text': reply});
      });
    });
  }

  // Complete profile redirect (leads to completing profile screen)
  void _editProfileDetails() {
    context.push(RouteNames.completeProfile);
  }

  // Logout process
  Future<void> _logout() async {
    await ref.read(authControllerProvider.notifier).logout();
    if (mounted) {
      context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final email = authState.email ?? 'siswa@litera.ai';
    final role = authState.role ?? UserRole.student;

    String displayRole = 'siswa';
    if (role == UserRole.teacher || email.contains('guru')) {
      displayRole = 'guru';
    } else if (email.contains('orangtua') || email.contains('parent')) {
      displayRole = 'orang_tua';
    } else {
      displayRole = 'siswa';
    }

    Color themeColor;
    if (displayRole == 'guru') {
      themeColor = const Color(0xFF1E3A8A); // Navy
    } else if (displayRole == 'orang_tua') {
      themeColor = const Color(0xFF16A34A); // Green
    } else {
      themeColor = const Color(0xFF2563EB); // Blue
    }

    return Scaffold(
      backgroundColor: _isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          displayRole == 'siswa' 
              ? (_language == 'ID' ? 'Profil AI Siswa' : 'AI Student Profile') 
              : (displayRole == 'guru' ? (_language == 'ID' ? 'Profil AI Guru' : 'AI Teacher Profile') : (_language == 'ID' ? 'Profil AI Orang Tua' : 'AI Parent Profile')),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Dark Mode switch
          IconButton(
            icon: Icon(_isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () => setState(() => _isDark = !_isDark),
          ),
          // Language Switch
          TextButton(
            onPressed: () => setState(() => _language = _language == 'ID' ? 'EN' : 'ID'),
            child: Text(_language, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              children: [
                // 1. HERO SECTION
                _buildHeroSection(authState, displayRole, themeColor),
                const SizedBox(height: 20),

                // 2. ROLE-SPECIFIC DASHBOARD
                if (displayRole == 'guru')
                  _buildGuruDashboard(authState, themeColor)
                else if (displayRole == 'orang_tua')
                  _buildOrangTuaDashboard(authState, themeColor)
                else
                  _buildSiswaDashboard(authState, themeColor),

                const SizedBox(height: 24),

                // 3. COMMON ACCOUNT SETTINGS MENU
                _buildSettingsMenu(authState, themeColor),
                const SizedBox(height: 100), // padding for chatbot float
              ],
            ),
          ),

          // 4. FLOATING CHATBOT TUTOR OVERLAY (Siswa & Orang Tua only)
          if (displayRole != 'guru') ...[
            _buildChatbotOverlay(themeColor),
            _buildChatbotFloatingButton(themeColor),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // HERO SECTION BUILDER
  // ==========================================
  Widget _buildHeroSection(AuthState authState, String role, Color themeColor) {
    final defaultAvatar = role == 'orang_tua' ? Icons.family_restroom : (role == 'guru' ? Icons.school : Icons.person);
    final fullName = authState.fullName ?? (role == 'guru' ? 'Budi Santoso, M.Pd' : 'Lutfi Ramadhan');
    final subtitle = role == 'guru' 
        ? 'NIP: 198203192008011002 | SMA Intelligent School'
        : (role == 'orang_tua' ? 'Orang Tua dari Lutfi Ramadhan | Kelas 8' : 'NISN: 8129031 | SD Intelligent School');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: _isDark 
                ? [themeColor.withOpacity(0.2), const Color(0xFF1E293B)] 
                : [themeColor.withOpacity(0.08), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Profile Avatar with Camera trigger
                InkWell(
                  onTap: _showImagePickerDialog,
                  borderRadius: BorderRadius.circular(40),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: themeColor.withOpacity(0.15),
                        backgroundImage: _localPhotoPath != null ? FileImage(File(_localPhotoPath!)) : null,
                        child: _localPhotoPath == null ? Icon(defaultAvatar, size: 36, color: themeColor) : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: themeColor, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 6),
                      // AI Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          role == 'guru' ? 'AI Analytical Certified' : (role == 'orang_tua' ? 'AI Family Connected' : 'Level 12 • Advanced Learner'),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: themeColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Gamification stats for Student
            if (role == 'siswa') ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('XP', '18,450', Colors.orange),
                  _buildStatItem('Coin', '340', Colors.amber),
                  _buildStatItem('Rank', '#5', Colors.purple),
                  _buildStatItem('Streak', '72 Hari', Colors.red),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // ==========================================
  // 1. SISWA AI DASHBOARD
  // ==========================================
  Widget _buildSiswaDashboard(AuthState authState, Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // AI Learning Score
        Text(
          _language == 'ID' ? 'Analisis Kemampuan AI' : 'AI Capability Analysis',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Radar chart
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: RadarChartPainter(
                      scores: _radarScores,
                      labels: _radarLabels,
                      isDark: _isDark,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Kelebihan utama Anda ada di logika & kolaborasi. Fokus pada latihan penalaran teks (literasi).',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Study Period switcher & Line chart
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _language == 'ID' ? 'Perkembangan Akademik' : 'Academic Progress Trend',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _activeChartPeriod,
              items: ['7 Hari', '30 Hari', '3 Bulan'].map((String p) {
                return DropdownMenuItem<String>(value: p, child: Text(p));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _activeChartPeriod = val);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: CustomPaint(
                painter: LineChartPainter(
                  _chartData[_activeChartPeriod]!,
                  _chartDays[_activeChartPeriod]!,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Gaya Belajar Section
        Text(
          _language == 'ID' ? 'Gaya Belajar Dominan' : 'Dominant Learning Style',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProgressStyle('Visual (Spasial)', 0.55, Colors.blue),
                const SizedBox(height: 12),
                _buildProgressStyle('Auditory (Suara)', 0.25, Colors.purple),
                const SizedBox(height: 12),
                _buildProgressStyle('Reading/Writing', 0.15, Colors.orange),
                const SizedBox(height: 12),
                _buildProgressStyle('Kinesthetic (Gerak)', 0.05, Colors.teal),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Target / Daily mission
        Text(
          _language == 'ID' ? 'Misi Harian & Target' : 'Daily Mission & Targets',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: List.generate(_targets.length, (idx) {
                final target = _targets[idx];
                return CheckboxListTile(
                  title: Text(target['title'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: Text(target['deadline'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  value: target['completed'],
                  activeColor: themeColor,
                  onChanged: (val) {
                    setState(() {
                      _targets[idx]['completed'] = val;
                    });
                    HapticFeedback.lightImpact();
                  },
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressStyle(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
        Expanded(
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: color.withOpacity(0.12),
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 12),
        Text('${(value * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ==========================================
  // 2. GURU AI DASHBOARD
  // ==========================================
  Widget _buildGuruDashboard(AuthState authState, Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _language == 'ID' ? 'Analisis Pembelajaran Kelas' : 'Classroom Learning Analytics',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Analytics statistics grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildGridStatCard('Siswa Aktif', '32 Siswa', Icons.people, Colors.blue),
            _buildGridStatCard('Rata-rata Nilai', '84.5 / 100', Icons.assessment_outlined, Colors.purple),
            _buildGridStatCard('Submission Rate', '92.4%', Icons.assignment_turned_in_outlined, Colors.green),
            _buildGridStatCard('Kelas Berjalan', '4 Kelas', Icons.grid_view, Colors.orange),
          ],
        ),
        const SizedBox(height: 20),

        // Student line chart trend
        Text(
          _language == 'ID' ? 'Tren Hasil Belajar Kelas' : 'Class Performance Trend',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: CustomPaint(
                painter: LineChartPainter(
                  const [70, 72, 75, 78, 80, 82, 84],
                  const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // AI Insight: Student Needs Help & Topics
        Text(
          _language == 'ID' ? 'Rekomendasi & Insight AI' : 'AI Recommendations & Insights',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInsightItem('Siswa Butuh Perhatian', 'Farhan (Nilai turun 12%), Siti (Kurang konsisten)', Icons.warning_amber_rounded, Colors.red),
                const SizedBox(height: 12),
                _buildInsightItem('Materi Tersulit', 'Aljabar Pecahan (Tingkat kelulusan 64%)', Icons.quiz_outlined, Colors.orange),
                const SizedBox(height: 12),
                _buildInsightItem('Siswa Terbaik Minggu Ini', 'Budi Hartono (98 XP), Dewi Lestari (96 XP)', Icons.emoji_events_outlined, Colors.amber),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Class Management actions
        Text(
          _language == 'ID' ? 'Manajemen & Laporan' : 'Management & Reports',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleExportReport('PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: themeColor,
                  side: BorderSide(color: themeColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Export PDF'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleExportReport('Excel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: themeColor,
                  side: BorderSide(color: themeColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.table_chart),
                label: const Text('Export Excel'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String title, String desc, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(desc, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 3. ORANG TUA AI DASHBOARD
  // ==========================================
  Widget _buildOrangTuaDashboard(AuthState authState, Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _language == 'ID' ? 'Analisis Belajar Anak' : 'Child Learning Performance',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Child progress metrics
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildChildProgressItem('Literasi (Bahasa)', 85, Colors.blue),
                const SizedBox(height: 12),
                _buildChildProgressItem('Numerasi (Matematika)', 78, Colors.orange),
                const SizedBox(height: 12),
                _buildChildProgressItem('Kedisiplinan Sesi', 94, Colors.green),
                const SizedBox(height: 12),
                _buildChildProgressItem('Jam Belajar', 88, Colors.purple),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Study Period switcher & Line chart for Parent
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _language == 'ID' ? 'Grafik Progres Bulanan Anak' : 'Monthly Progress Chart',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _activeChartPeriod,
              items: ['7 Hari', '30 Hari', '3 Bulan'].map((String p) {
                return DropdownMenuItem<String>(value: p, child: Text(p));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _activeChartPeriod = val);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: CustomPaint(
                painter: LineChartPainter(
                  _chartData[_activeChartPeriod]!,
                  _chartDays[_activeChartPeriod]!,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Parent specific AI insights
        Text(
          _language == 'ID' ? 'Analisis Kelebihan & Kesulitan Anak' : 'Child Strengths & Difficulties',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInsightItem('Anak Lebih Mudah Memahami', 'Pembelajaran Visual yang dilengkapi dengan modul gambar/infografis.', Icons.thumb_up_alt_outlined, Colors.green),
                const SizedBox(height: 12),
                _buildInsightItem('Anak Mengalami Kesulitan', 'Analisis teks deskriptif panjang pada modul Literasi.', Icons.info_outline, Colors.orange),
                const SizedBox(height: 12),
                _buildInsightItem('Rekomendasi Aktivitas', 'Temani anak membaca buku cerita selama 15 menit sebelum tidur.', Icons.auto_awesome, Colors.blue),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChildProgressItem(String label, int score, Color color) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: score / 100,
                backgroundColor: color.withOpacity(0.12),
                color: color,
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Text('$score%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // ==========================================
  // COMMON ACCOUNT SETTINGS MENU
  // ==========================================
  Widget _buildSettingsMenu(AuthState authState, Color themeColor) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.person_outline, color: themeColor),
              title: Text(_language == 'ID' ? 'Ubah Informasi Profil' : 'Edit Profile Information'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: _editProfileDetails,
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.bookmark_outline, color: themeColor),
              title: Text(_language == 'ID' ? 'Favorit / Bookmark' : 'Bookmarks & Favorites'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () => context.push(RouteNames.bookmarks),
            ),
            const Divider(height: 1),
            SwitchListTile(
              secondary: Icon(Icons.fingerprint, color: themeColor),
              title: Text(_language == 'ID' ? 'Autentikasi Biometrik' : 'Biometric Authentication'),
              value: _biometricEnabled,
              activeColor: themeColor,
              onChanged: (val) {
                setState(() => _biometricEnabled = val);
                HapticFeedback.lightImpact();
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.lock_outline, color: themeColor),
              title: Text(_language == 'ID' ? 'Keamanan Akun' : 'Account Security'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Beralih ke setelan keamanan akun...')),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.privacy_tip_outlined, color: themeColor),
              title: Text(_language == 'ID' ? 'Privasi & Data' : 'Privacy & Data Protection'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privasi Data LITERA-AI mematuhi standar enkripsi cloud.')),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                _language == 'ID' ? 'Keluar Akun' : 'Log Out Account',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // FLOATING CHATBOT TUTOR OVERLAY
  // ==========================================
  Widget _buildChatbotFloatingButton(Color themeColor) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: FloatingActionButton(
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        onPressed: () {
          setState(() {
            _showChatbot = !_showChatbot;
          });
          HapticFeedback.mediumImpact();
        },
        child: Icon(_showChatbot ? Icons.close : Icons.psychology),
      ),
    );
  }

  Widget _buildChatbotOverlay(Color themeColor) {
    if (!_showChatbot) return const SizedBox();

    return Positioned(
      right: 16,
      bottom: 80,
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 300,
          height: 380,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Chatbot
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: themeColor.withOpacity(0.12),
                    child: Icon(Icons.psychology, color: themeColor),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('LITERA-AI Tutor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Asisten Belajar Aktif', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(),
              // Chat messages
              Expanded(
                child: ListView.builder(
                  itemCount: _messages.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, idx) {
                    final msg = _messages[idx];
                    final isAi = msg['sender'] == 'ai';
                    return Align(
                      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isAi ? Colors.grey.shade100 : themeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg['text']!,
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Message inputs
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Tanyakan sesuatu...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: themeColor),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// RADAR CHART PAINTER FOR SKILLS
// ----------------------------------------------------
class RadarChartPainter extends CustomPainter {
  final List<double> scores;
  final List<String> labels;
  final bool isDark;

  RadarChartPainter({required this.scores, required this.labels, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2.8;

    final linePaint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final scorePaint = Paint()
      ..color = const Color(0xFF2563EB).withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final scoreBorderPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    const angleStep = 2 * pi / 9;

    // Draw concentric radar lines
    for (int i = 1; i <= 4; i++) {
      final r = radius * (i / 4);
      final path = Path();
      for (int j = 0; j < 9; j++) {
        final angle = j * angleStep - pi / 2;
        final x = center.dx + r * cos(angle);
        final y = center.dy + r * sin(angle);
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, linePaint);
    }

    // Draw axis lines and text labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int j = 0; j < 9; j++) {
      final angle = j * angleStep - pi / 2;
      final xLine = center.dx + radius * cos(angle);
      final yLine = center.dy + radius * sin(angle);
      canvas.drawLine(center, Offset(xLine, yLine), linePaint);

      // Label positions
      final xLabel = center.dx + (radius + 15) * cos(angle);
      final yLabel = center.dy + (radius + 10) * sin(angle);

      final textSpan = TextSpan(
        text: labels[j],
        style: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[800],
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.text = textSpan;
      textPainter.layout();
      textPainter.paint(canvas, Offset(xLabel - textPainter.width / 2, yLabel - textPainter.height / 2));
    }

    // Draw score polygon
    final scorePath = Path();
    for (int j = 0; j < 9; j++) {
      final angle = j * angleStep - pi / 2;
      final r = radius * (scores[j] / 100);
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (j == 0) {
        scorePath.moveTo(x, y);
      } else {
        scorePath.lineTo(x, y);
      }
    }
    scorePath.close();
    canvas.drawPath(scorePath, scorePaint);
    canvas.drawPath(scorePath, scoreBorderPaint);

    // Draw dots
    final dotPaint = Paint()
      ..color = const Color(0xFF06B6D4)
      ..style = PaintingStyle.fill;

    for (int j = 0; j < 9; j++) {
      final angle = j * angleStep - pi / 2;
      final r = radius * (scores[j] / 100);
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RadarChartPainter oldDelegate) {
    return oldDelegate.scores != scores;
  }
}

// ----------------------------------------------------
// LINE CHART PAINTER FOR PROGRESS TREND
// ----------------------------------------------------
class LineChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> days;

  LineChartPainter(this.values, this.days);

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final paintDot = Paint()
      ..color = const Color(0xFF06B6D4)
      ..style = PaintingStyle.fill;

    final paintGrid = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1.0;

    final stepX = size.width / (values.length - 1);
    final heightRatio = size.height / 100;

    // Grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height - (i * 20 * heightRatio);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    final path = Path();
    final fillPath = Path();

    fillPath.moveTo(0, size.height);

    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - (values[i] * heightRatio);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Fill gradient
    final gradient = LinearGradient(
      colors: [const Color(0xFF2563EB).withOpacity(0.20), const Color(0xFF2563EB).withOpacity(0.01)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paintFill = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);

    // Render dot labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - (values[i] * heightRatio);
      canvas.drawCircle(Offset(x, y), 4.5, paintDot);

      if (i % 2 == 0) {
        final textSpan = TextSpan(
          text: days[i],
          style: TextStyle(color: Colors.grey.shade500, fontSize: 8.5, fontWeight: FontWeight.bold),
        );
        textPainter.text = textSpan;
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height + 4));
      }
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
