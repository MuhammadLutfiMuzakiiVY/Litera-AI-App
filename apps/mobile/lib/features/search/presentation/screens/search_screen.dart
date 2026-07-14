import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:litera_ai_mobile/features/auth/application/auth_controller.dart';
import 'package:litera_ai_mobile/shared/widgets/app_screen.dart';

class SearchItem {
  final String id;
  final String title;
  final String category;
  final String difficulty;
  final int estimatedMinutes;
  final double progress;
  final bool isAiRecommended;
  final IconData icon;

  const SearchItem({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.progress,
    required this.isAiRecommended,
    required this.icon,
  });
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isListening = false;

  // Active filters state
  List<String> _selectedCategories = [];
  String? _selectedDifficulty;
  String? _selectedStatus; // 'Belum Mulai', 'Sedang Berjalan', 'Selesai'
  bool _onlyAiRecommended = false;

  // Recent searches state
  List<String> _recentSearches = [
    'STEM Energi Air',
    'Asesmen Diagnostik',
    'Logika Matematika',
    'LSTM-DKT',
  ];

  // Trending searches state
  final List<String> _trendingSearches = const [
    'STEM Energi Terbarukan ⚡',
    'Asesmen Literasi Nasional 📝',
    'LSTM-DKT Model 🧠',
    'Kemampuan Numerasi Dasar 📊',
  ];

