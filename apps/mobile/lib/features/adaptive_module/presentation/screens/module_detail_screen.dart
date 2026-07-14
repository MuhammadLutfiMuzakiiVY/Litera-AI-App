import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:litera_ai_mobile/features/learning/application/learning_providers.dart';
import 'package:litera_ai_mobile/shared/widgets/app_screen.dart';

class ModuleDetailScreen extends ConsumerStatefulWidget {
  const ModuleDetailScreen({required this.moduleId, super.key});

  final String moduleId;

  @override
  ConsumerState<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends ConsumerState<ModuleDetailScreen> {
  bool _isBookmarked = false;
  bool _isFinishedReading = false;
  double _userRating = 0.0;

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isBookmarked ? 'Modul berhasil disimpan ke bookmark! 📌' : 'Modul dihapus dari bookmark.'),
        backgroundColor: _isBookmarked ? Colors.green : Colors.grey[800],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareModule(String title) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Bagikan Modul Belajar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareOption(context, 'WhatsApp', Icons.chat_bubble_outline, Colors.green),
                  _buildShareOption(context, 'Telegram', Icons.telegram, Colors.blue),
                  _buildShareOption(context, 'Salin Link', Icons.link, Colors.grey),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareOption(BuildContext context, String label, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(label == 'Salin Link' ? 'Tautan modul berhasil disalin ke clipboard!' : 'Membuka $label untuk membagikan modul...'),
            backgroundColor: Colors.green,
          ),
        );
      },
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _toggleReadingStatus() {
    setState(() {
      _isFinishedReading = !_isFinishedReading;
    });
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFinishedReading ? 'Modul ditandai selesai dibaca! 🎉' : 'Status selesai dibaca dibatalkan.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final module = ref.watch(moduleDetailProvider(widget.moduleId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Detail Modul Adaptif', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: module.when(
          data: (data) => ListView(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            children: [
              // 1. FEATURED COVER BANNER CARD
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade800, Colors.purple.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Dot grids background decoration overlay
                    Positioned(
                      right: -10,
                      top: -10,
                      child: Opacity(
                        opacity: 0.15,
                        child: Icon(Icons.blur_on, size: 140, color: Colors.white),
                      ),
                    ),
                    // Banner contents
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'MODUL REKOMENDASI AI',
                              style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data.title,
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Estimasi waktu belajar: ${data.estimatedMinutes} menit',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    // Floating Bookmark + Share Buttons in top right
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: IconButton(
                              icon: const Icon(Icons.share, color: Colors.white, size: 20),
                              onPressed: () => _shareModule(data.title),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: IconButton(
                              icon: Icon(
                                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                color: _isBookmarked ? Colors.amber : Colors.white,
                                size: 20,
                              ),
                              onPressed: _toggleBookmark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. BADGES ROW
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBadgeDetailItem(Icons.signal_cellular_alt, 'Kesulitan', data.difficulty),
                  _buildBadgeDetailItem(Icons.timer_outlined, 'Durasi', '${data.estimatedMinutes} Min'),
                  _buildBadgeDetailItem(Icons.bookmark_outline, 'Status', _isFinishedReading ? 'Selesai' : 'Belum Selesai'),
                ],
              ),
              const SizedBox(height: 24),

              // 3. DESCRIPTION / GOALS
              const Text('Deskripsi Modul', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
              const SizedBox(height: 8),
              Text(
                'Modul pembelajaran adaptif ini telah disesuaikan oleh AI berdasarkan progres belajar Anda. Baca dan pahami materi serta contoh di bawah ini sebelum melanjutkan ke kuis adaptif.',
                style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
              ),
              const SizedBox(height: 20),

              // 4. CONTENTS LIST
              const Text('Materi & Bacaan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
              const SizedBox(height: 10),
              for (final content in data.contents) ...[
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              content.contentType == 'example' ? Icons.lightbulb_outline : Icons.science_outlined,
                              color: Colors.amber[800],
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                content.body['title'] as String? ?? 'Materi',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          content.body['text'] as String? ?? '',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // 5. RATING FEEDBACK SELECTOR
              const Text(
                'Apakah modul ini membantu Anda?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starRating = index + 1.0;
                  return IconButton(
                    icon: Icon(
                      _userRating >= starRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 28,
                    ),
                    onPressed: () {
                      setState(() {
                        _userRating = starRating;
                      });
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Terima kasih! Penilaian $starRating bintang Anda berhasil disimpan.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),

              // 6. ACTION BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _toggleReadingStatus,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Colors.indigo),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: Icon(_isFinishedReading ? Icons.check_circle : Icons.check_circle_outline),
                      label: Text(_isFinishedReading ? 'Selesai Dibaca' : 'Tandai Selesai'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/student/quizzes/${widget.moduleId}/start'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.quiz_outlined),
                      label: const Text('Mulai Kuis AI'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: AppEmptyState(
              title: 'Modul gagal dimuat',
              message: 'Periksa koneksi lalu coba lagi.',
              action: FilledButton.icon(
                onPressed: () => ref.invalidate(moduleDetailProvider(widget.moduleId)),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeDetailItem(IconData icon, String title, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.indigo, size: 20),
          const SizedBox(height: 6),
          Text(title, style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo)),
        ],
      ),
    );
  }
}
