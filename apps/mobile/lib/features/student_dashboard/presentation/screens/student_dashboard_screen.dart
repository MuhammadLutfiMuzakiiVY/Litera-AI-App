import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:litera_ai_mobile/features/auth/application/auth_controller.dart';
import 'package:litera_ai_mobile/app/router/route_names.dart';
import 'package:litera_ai_mobile/features/learning/application/learning_providers.dart';
import 'package:litera_ai_mobile/shared/widgets/app_navigation.dart';
import 'package:litera_ai_mobile/shared/widgets/app_screen.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(studentProgressProvider);

    // Local target states for interactive checkboxes using StatefulBuilder
    bool target1 = false;
    bool target2 = false;
    bool target3 = false;
    bool target4 = false;

    return AppScreen(
      title: 'LITERA-AI Dashboard',
      actions: [
        IconButton(
          tooltip: 'Pencarian',
          icon: const Icon(Icons.search),
          onPressed: () => context.push(RouteNames.search),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              tooltip: 'Notifikasi',
              onPressed: () => context.push(RouteNames.notifications),
              icon: const Icon(Icons.notifications_outlined),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
      bottomNavigationBar: const StudentNavigationBar(selectedIndex: 0),
      children: [
        // 1. HEADER SISWA
        (() {
          final authState = ref.watch(authControllerProvider);
          final displayName = authState.fullName != null && authState.fullName!.isNotEmpty
              ? authState.fullName!
              : 'Muhammad';
          final firstLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'M';
          final photoPath = authState.photoPath;
          final schoolName = authState.schoolName != null && authState.schoolName!.isNotEmpty
              ? authState.schoolName!
              : 'SD Intelligent School';
          final educationLevel = authState.educationLevel != null && authState.educationLevel!.isNotEmpty
              ? authState.educationLevel!
              : 'SD Kelas 5';

          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.indigo.shade200, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.indigo.shade100,
                  backgroundImage: photoPath != null ? FileImage(File(photoPath)) : null,
                  child: photoPath == null
                      ? Text(
                          firstLetter,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang, $displayName 👋',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$educationLevel • $schoolName',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          );
        })(),
        const SizedBox(height: 20),

        // 2. HIGHLIGHT STATUS ANALISIS AI
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade800, Colors.purple.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology, color: Colors.amber, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'STATUS ANALISIS AI',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'AI telah menganalisis perkembangan belajar Anda berdasarkan model 1D-CNN.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCircularProgressStat(
                    label: 'Tingkat Literasi',
                    value: 0.78,
                    percentageString: '78%',
                    progressColor: Colors.amber,
                  ),
                  _buildCircularProgressStat(
                    label: 'Penalaran Logis',
                    value: 0.71,
                    percentageString: '71%',
                    progressColor: Colors.tealAccent,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Status Perkembangan:',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Terus Berkembang',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildMainMenuGrid(context),
        const SizedBox(height: 16),

        // 3. REKOMENDASI AI HARI INI
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.purple.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Rekomendasi AI Hari Ini',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Estimasi: 25 Menit',
                        style: TextStyle(
                          color: Colors.purple.shade800,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRecommendationItem(
                  context,
                  icon: '📖',
                  title: 'Bacaan Argumentasi',
                  subtitle: 'Melatih penarikan kesimpulan teks analitis.',
                  color: Colors.blue.shade50,
                ),
                const SizedBox(height: 12),
                _buildRecommendationItem(
                  context,
                  icon: '🧩',
                  title: 'Logika Matematika Level 2',
                  subtitle: 'Melatih kemampuan penalaran numerik adaptif.',
                  color: Colors.orange.shade50,
                ),
                const SizedBox(height: 12),
                _buildRecommendationItem(
                  context,
                  icon: '📈',
                  title: 'Latihan HOTS',
                  subtitle: 'Soal High Order Thinking Skills literasi.',
                  color: Colors.red.shade50,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => context.push('/student/modules/demo-module'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Mulai Belajar',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.play_arrow_rounded, size: 22),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 4. PROGRESS BELAJAR
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress Mingguan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Text(
                      '82%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: 0.82,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildProgressMetric('Materi Selesai', '24'),
                    _buildProgressMetric('Latihan Selesai', '56'),
                    _buildProgressMetric('Target Minggu Ini', '30 Materi'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 5. HASIL DIAGNOSTIK AI
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics_outlined, color: Colors.indigo.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Profil Literasi (Diagnostik AI)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDiagnosticStatusItem(
                  label: 'Membaca Dasar',
                  isCompleted: true,
                ),
                _buildDiagnosticStatusItem(
                  label: 'Memahami Informasi',
                  isCompleted: true,
                ),
                _buildDiagnosticStatusItem(
                  label: 'Analisis Teks',
                  isCompleted: false,
                ),
                _buildDiagnosticStatusItem(
                  label: 'Menarik Kesimpulan',
                  isCompleted: false,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    border: Border.all(color: Colors.amber.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline_rounded, color: Colors.amber.shade800),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Rekomendasi AI: Fokus latihan Anda hari ini adalah Analisis Teks.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7F5F00),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 6. JALUR PEMBELAJARAN ADAPTIF
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.alt_route_rounded, color: Colors.indigo.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Jalur Pembelajaran Adaptif',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPathLevel(level: '1', status: 'completed'),
                    _buildPathLine(isCompleted: true),
                    _buildPathLevel(level: '2', status: 'completed'),
                    _buildPathLine(isCompleted: true),
                    _buildPathLevel(level: '3', status: 'active'),
                    _buildPathLine(isCompleted: false),
                    _buildPathLevel(level: '4', status: 'locked'),
                  ],
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Nilai Anda akan menentukan pembukaan level berikutnya otomatis.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 7. DYNAMIC DIFFICULTY ADJUSTMENT (DDA)
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.speed_rounded, color: Colors.indigo.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Dynamic Difficulty (DDA)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildDifficultyChip('EASY', false)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildDifficultyChip('NORMAL', true)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildDifficultyChip('HARD', false)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Colors.blue.shade700),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Saat ini AI memilih tingkat kesulitan NORMAL. Jika nilai Anda meningkat, sistem akan otomatis beralih ke HARD.',
                          style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 8. STATISTIK AI
        const SectionTitle('Statistik AI'),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.track_changes_rounded,
                title: 'Akurasi Jawaban',
                value: '87%',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.timer_outlined,
                title: 'Waktu Belajar',
                value: '2j 31m',
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.local_fire_department_rounded,
                title: 'Learning Streak',
                value: '18 Hari',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.star_border_rounded,
                title: 'Target Mingguan',
                value: '92%',
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 9. AKTIVITAS TERBARU
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.history_rounded, color: Colors.indigo.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Aktivitas Terbaru',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildActivityItem('✔ Menyelesaikan Bacaan Argumentasi'),
                _buildActivityItem('✔ Mengikuti Latihan Numerasi Level 2'),
                _buildActivityItem('✔ AI Update Progress Belajar'),
                _buildActivityItem('✔ Level Kemampuan Bertambah'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 10. TARGET BELAJAR HARI INI
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.playlist_add_check_rounded, color: Colors.indigo.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Target Belajar Hari Ini',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildCheckboxTarget(
                      'Membaca Artikel Ilmiah Adaptif',
                      target1,
                      (val) => setState(() => target1 = val ?? false),
                    ),
                    _buildCheckboxTarget(
                      'Menyelesaikan 10 Soal HOTS',
                      target2,
                      (val) => setState(() => target2 = val ?? false),
                    ),
                    _buildCheckboxTarget(
                      'Kuis Penalaran Numerasi',
                      target3,
                      (val) => setState(() => target3 = val ?? false),
                    ),
                    _buildCheckboxTarget(
                      'Eksplorasi Proyek STEM',
                      target4,
                      (val) => setState(() => target4 = val ?? false),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 11. LENCANA PRESTASI
        const SectionTitle('Lencana Prestasi (Achievements)'),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildAchievementBadge('🏆', 'Critical Reader', 'Baca 10 artikel argumentatif.'),
              _buildAchievementBadge('🧠', 'Logic Master', 'Selesaikan 5 kuis logika.'),
              _buildAchievementBadge('📚', 'Active Learner', 'Selesaikan target belajar.'),
              _buildAchievementBadge('🔥', '30 Days Streak', 'Streak belajar 30 hari.'),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // WIDGET HELPERS

  Widget _buildCircularProgressStat({
    required String label,
    required double value,
    required String percentageString,
    required Color progressColor,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 8,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            Text(
              percentageString,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationItem(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildProgressMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosticStatusItem({
    required String label,
    required bool isCompleted,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            color: isCompleted ? Colors.green : Colors.amber.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isCompleted ? FontWeight.normal : FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPathLevel({required String level, required String status}) {
    Color bgColor;
    Widget child;

    if (status == 'completed') {
      bgColor = Colors.green;
      child = const Icon(Icons.check, color: Colors.white, size: 16);
    } else if (status == 'active') {
      bgColor = Colors.indigo;
      child = Text(
        level,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      );
    } else {
      bgColor = Colors.grey.shade200;
      child = Icon(Icons.lock, color: Colors.grey.shade500, size: 16);
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: status == 'active'
            ? [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  Widget _buildPathLine({required bool isCompleted}) {
    return Expanded(
      child: Container(
        height: 3,
        color: isCompleted ? Colors.green : Colors.grey.shade200,
      ),
    );
  }

  Widget _buildDifficultyChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? Colors.indigo : Colors.grey.shade100,
        border: Border.all(
          color: isActive ? Colors.indigo : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.white : Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text.substring(2),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTarget(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.indigo,
        ),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              decoration: value ? TextDecoration.lineThrough : null,
              color: value ? Colors.grey : Colors.black87,
              fontWeight: value ? FontWeight.normal : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(String emoji, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(right: 12, bottom: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 8, color: Colors.grey),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }


  // ==========================================
  // GRID MENU/FITUR UTAMA INTERAKTIF
  // ==========================================
  Widget _buildMainMenuGrid(BuildContext context) {
    final menus = [
      {'title': 'Materi', 'icon': Icons.menu_book, 'color': Colors.blue},
      {'title': 'AI Chat', 'icon': Icons.forum_outlined, 'color': Colors.indigo},
      {'title': 'Tugas', 'icon': Icons.assignment_outlined, 'color': Colors.red},
      {'title': 'Quiz', 'icon': Icons.quiz_outlined, 'color': Colors.orange},
      {'title': 'Artikel', 'icon': Icons.article_outlined, 'color': Colors.green},
      {'title': 'Video', 'icon': Icons.video_library_outlined, 'color': Colors.cyan},
      {'title': 'Dokumen', 'icon': Icons.folder_open_outlined, 'color': Colors.teal},
      {'title': 'Kalender', 'icon': Icons.calendar_month_outlined, 'color': Colors.purple},
      {'title': 'Event', 'icon': Icons.emoji_events_outlined, 'color': Colors.amber},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Eksplorasi Fitur Utama',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: menus.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (context, idx) {
            final menu = menus[idx];
            return InkWell(
              onTap: () => _handleMenuTap(context, menu['title'] as String),
              borderRadius: BorderRadius.circular(16),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (menu['color'] as Color).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        menu['icon'] as IconData,
                        color: menu['color'] as Color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      menu['title'] as String,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _handleMenuTap(BuildContext context, String title) {
    HapticFeedback.lightImpact();
    switch (title) {
      case 'Materi':
        _showMateriSheet(context);
        break;
      case 'AI Chat':
        _showAiChatSheet(context);
        break;
      case 'Tugas':
        _showTugasSheet(context);
        break;
      case 'Quiz':
        _showQuizSheet(context);
        break;
      case 'Artikel':
        _showArtikelSheet(context);
        break;
      case 'Video':
        _showVideoSheet(context);
        break;
      case 'Dokumen':
        _showDokumenSheet(context);
        break;
      case 'Kalender':
        _showKalenderSheet(context);
        break;
      case 'Event':
        _showEventSheet(context);
        break;
    }
  }

  void _showMateriSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Modul Belajar Adaptif', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
              const SizedBox(height: 16),
              _buildSheetLinkItem(context, '📖 Literasi Teks Deskriptif', 'Pelajari penarikan kesimpulan kalimat.'),
              _buildSheetLinkItem(context, '🧩 Numerasi Aljabar Linear', 'Pelajari persamaan variabel ganda.'),
              _buildSheetLinkItem(context, '📈 Eksperimen STEM Coding', 'Pelajari pengenalan algoritma pemrograman.'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSheetLinkItem(BuildContext context, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        onTap: () {
          Navigator.pop(context);
          context.push('/student/modules/demo-module');
        },
      ),
    );
  }

  void _showAiChatSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return _InteractiveTutorChatWidget(scrollController: scrollController);
          },
        );
      },
    );
  }

  void _showTugasSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return _InteractiveTugasWidget();
      },
    );
  }

  void _showQuizSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return _InteractiveQuizWidget();
      },
    );
  }

  void _showArtikelSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Artikel & Bacaan Populer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
              const SizedBox(height: 12),
              _buildArticleItem('Mengenal Kecerdasan Buatan (AI) di Sekolah', 'Bagaimana AI membantumu belajar lebih cepat.'),
              _buildArticleItem('Pentingnya Numerasi di Era Digital', 'Tips melatih nalar numerik sehari-hari.'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArticleItem(String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        leading: const Icon(Icons.menu_book, color: Colors.green),
        onTap: () {},
      ),
    );
  }

  void _showVideoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return _InteractiveVideoWidget();
      },
    );
  }

  void _showDokumenSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dokumen Pembelajaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 12),
              _buildDocDownloadItem('Panduan Belajar Mandiri.pdf', '1.2 MB'),
              _buildDocDownloadItem('Kumpulan Soal Latihan AKM 2026.pdf', '3.4 MB'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocDownloadItem(String title, String size) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text('Ukuran: $size', style: const TextStyle(fontSize: 11, color: Colors.grey)),
        leading: const Icon(Icons.file_download_outlined, color: Colors.teal),
        trailing: const Icon(Icons.download, size: 18),
        onTap: () {},
      ),
    );
  }

  void _showKalenderSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Kalender Belajar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple)),
              const SizedBox(height: 12),
              _buildScheduleItem('Hari Ini, 16:00', 'Sesi Quiz Aljabar Adaptif'),
              _buildScheduleItem('Besok, 09:00', 'Materi Video Literasi Analitik'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScheduleItem(String time, String title) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text('Jadwal: $time', style: const TextStyle(fontSize: 11, color: Colors.grey)),
        leading: const Icon(Icons.access_time, color: Colors.purple),
        onTap: () {},
      ),
    );
  }

  void _showEventSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Event & Tantangan Aktif', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
              const SizedBox(height: 12),
              _buildEventChallengeItem('🏆 Tantangan 7 Hari Belajar', 'Menangkan Lencana Emas STEM.'),
              _buildEventChallengeItem('🚀 Kompetisi Cerdas Cermat AI', 'Daftar sebelum 15 Juli 2026.'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventChallengeItem(String title, String desc) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(desc, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        trailing: const Icon(Icons.star, color: Colors.amber, size: 18),
        onTap: () {},
      ),
    );
  }
}

