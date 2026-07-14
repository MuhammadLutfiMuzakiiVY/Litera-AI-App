import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final _searchController = TextEditingController();
  final _feedbackController = TextEditingController();
  final _chatInputController = TextEditingController();
  final _emailTitleController = TextEditingController();
  final _emailBodyController = TextEditingController();

  String _searchQuery = '';
  double _feedbackRating = 5;
  bool _isChatting = false;

  // Mock FAQ list
  final List<Map<String, String>> _faqs = [
    {
      'question': 'Bagaimana cara AI menyesuaikan materi belajar?',
      'answer': 'LITERA-AI melacak performa Anda pada kuis adaptif. Jika Anda menjawab salah, AI akan merekomendasikan modul remedial tingkat dasar. Jika benar, tingkat kesulitan modul berikutnya akan ditingkatkan secara bertahap.',
    },
    {
      'question': 'Apakah aplikasi dapat berjalan saat offline?',
      'answer': 'Ya! Anda dapat membaca modul dan mengerjakan kuis offline. Aksi belajar Anda akan disimpan sementara di antrean outbox perangkat dan disinkronkan secara otomatis ketika Anda kembali terhubung ke internet.',
    },
    {
      'question': 'Bagaimana cara mengubah peran (Siswa, Guru, Orang Tua)?',
      'answer': 'Peran Anda ditentukan berdasarkan alamat email akun saat pertama kali mendaftar. Untuk mencoba peran lain, Anda dapat logout lalu masuk menggunakan email demo khusus (misal: guru@litera-ai.id atau parent@litera-ai.id).',
    },
    {
      'question': 'Apa itu nilai Mastery pada riwayat belajar?',
      'answer': 'Mastery score adalah estimasi tingkat penguasaan konsep Anda terhadap topik tertentu (nilai berkisar antara 0.0 hingga 1.0). Skor ini dihitung menggunakan model Deep Knowledge Tracing.',
    },
  ];

  // Mock Chat Admin conversation logs
  final List<Map<String, dynamic>> _chatMessages = [
    {
      'sender': 'admin',
      'text': 'Halo! Selamat datang di Pusat Bantuan LITERA-AI. Ada yang bisa kami bantu hari ini?',
      'time': 'Sekarang',
    }
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _feedbackController.dispose();
    _chatInputController.dispose();
    _emailTitleController.dispose();
    _emailBodyController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _chatInputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _chatMessages.add({
        'sender': 'user',
        'text': text,
        'time': 'Sekarang',
      });
      _chatInputController.clear();
    });
    HapticFeedback.lightImpact();

    // Simulated auto response from Support Admin
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        String replyText = 'Terima kasih atas pesan Anda. Agen dukungan kami sedang memeriksa pertanyaan Anda: "$text". Silakan tunggu beberapa saat.';
        if (text.toLowerCase().contains('kuis') || text.toLowerCase().contains('quiz')) {
          replyText = 'Untuk masalah kuis offline, pastikan Anda menekan tombol "Sync" di halaman Pengaturan setelah terhubung kembali ke internet.';
        } else if (text.toLowerCase().contains('email') || text.toLowerCase().contains('akun')) {
          replyText = 'Perubahan data email atau profil dapat dilakukan melalui menu "Edit Profil" di tab Profil AI Anda.';
        }
        _chatMessages.add({
          'sender': 'admin',
          'text': replyText,
          'time': 'Sekarang',
        });
      });
      HapticFeedback.mediumImpact();
    });
  }

  void _submitFeedback() {
    final comment = _feedbackController.text.trim();
    HapticFeedback.mediumImpact();
    Navigator.pop(context); // Close feedback modal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Feedback $_feedbackRating Bintang berhasil dikirim! Terima kasih atas masukan Anda.'),
        backgroundColor: Colors.green,
      ),
    );
    _feedbackController.clear();
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Kirim Umpan Balik', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Berikan penilaian Anda terhadap kenyamanan menggunakan aplikasi LITERA-AI:', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final rating = index + 1.0;
                  return IconButton(
                    icon: Icon(
                      _feedbackRating >= rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      setDialogState(() => _feedbackRating = rating);
                      HapticFeedback.lightImpact();
                    },
                  );
                }),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _feedbackController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Komentar & Masukan',
                  hintText: 'Tuliskan saran Anda di sini...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: _submitFeedback,
              child: const Text('Kirim'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmailDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Kirim Email Dukungan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _emailTitleController,
              decoration: const InputDecoration(labelText: 'Subjek Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailBodyController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Pesan Dukungan', hintText: 'Jelaskan pertanyaan Anda secara mendetail...', border: OutlineInputBorder()),
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
                const SnackBar(content: Text('Email berhasil dikirim ke support@litera-ai.id! ✉️'), backgroundColor: Colors.green),
              );
              _emailTitleController.clear();
              _emailBodyController.clear();
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  void _openWhatsApp() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Membuka WhatsApp Support Chat LITERA-AI... 💬'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = _faqs.where((faq) {
      final q = faq['question']!.toLowerCase();
      final a = faq['answer']!.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return q.contains(query) || a.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Pusat Bantuan', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!_isChatting) ...[
              // 1. HEADER HERO BANNER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade800, Colors.purple.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ada Kendala Belajar?',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Tim asisten & admin LITERA-AI siap membantu Anda kapan saja.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),

              // 2. SUPPORT CHANNEL CARDS GRID
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildChannelCard(Icons.forum_outlined, 'Chat Admin', 'Hubungi kami via chat live.', () {
                      setState(() => _isChatting = true);
                      HapticFeedback.lightImpact();
                    }, Colors.blue),
                    _buildChannelCard(Icons.mail_outline, 'Email Support', 'Kirim keluhan formal.', _showEmailDialog, Colors.purple),
                    _buildChannelCard(Icons.chat_bubble_outline, 'WhatsApp Support', 'Layanan chat cepat.', _openWhatsApp, Colors.green),
                    _buildChannelCard(Icons.rate_review_outlined, 'Feedback / Nilai', 'Beri kami masukan.', _showFeedbackDialog, Colors.amber),
                  ],
                ),
              ),

              // 3. SEARCH BAR FAQ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Cari pertanyaan umum...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 4. FAQ EXPANSION TILES LIST
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredFaqs.length,
                  itemBuilder: (context, idx) {
                    final faq = filteredFaqs[idx];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ExpansionTile(
                        title: Text(faq['question']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.indigo)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                            child: Text(faq['answer']!, style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              // CHAT WITH SUPPORT ADMIN ACTIVE SCREEN
              _buildChatContainer(),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildChannelCard(IconData icon, String title, String subtitle, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.12),
                radius: 18,
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 9, color: Colors.grey[500])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatContainer() {
    return Expanded(
      child: Column(
        children: [
          // Chat Window Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() => _isChatting = false),
                ),
                const SizedBox(width: 8),
                const CircleAvatar(
                  backgroundColor: Colors.indigo,
                  child: Icon(Icons.support_agent, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dukungan Admin', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Online • Siap membantu', style: TextStyle(fontSize: 10, color: Colors.green)),
                  ],
                ),
              ],
            ),
          ),

          // Messages List View
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _chatMessages.length,
              itemBuilder: (context, idx) {
                final msg = _chatMessages[idx];
                final isAdmin = msg['sender'] == 'admin';

                return Align(
                  alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isAdmin ? Colors.white : Colors.indigo,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
                      ],
                    ),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    child: Text(
                      msg['text'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: isAdmin ? Colors.black87 : Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input text editor bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatInputController,
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan Anda...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.indigo,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