  final List<SearchItem> _database = const [
    SearchItem(
      id: 'lit-1',
      title: 'Membaca Dasar Kalimat',
      category: 'Literasi',
      difficulty: 'Mudah',
      estimatedMinutes: 15,
      progress: 1.0,
      isAiRecommended: false,
      icon: Icons.abc,
    ),
    SearchItem(
      id: 'lit-2',
      title: 'Analisis Argumentasi Paragraf',
      category: 'Literasi',
      difficulty: 'Sedang',
      estimatedMinutes: 25,
      progress: 0.45,
      isAiRecommended: true,
      icon: Icons.article_outlined,
    ),
    SearchItem(
      id: 'num-1',
      title: 'Logika Matematika Level 2',
      category: 'Numerasi',
      difficulty: 'Sedang',
      estimatedMinutes: 20,
      progress: 0.0,
      isAiRecommended: true,
      icon: Icons.psychology,
    ),
    SearchItem(
      id: 'num-2',
      title: 'HOTS Aljabar Linear',
      category: 'Numerasi',
      difficulty: 'Sulit',
      estimatedMinutes: 35,
      progress: 0.12,
      isAiRecommended: false,
      icon: Icons.calculate_outlined,
    ),
    SearchItem(
      id: 'stem-1',
      title: 'STEM: Energi Air Sekolah',
      category: 'STEM',
      difficulty: 'Sedang',
      estimatedMinutes: 30,
      progress: 0.8,
      isAiRecommended: true,
      icon: Icons.science_outlined,
    ),
    SearchItem(
      id: 'diag-1',
      title: 'Asesmen Awal Literasi',
      category: 'Asesmen Diagnostik',
      difficulty: 'Mudah',
      estimatedMinutes: 10,
      progress: 1.0,
      isAiRecommended: false,
      icon: Icons.assignment_outlined,
    ),
    SearchItem(
      id: 'adapt-1',
      title: 'LSTM-DKT Model Simulasi',
      category: 'Pembelajaran Adaptif',
      difficulty: 'Sulit',
      estimatedMinutes: 40,
      progress: 0.0,
      isAiRecommended: true,
      icon: Icons.hub_outlined,
    ),
    SearchItem(
      id: 'lat-1',
      title: 'Latihan Penalaran Kritis',
      category: 'Latihan',
      difficulty: 'Sedang',
      estimatedMinutes: 15,
      progress: 0.65,
      isAiRecommended: false,
      icon: Icons.fitness_center_outlined,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtered lists
  List<SearchItem> get _filteredResults {
    return _database.where((item) {
      final matchesQuery = item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategories.isEmpty || _selectedCategories.contains(item.category);
      final matchesDifficulty = _selectedDifficulty == null || item.difficulty == _selectedDifficulty;
      
      bool matchesStatus = true;
      if (_selectedStatus != null) {
        if (_selectedStatus == 'Selesai') {
          matchesStatus = item.progress >= 1.0;
        } else if (_selectedStatus == 'Sedang Berjalan') {
          matchesStatus = item.progress > 0.0 && item.progress < 1.0;
        } else if (_selectedStatus == 'Belum Mulai') {
          matchesStatus = item.progress == 0.0;
        }
      }

      final matchesAi = !_onlyAiRecommended || item.isAiRecommended;

      return matchesQuery && matchesCategory && matchesDifficulty && matchesStatus && matchesAi;
    }).toList();
  }

  List<SearchItem> get _aiRecommendedItems {
    return _database.where((item) => item.isAiRecommended).toList();
  }

  List<String> get _autoSuggestions {
    if (_searchQuery.isEmpty) return [];
    return _database
        .where((item) => item.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .map((item) => item.title)
        .take(4)
        .toList();
  }

  void _triggerVoiceSearch() {
    setState(() => _isListening = true);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Simulated voice transcription delay
            Timer(const Duration(milliseconds: 2500), () {
              if (mounted && _isListening) {
                Navigator.pop(context);
                setState(() {
                  _isListening = false;
                  _searchQuery = 'STEM: Energi Air Sekolah';
                  _searchController.text = _searchQuery;
                  if (!_recentSearches.contains(_searchQuery)) {
                    _recentSearches.insert(0, _searchQuery);
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mentranskripsikan suara: "STEM: Energi Air Sekolah"'),
                    backgroundColor: Colors.indigo,
                  ),
                );
              }
            });

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'LITERA-AI Asisten Suara',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Katakan materi, kategori, atau topik pembelajaran Anda...',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 36),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.indigo.shade50,
                        ),
                      ),
                      // Animated pulse ring (simulated by layout size)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.indigo.shade100,
                        ),
                      ),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.indigo,
                        child: IconButton(
                          icon: const Icon(Icons.mic, color: Colors.white, size: 24),
                          onPressed: () {
                            setState(() => _isListening = false);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Mendengarkan...',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      setState(() => _isListening = false);
    });
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.65,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filter Pembelajaran',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                          ),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                _selectedCategories.clear();
                                _selectedDifficulty = null;
                                _selectedStatus = null;
                                _onlyAiRecommended = false;
                              });
                            },
                            child: const Text('Reset Semua'),
                          ),
                        ],
                      ),
                      const Divider(height: 20),

                      // KATEGORI
                      const Text(
                        'Kategori Materi',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ['Literasi', 'Numerasi', 'STEM', 'Asesmen Diagnostik', 'Pembelajaran Adaptif', 'Latihan'].map((cat) {
                          final isSelected = _selectedCategories.contains(cat);
                          return FilterChip(
                            label: Text(cat),
                            selected: isSelected,
                            selectedColor: Colors.indigo,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            onSelected: (selected) {
                              setModalState(() {
                                if (selected) {
                                  _selectedCategories.add(cat);
                                } else {
                                  _selectedCategories.remove(cat);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // TINGKAT KESULITAN
                      const Text(
                        'Tingkat Kesulitan',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: ['Mudah', 'Sedang', 'Sulit'].map((diff) {
                          final isSelected = _selectedDifficulty == diff;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(diff),
                              selected: isSelected,
                              selectedColor: Colors.indigo,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              onSelected: (selected) {
                                setModalState(() {
                                  _selectedDifficulty = selected ? diff : null;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // STATUS PENYELESAIAN
                      const Text(
                        'Status Penyelesaian',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: ['Belum Mulai', 'Sedang Berjalan', 'Selesai'].map((status) {
                          final isSelected = _selectedStatus == status;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(status),
                              selected: isSelected,
                              selectedColor: Colors.indigo,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              onSelected: (selected) {
                                setModalState(() {
                                  _selectedStatus = selected ? status : null;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // REKOMENDASI AI ONLY
                      SwitchListTile(
                        title: const Text('Hanya Rekomendasi Algoritma AI (LSTM-DKT/1D-CNN)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        subtitle: const Text('Menampilkan materi pilihan terbaik hasil analisis diagnostik literasi Anda.', style: TextStyle(fontSize: 11)),
                        value: _onlyAiRecommended,
                        activeColor: Colors.indigo,
                        onChanged: (val) {
                          setModalState(() {
                            _onlyAiRecommended = val;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 28),

                      // ACTION BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {}); // Apply state changes locally to screen
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Terapkan Filter'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildResultCard(SearchItem item) {
    final accentColor = item.category == 'STEM'
        ? Colors.teal
        : (item.category == 'Numerasi' ? Colors.orange : Colors.indigo);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            // Ripple effect redirect to module
            context.push('/student/modules/${item.id}');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header line with category color
              Container(height: 4, color: accentColor),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Content type icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.icon, color: accentColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    // Body text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  item.category,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: accentColor.shade900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item.difficulty,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: item.difficulty == 'Sulit'
                                      ? Colors.red
                                      : (item.difficulty == 'Sedang' ? Colors.orange : Colors.green),
                                ),
                              ),
                              const Spacer(),
                              if (item.isAiRecommended)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.amber.shade300, width: 0.8),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.auto_awesome, color: Colors.amber, size: 10),
                                      SizedBox(width: 4),
                                      Text(
                                        'Prioritas AI',
                                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.amber),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Estimasi waktu: ${item.estimatedMinutes} menit',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: item.progress,
                                    minHeight: 6,
                                    backgroundColor: Colors.grey.shade100,
                                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${(item.progress * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiRecommendationPanel() {
    final items = _aiRecommendedItems;
    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
            SizedBox(width: 8),
            Text(
              'Direkomendasikan AI untuk Anda',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Jalur belajar adaptif personal berdasarkan model LSTM-DKT/1D-CNN.',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                width: 240,
                margin: const EdgeInsets.only(right: 12, bottom: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () => context.push('/student/modules/${item.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.category,
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.indigo),
                                ),
                              ),
                              Text(item.difficulty, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(Icons.schedule, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('${item.estimatedMinutes} menit', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              const Spacer(),
                              const Text('Mulai ➔', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.indigo)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredResults;
    final suggestions = _autoSuggestions;

    return AppScreen(
      title: 'Eksplorasi Pembelajaran',
      children: [
        // SEARCH & FILTER BAR ROW
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari materi, latihan, topik, atau asesmen...',
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
                        : IconButton(
                            icon: const Icon(Icons.mic, color: Colors.indigo),
                            onPressed: _triggerVoiceSearch,
                          ),
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
            ),
            const SizedBox(width: 8),
            // Filter option button
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200, width: 1.5),
              ),
              child: IconButton(
                icon: const Icon(Icons.tune, color: Colors.indigo),
                onPressed: _showFilterOptions,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ACTIVE CHIPS DISPLAY
        if (_selectedCategories.isNotEmpty || _selectedDifficulty != null || _selectedStatus != null || _onlyAiRecommended)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ..._selectedCategories.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Chip(
                    label: Text(cat),
                    deleteIconColor: Colors.indigo,
                    onDeleted: () => setState(() => _selectedCategories.remove(cat)),
                  ),
                )),
                if (_selectedDifficulty != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Chip(
                      label: Text('Kesulitan: $_selectedDifficulty'),
                      onDeleted: () => setState(() => _selectedDifficulty = null),
                    ),
                  ),
                if (_selectedStatus != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Chip(
                      label: Text('Status: $_selectedStatus'),
                      onDeleted: () => setState(() => _selectedStatus = null),
                    ),
                  ),
                if (_onlyAiRecommended)
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Chip(
                      label: const Text('Rekomendasi AI'),
                      onDeleted: () => setState(() => _onlyAiRecommended = false),
                    ),
                  ),
              ],
            ),
          ),

        // AUTO SUGGESTIONS DROP-DOWN LIST
        if (_searchQuery.isNotEmpty && suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: suggestions.map((suggestion) {
                return ListTile(
                  leading: const Icon(Icons.history_toggle_off, size: 18),
                  title: Text(suggestion, style: const TextStyle(fontSize: 13)),
                  trailing: const Icon(Icons.arrow_outward, size: 14),
                  onTap: () {
                    setState(() {
                      _searchQuery = suggestion;
                      _searchController.text = suggestion;
                      if (!_recentSearches.contains(suggestion)) {
                        _recentSearches.insert(0, suggestion);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),

        // SCREEN CONTENT DEPENDING ON SEARCH QUERY
        if (_searchQuery.isEmpty) ...[
          // RECENT SEARCHES
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pencarian Terbaru',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _recentSearches.clear();
                    });
                  },
                  child: const Text('Hapus Semua', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _recentSearches.map((keyword) {
                return Chip(
                  label: Text(keyword, style: const TextStyle(fontSize: 11)),
                  onDeleted: () {
                    setState(() {
                      _recentSearches.remove(keyword);
                    });
                  },
                  deleteIcon: const Icon(Icons.close, size: 14),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // TRENDING SEARCHES
          const Text(
            'Pencarian Populer (Trending)',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _trendingSearches.map((trending) {
              return ActionChip(
                label: Text(trending, style: const TextStyle(fontSize: 11)),
                onPressed: () {
                  setState(() {
                    // Extract keyword without emojis
                    final keyword = trending.replaceAll(RegExp(r'[\u2000-\u3000\u2700-\u27bf\u2600-\u26ff\ud83c\udc00-\ud83c\udfff\ud83d\udc00-\ud83d\udfff\ud83e\udc00-\ud83e\udfff]'), '').trim();
                    _searchQuery = keyword;
                    _searchController.text = keyword;
                    if (!_recentSearches.contains(keyword)) {
                      _recentSearches.insert(0, keyword);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // AI RECOMENDER PANEL
          _buildAiRecommendationPanel(),
        ] else ...[
          // SEARCH RESULTS PANEL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hasil Pencarian (${results.length})',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              if (results.isNotEmpty)
                const Row(
                  children: [
                    Icon(Icons.sort, size: 14, color: Colors.indigo),
                    SizedBox(width: 4),
                    Text('Relevansi AI', style: TextStyle(fontSize: 11, color: Colors.indigo, fontWeight: FontWeight.bold)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),

          // RESULTS LIST OR EMPTY STATE
          if (results.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.search_off_rounded, size: 64, color: Colors.indigo.shade400),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Materi Tidak Ditemukan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hasil pencarian "$_searchQuery" tidak ditemukan.\nCoba kueri lain atau pelajari rekomendasi AI adaptif berikut:',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Rekomendasi materi serupa untuk Anda:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._aiRecommendedItems.map((item) => _buildResultCard(item)),
                  ],
                ),
              ),
            )
          else
            ...results.map((item) => _buildResultCard(item)),
        ],
      ],
    );
  }
}
