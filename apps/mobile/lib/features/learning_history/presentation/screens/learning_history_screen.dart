import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:litera_ai_mobile/shared/widgets/app_navigation.dart';
import 'package:litera_ai_mobile/shared/widgets/app_screen.dart';

class LearningHistoryScreen extends StatefulWidget {
  const LearningHistoryScreen({super.key});

  @override
  State<LearningHistoryScreen> createState() => _LearningHistoryScreenState();
}

class _LearningHistoryScreenState extends State<LearningHistoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int _activeTab = 0; // 0: Pembelajaran, 1: Chat Tutor AI, 2: Transaksi, 3: Aktivitas Akun

  // Mock datasets for the 4 history categories
  final List<Map<String, dynamic>> _learningHistory = [
    {
      'title': 'Quiz Inferensi Teks',
      'body': 'Skor 80/100 • Mastery 0.74 • Level Sedang',
      'type': 'quiz',
      'date': '10 Juli 2026',
      'details': 'Benar: 4 Soal, Salah: 1 Soal. Peningkatan di sub-materi penarikan kesimpulan deduktif.',
    },
    {
      'title': 'Modul STEM Air Sekolah',
      'body': 'Progress 100% • Selesai dibaca',
      'type': 'modul',
      'date': '10 Juli 2026',
      'details': 'Waktu belajar: 24 Menit. Selesai membaca 3 modul STEM dasar.',
    },
    {
      'title': 'Quiz Logika Numerik',
      'body': 'Skor 95/100 • Mastery 0.88 • Level Sulit',
      'type': 'quiz',
      'date': '9 Juli 2026',
      'details': 'Benar: 5 Soal, Salah: 0 Soal. Menguasai konsep dasar aljabar linear terapan.',
    },
    {
      'title': 'Modul Membaca Kritis',
      'body': 'Progress 40% • Terakhir dibuka kemarin',
      'type': 'modul',
      'date': '9 Juli 2026',
      'details': 'Waktu belajar: 8 Menit. Bab 2 sub-materi analisis teks argumentasi.',
    },
  ];

  final List<Map<String, dynamic>> _chatHistory = [
    {
      'title': 'Diskusi Rumus Kuadrat',
      'body': 'AI Asisten Tutor • 3 pesan terkirim',
      'date': '10 Juli 2026',
      'dialog': [
        {'sender': 'user', 'text': 'Bagaimana rumus abc untuk kuadrat?'},
        {'sender': 'ai', 'text': 'Rumus abc adalah x = (-b ± √(b² - 4ac)) / 2a.'},
        {'sender': 'user', 'text': 'Oh begitu, terima kasih Tutor!'},
      ],
    },
    {
      'title': 'Latihan Menulis Essay',
      'body': 'AI Asisten Tutor • 2 pesan terkirim',
      'date': '8 Juli 2026',
      'dialog': [
        {'sender': 'user', 'text': 'Apa ciri essay argumentatif?'},
        {'sender': 'ai', 'text': 'Memiliki tesis yang jelas, menyertakan bukti pendukung, dan menyangkal argumen tandingan.'},
      ],
    },
    {
      'title': 'Sistem Model DKT',
      'body': 'AI Asisten Tutor • 2 pesan terkirim',
      'date': '7 Juli 2026',
      'dialog': [
        {'sender': 'user', 'text': 'Apa itu model DKT di LITERA-AI?'},
        {'sender': 'ai', 'text': 'Deep Knowledge Tracing (DKT) melacak tingkat pemahaman konsep Anda dari waktu ke waktu.'},
      ],
    },
  ];

  final List<Map<String, dynamic>> _transactionHistory = [
    {
      'title': 'Pembelian Skin Gold Dashboard',
      'body': 'Potongan Koin Gamifikasi',
      'value': '-150 Koin',
      'date': '9 Juli 2026',
      'color': Colors.red,
    },
    {
      'title': 'Daily Login Reward',
      'body': 'Hadiah Masuk Harian',
      'value': '+20 Koin',
      'date': '9 Juli 2026',
      'color': Colors.green,
    },
    {
      'title': 'Bonus Lencana Logic Master',
      'body': 'Hadiah Level Up AI',
      'value': '+100 XP',
      'date': '8 Juli 2026',
      'color': Colors.green,
    },
    {
      'title': 'Pendaftaran Kompetisi STEM',
      'body': 'Tiket Masuk Event Mingguan',
      'value': '-50 Koin',
      'date': '6 Juli 2026',
      'color': Colors.red,
    },
  ];

  final List<Map<String, dynamic>> _accountHistory = [
    {
      'title': 'Login Perangkat Baru',
      'body': 'Xiaomi 13 • Jakarta, Indonesia',
      'time': '14:02 WIB',
      'date': '10 Juli 2026',
    },
    {
      'title': 'Pembaruan Data Sekolah',
      'body': 'Profil disinkronkan ke SMA Intelligent',
      'time': '10:15 WIB',
      'date': '9 Juli 2026',
    },
    {
      'title': 'Verifikasi Email Sukses',
      'body': 'Email terhubung & terverifikasi',
      'time': '09:30 WIB',
      'date': '9 Juli 2026',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Get filtered items depending on active tab
  List<Map<String, dynamic>> get _filteredHistory {
    final query = _searchQuery.toLowerCase();
    List<Map<String, dynamic>> activeList;

    switch (_activeTab) {
      case 1:
        activeList = _chatHistory;
        break;
      case 2:
        activeList = _transactionHistory;
        break;
      case 3:
        activeList = _accountHistory;
        break;
      default:
        activeList = _learningHistory;
    }

    return activeList.where((item) {
      final title = item['title'].toString().toLowerCase();
      final body = item['body'].toString().toLowerCase();
      return title.contains(query) || body.contains(query);
    }).toList();
  }

  // Show dialog details of history item
  void _showDetailsDialog(Map<String, dynamic> item) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tanggal: ${item['date'] ?? '-'}', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (_activeTab == 0) ...[
                const Text('Analisis Progres:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(item['details'] as String, style: const TextStyle(fontSize: 13, height: 1.4)),
              ] else if (_activeTab == 1) ...[
                const Text('Percakapan AI:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 150,
                  width: double.maxFinite,
                  child: ListView.builder(
                    itemCount: (item['dialog'] as List).length,
                    itemBuilder: (context, idx) {
                      final message = (item['dialog'] as List)[idx];
                      final isUser = message['sender'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.indigo.shade50 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            message['text'] as String,
                            style: const TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ] else if (_activeTab == 2) ...[
                Text('Jenis Transaksi: ${item['body']}', style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                Text('Nilai: ${item['value']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: item['color'] as Color)),
              ] else ...[
                Text('Perangkat: ${item['body']}', style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 4),
                Text('Waktu: ${item['time']}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredHistory;

    return AppScreen(
      title: 'Riwayat Pembelajaran & Aktivitas',
      bottomNavigationBar: const StudentNavigationBar(selectedIndex: 2),
      children: [
        // 1. SEARCH BAR
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari riwayat...',
              prefixIcon: const Icon(Icons.search, color: Colors.indigo),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade100, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        const SizedBox(height: 16),

        // 2. HORIZONTAL TAB SELECTOR
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildTabChip(0, 'Pembelajaran', Icons.school),
              _buildTabChip(1, 'Chat Tutor AI', Icons.forum),
              _buildTabChip(2, 'Gamifikasi', Icons.paid),
              _buildTabChip(3, 'Aktivitas Akun', Icons.history),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 3. HISTORY LIST OR EMPTY STATE
        if (list.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 72, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Riwayat tidak ditemukan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Coba gunakan kata kunci pencarian yang berbeda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...list.map((item) => _buildHistoryCard(item)),
      ],
    );
  }

  Widget _buildTabChip(int index, String label, IconData icon) {
    final isSelected = _activeTab == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.indigo),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        selected: isSelected,
        selectedColor: Colors.indigo.shade800,
        checkmarkColor: Colors.white,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: isSelected ? Colors.indigo.shade800 : Colors.grey.shade300,
          width: 1.2,
        ),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        onSelected: (selected) {
          setState(() {
            _activeTab = index;
          });
          HapticFeedback.lightImpact();
        },
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    IconData icon;
    Color color;

    if (_activeTab == 0) {
      final isQuiz = item['type'] == 'quiz';
      icon = isQuiz ? Icons.check_circle_outline : Icons.auto_stories_outlined;
      color = isQuiz ? Colors.teal : Colors.indigo;
    } else if (_activeTab == 1) {
      icon = Icons.psychology;
      color = Colors.indigo;
    } else if (_activeTab == 2) {
      icon = Icons.emoji_events;
      color = item['color'] as Color;
    } else {
      icon = Icons.devices;
      color = Colors.blueGrey;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          item['title'] as String,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['body'] as String,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['date'] as String,
                    style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  if (_activeTab == 2)
                    Text(
                      item['value'] as String,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                    ),
                ],
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        onTap: () => _showDetailsDialog(item),
      ),
    );
  }
}
