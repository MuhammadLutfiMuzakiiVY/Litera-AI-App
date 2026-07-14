import 'package:flutter/material.dart';
import 'package:litera_ai_mobile/shared/widgets/app_screen.dart';

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String category;
  final IconData icon;
  final Color iconColor;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.category,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  // Prefilled mock notifications
  late List<NotificationModel> _notifications;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _notifications = [
      NotificationModel(
        id: 'notif-1',
        title: 'Hasil Asesmen Diagnostik Tersedia',
        description: 'Selamat! AI telah memproses hasil asesmen awal membaca kritis Anda. Tingkat literasi Anda saat ini berada di angka 82%.',
        category: 'Asesmen Diagnostik',
        timestamp: now.subtract(const Duration(hours: 1)),
        icon: Icons.assignment_turned_in_outlined,
        iconColor: Colors.teal,
        isRead: false,
      ),
      NotificationModel(
        id: 'notif-2',
        title: 'Rekomendasi AI Baru',
        description: 'Berdasarkan perkembangan belajar Anda, AI menyarankan untuk mempelajari modul "STEM: Energi Air Sekolah" (25 Menit).',
        category: 'Rekomendasi AI',
        timestamp: now.subtract(const Duration(hours: 4)),
        icon: Icons.auto_awesome,
        iconColor: Colors.amber,
        isRead: false,
      ),
      NotificationModel(
        id: 'notif-3',
        title: 'Tingkat Kesulitan Berubah (DDA)',
        description: 'Dynamic Difficulty Adjustment mendeteksi pemahaman Anda meningkat. Kesulitan modul Logika Matematika dinaikkan ke Sedang.',
        category: 'Pembelajaran',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        icon: Icons.trending_up,
        iconColor: Colors.purple,
        isRead: false,
      ),
      NotificationModel(
        id: 'notif-4',
        title: 'Latihan HOTS Baru Tersedia',
        description: 'Guru Matematika mengunggah latihan penalaran logis baru tingkat lanjut untuk kelas Anda.',
        category: 'Tugas & Latihan',
        timestamp: now.subtract(const Duration(days: 1, hours: 8)),
        icon: Icons.fitness_center_outlined,
        iconColor: Colors.blue,
        isRead: true,
      ),
      NotificationModel(
        id: 'notif-5',
        title: 'Lencana Prestasi Diperoleh! 🎉',
        description: 'Hebat! Anda memperoleh lencana "Top Reader" karena menyelesaikan 10 materi literasi minggu ini.',
        category: 'Prestasi',
        timestamp: now.subtract(const Duration(days: 3)),
        icon: Icons.emoji_events_outlined,
        iconColor: Colors.orange,
        isRead: true,
      ),
      NotificationModel(
        id: 'notif-6',
        title: 'Pembaruan Aplikasi LITERA-AI v1.2',
        description: 'Pembaruan sistem: optimasi engine rekomendasi DKT dan sinkronisasi offline lebih cepat.',
        category: 'Sistem',
        timestamp: now.subtract(const Duration(days: 10)),
        icon: Icons.system_update_outlined,
        iconColor: Colors.indigo,
        isRead: true,
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  List<NotificationModel> get _filteredNotifications {
    return _notifications.where((n) {
      final matchesSearch = n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          n.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategory == 'Semua' ||
          (_selectedCategory == 'Belum Dibaca' && !n.isRead) ||
          n.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  // Group notifications by relative date
  Map<String, List<NotificationModel>> _groupNotifications(List<NotificationModel> list) {
    final Map<String, List<NotificationModel>> groups = {
      'Hari Ini': [],
      'Kemarin': [],
      'Minggu Ini': [],
      'Bulan Ini': [],
    };

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    for (final item in list) {
      final itemDate = DateTime(item.timestamp.year, item.timestamp.month, item.timestamp.day);
      if (itemDate == today) {
        groups['Hari Ini']!.add(item);
      } else if (itemDate == yesterday) {
        groups['Kemarin']!.add(item);
      } else if (itemDate.isAfter(weekAgo)) {
        groups['Minggu Ini']!.add(item);
      } else {
        groups['Bulan Ini']!.add(item);
      }
    }

    // Clean empty groups
    groups.removeWhere((key, value) => value.isEmpty);
    return groups;
  }

  void _markAllAsRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi ditandai sebagai sudah dibaca.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearAllNotifications() {
    final deleted = List<NotificationModel>.from(_notifications);
    setState(() {
      _notifications.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Semua notifikasi dihapus.'),
        action: SnackBarAction(
          label: 'Batal',
          textColor: Colors.amber,
          onPressed: () {
            setState(() {
              _notifications.addAll(deleted);
            });
          },
        ),
      ),
    );
  }

  void _toggleReadStatus(NotificationModel item) {
    setState(() {
      item.isRead = !item.isRead;
    });
  }

  void _deleteNotification(NotificationModel item) {
    final index = _notifications.indexWhere((n) => n.id == item.id);
    if (index == -1) return;

    setState(() {
      _notifications.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${item.title}" dihapus.'),
        action: SnackBarAction(
          label: 'Batal',
          textColor: Colors.amber,
          onPressed: () {
            setState(() {
              _notifications.insert(index, item);
            });
          },
        ),
      ),
    );
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pengaturan Notifikasi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Rekomendasi AI Baru'),
                value: true,
                onChanged: (val) {},
                activeColor: Colors.indigo,
              ),
              SwitchListTile(
                title: const Text('Hasil Asesmen & Analisis'),
                value: true,
                onChanged: (val) {},
                activeColor: Colors.indigo,
              ),
              SwitchListTile(
                title: const Text('Pengingat Target Harian'),
                value: true,
                onChanged: (val) {},
                activeColor: Colors.indigo,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDetailDialog(NotificationModel item) {
    setState(() => item.isRead = true);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Icon(item.icon, color: item.iconColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            item.description,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Action redirection simulation
                if (item.category == 'Rekomendasi AI' || item.category == 'Pembelajaran') {
                  Navigator.pop(context); // Go back from notification list
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Mulai Belajar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel item) {
    return Dismissible(
      key: Key(item.id),
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.green.shade600,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        child: const Icon(Icons.mark_email_read, color: Colors.white),
      ),
      secondaryBackground: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_sweep, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          setState(() {
            item.isRead = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notifikasi ditandai sebagai dibaca.'),
              backgroundColor: Colors.green,
            ),
          );
          return false; // Don't delete
        } else {
          return true; // Dismiss & delete
        }
      },
      onDismissed: (direction) {
        _deleteNotification(item);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : Colors.indigo.shade50.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isRead ? Colors.grey.shade200 : Colors.indigo.shade100,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.iconColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.iconColor, size: 22),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (!item.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.indigo,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, height: 1.3),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: item.iconColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.category,
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: item.iconColor),
                    ),
                  ),
                  Text(
                    _formatDuration(item.timestamp),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
          onTap: () => _showDetailDialog(item),
        ),
      ),
    );
  }

  String _formatDuration(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    if (diff.inDays < 7) return '${diff.inDays}h lalu';
    return '${time.day}/${time.month}';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredNotifications;
    final groups = _groupNotifications(filtered);

    return AppScreen(
      title: 'Notifikasi',
      actions: [
        IconButton(
          tooltip: 'Pengaturan Notifikasi',
          icon: const Icon(Icons.settings_outlined),
          onPressed: _showNotificationSettings,
        ),
      ],
      children: [
        // UNREAD HEADLINE & ACTION OPTIONS
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_unreadCount Belum Dibaca',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: _notifications.isEmpty ? null : _markAllAsRead,
              child: const Text('Tandai Semua Dibaca', style: TextStyle(fontSize: 11)),
            ),
            TextButton(
              onPressed: _notifications.isEmpty ? null : _clearAllNotifications,
              child: const Text('Hapus Semua', style: TextStyle(fontSize: 11, color: Colors.red)),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // SEARCH BAR
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari notifikasi...',
              hintStyle: const TextStyle(fontSize: 13),
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
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),
        ),
        const SizedBox(height: 16),

        // CATEGORY FILTER ROW
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              'Semua',
              'Belum Dibaca',
              'Pembelajaran',
              'Asesmen Diagnostik',
              'Rekomendasi AI',
              'Tugas & Latihan',
              'Prestasi',
              'Sistem',
            ].map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: FilterChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: Colors.indigo.shade800,
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? Colors.indigo.shade800 : Colors.grey.shade300,
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // NOTIFICATION GROUPS OR EMPTY STATE
        if (filtered.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.notifications_off_outlined, size: 64, color: Colors.indigo.shade400),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum Ada Notifikasi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Semua aktivitas dan rekomendasi AI belajar Anda\nakan muncul di halaman ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...groups.entries.map((group) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 4),
                  child: Text(
                    group.key,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                ...group.value.map((item) => _buildNotificationCard(item)),
              ],
            );
          }),
      ],
    );
  }
}
