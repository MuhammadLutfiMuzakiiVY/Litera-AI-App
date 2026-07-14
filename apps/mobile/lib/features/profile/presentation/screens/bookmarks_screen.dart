import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:litera_ai_mobile/app/router/route_names.dart';
import 'package:litera_ai_mobile/shared/widgets/app_screen.dart';
import 'package:litera_ai_mobile/shared/widgets/skeleton_loader.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;

  // Initial mock list of bookmark modules
  final List<Map<String, dynamic>> _bookmarkedItems = [
    {
      'id': 'demo-module',
      'title': 'Literasi Kalimat Deskriptif',
      'category': 'Literasi Adaptif',
      'difficulty': 'Mudah',
      'duration': '20 Min',
      'icon': Icons.menu_book,
      'color': Colors.blue,
    },
    {
      'id': 'algebra-module',
      'title': 'Numerasi Aljabar Linear',
      'category': 'Numerasi',
      'difficulty': 'Sedang',
      'duration': '25 Min',
      'icon': Icons.calculate_outlined,
      'color': Colors.orange,
    },
    {
      'id': 'stem-coding',
      'title': 'Pengenalan Algoritma STEM',
      'category': 'STEM',
      'difficulty': 'Sulit',
      'duration': '35 Min',
      'icon': Icons.code_rounded,
      'color': Colors.teal,
    },
    {
      'id': 'logic-quiz',
      'title': 'Logika Penalaran Kritis',
      'category': 'Logika',
      'difficulty': 'Sedang',
      'duration': '15 Min',
      'icon': Icons.psychology_outlined,
      'color': Colors.purple,
    },
  ];

  // Store recently deleted item for Undo action
  Map<String, dynamic>? _lastDeletedItem;
  int? _lastDeletedIndex;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _removeBookmark(int index) {
    HapticFeedback.mediumImpact();
    setState(() {
      _lastDeletedItem = _bookmarkedItems[index];
      _lastDeletedIndex = index;
      _bookmarkedItems.removeAt(index);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${_lastDeletedItem!['title']}" dihapus dari favorit.'),
        action: SnackBarAction(
          label: 'URUNGKAN',
          textColor: Colors.amber,
          onPressed: () {
            if (_lastDeletedItem != null && _lastDeletedIndex != null) {
              setState(() {
                _bookmarkedItems.insert(_lastDeletedIndex!, _lastDeletedItem!);
              });
              HapticFeedback.mediumImpact();
            }
          },
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() {
      _isLoading = false;
    });
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Daftar favorit disinkronkan dengan cloud.'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter bookmarks based on search query
    final filteredItems = _bookmarkedItems.where((item) {
      final title = item['title'].toString().toLowerCase();
      final category = item['category'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || category.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Favorit / Bookmark', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. SEARCH BAR
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Cari modul favorit...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
                  ),
                ),
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                child: _isLoading
                    ? const SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: SkeletonListLoader(itemCount: 4),
                      )
                    : filteredItems.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                        itemCount: filteredItems.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, idx) {
                          final item = filteredItems[idx];
                          // Match the original index in the main list for removal
                          final originalIndex = _bookmarkedItems.indexOf(item);

                          return Dismissible(
                            key: Key(item['id'] as String),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => _removeBookmark(originalIndex),
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 1,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (item['color'] as Color).withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(item['icon'] as IconData, color: item['color'] as Color),
                                ),
                                title: Text(
                                  item['title'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item['category'] as String,
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${item['difficulty']} • ${item['duration']}',
                                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _removeBookmark(originalIndex),
                                ),
                                onTap: () {
                                  context.push('/student/modules/${item['id']}');
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bookmark_outline_rounded, size: 54, color: Colors.indigo),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tidak ada favorit',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Materi atau quiz yang Anda bookmark akan disimpan di sini agar mudah diakses kembali.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