// ----------------------------------------------------
// STATEFUL INTERACTIVE CHATBOT TUTOR WIDGET
// ----------------------------------------------------
class _InteractiveTutorChatWidget extends StatefulWidget {
  final ScrollController scrollController;
  const _InteractiveTutorChatWidget({required this.scrollController});

  @override
  State<_InteractiveTutorChatWidget> createState() => _InteractiveTutorChatWidgetState();
}

class _InteractiveTutorChatWidgetState extends State<_InteractiveTutorChatWidget> {
  final _chatController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'sender': 'ai', 'text': 'Halo! Saya asisten AI LITERA-AI. Ada materi atau tugas yang ingin didiskusikan?'}
  ];

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _chatController.clear();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      String response = 'Itu pertanyaan bagus! Menurut teori, penalaran analitis penting dalam penyimpulan modul.';
      if (text.toLowerCase().contains('matematika') || text.toLowerCase().contains('angka')) {
        response = 'Untuk numerasi, pastikan memahami logika urutan operasi hitung terlebih dahulu.';
      }
      setState(() {
        _messages.add({'sender': 'ai', 'text': response});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Tanya AI Tutor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
          const Divider(),
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, idx) {
                final msg = _messages[idx];
                final isAi = msg['sender'] == 'ai';
                return Align(
                  alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isAi ? Colors.grey.shade100 : Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg['text']!, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(hintText: 'Tulis pesan...', contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(icon: const Icon(Icons.send, color: Colors.indigo), onPressed: _sendMessage),
            ],
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// STATEFUL INTERACTIVE TUGAS WIDGET
// ----------------------------------------------------
class _InteractiveTugasWidget extends StatefulWidget {
  @override
  State<_InteractiveTugasWidget> createState() => _InteractiveTugasWidgetState();
}

class _InteractiveTugasWidgetState extends State<_InteractiveTugasWidget> {
  final List<Map<String, dynamic>> _tasks = [
    {'title': 'Selesaikan Latihan Soal AKM Literasi', 'done': false},
    {'title': 'Tonton Video Edukasi Aljabar', 'done': true},
    {'title': 'Kirim Laporan Progres Mingguan', 'done': false},
  ];

  @override
  Widget build(BuildContext context) {
    final doneCount = _tasks.where((t) => t['done']).length;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tugas Mingguan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
          const SizedBox(height: 6),
          Text('Menyelesaikan $doneCount dari ${_tasks.length} tugas', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          Column(
            children: List.generate(_tasks.length, (idx) {
              final task = _tasks[idx];
              return CheckboxListTile(
                title: Text(task['title'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                value: task['done'],
                activeColor: Colors.red,
                onChanged: (val) {
                  setState(() {
                    _tasks[idx]['done'] = val;
                  });
                  HapticFeedback.lightImpact();
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// STATEFUL INTERACTIVE QUIZ WIDGET
// ----------------------------------------------------
class _InteractiveQuizWidget extends StatefulWidget {
  @override
  State<_InteractiveQuizWidget> createState() => _InteractiveQuizWidgetState();
}

class _InteractiveQuizWidgetState extends State<_InteractiveQuizWidget> {
  String? _selectedOption;
  bool? _isCorrect;

  void _checkAnswer(String option) {
    setState(() {
      _selectedOption = option;
      _isCorrect = option == 'B'; // 'B' is 40
    });
    if (_isCorrect!) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Kuis Penalaran Cepat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
          const SizedBox(height: 12),
          const Text(
            'Berapakah hasil dari 25% dari 160?',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildOptionRow('A. 30', 'A'),
          _buildOptionRow('B. 40', 'B'),
          _buildOptionRow('C. 50', 'C'),
          _buildOptionRow('D. 60', 'D'),
          if (_isCorrect != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isCorrect! ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _isCorrect! ? Colors.green : Colors.red),
              ),
              child: Text(
                _isCorrect! ? '🎉 Benar! Jawaban Anda tepat.' : '❌ Salah! Coba lagi.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _isCorrect! ? Colors.green.shade800 : Colors.red.shade800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionRow(String label, String code) {
    final isSelected = _selectedOption == code;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isSelected ? Colors.orange.shade50 : Colors.white,
      child: InkWell(
        onTap: () => _checkAnswer(code),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// STATEFUL INTERACTIVE VIDEO WIDGET
// ----------------------------------------------------
class _InteractiveVideoWidget extends StatefulWidget {
  @override
  State<_InteractiveVideoWidget> createState() => _InteractiveVideoWidgetState();
}

class _InteractiveVideoWidgetState extends State<_InteractiveVideoWidget> {
  bool _isPlaying = false;
  double _progress = 0.2;
  Timer? _videoTimer;

  @override
  void dispose() {
    _videoTimer?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      _videoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() {
          if (_progress < 1.0) {
            _progress += 0.05;
          } else {
            _progress = 0.0;
          }
        });
      });
    } else {
      _videoTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Video Edukasi Adaptif', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyan)),
          const SizedBox(height: 12),
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: IconButton(
                icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle, color: Colors.white, size: 54),
                onPressed: _togglePlay,
              ),
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: _progress, color: Colors.cyan, backgroundColor: Colors.grey.shade300),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_isPlaying ? 'Memutar...' : 'Dijeda', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text('${(_progress * 100).toInt()}% selesai', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

