import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:litera_ai_mobile/features/auth/application/auth_controller.dart';
import 'package:litera_ai_mobile/features/auth/domain/user_role.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  int _currentStep = 0;
  bool _loading = false;
  final ImagePicker _imagePicker = ImagePicker();

  // 1. INFORMASI PRIBADI STATE
  final _fullNameController = TextEditingController();
  final _nickNameController = TextEditingController();
  String _gender = 'Laki-laki';
  final _birthPlaceController = TextEditingController();
  DateTime _birthDate = DateTime(2014, 5, 20);
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController(text: 'Indonesia');
  final _provinceController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();
  String? _photoPath;

  // 2. JENJANG PENDIDIKAN STATE
  String _educationLevel = 'SD Kelas 5';
  String _major = 'Umum'; // Untuk SMA
  String _vocationalProgram = 'Rekayasa Perangkat Lunak (RPL)'; // Untuk SMK
  String _collegeStatus = 'Sarjana (S1)'; // Untuk Perguruan Tinggi
  int _collegeSemester = 1; // Untuk Perguruan Tinggi
  final _collegeMajorController = TextEditingController();
  final _collegeNameController = TextEditingController();
  final _nimController = TextEditingController();

  // 3. INFORMASI SEKOLAH/KAMPUS
  final _schoolNameController = TextEditingController();
  final _npsnController = TextEditingController();
  String _schoolStatus = 'Negeri';
  String _schoolAccreditation = 'A';

  // 4. INFORMASI AKADEMIK
  String _academicYear = '2025/2026';
  int _academicSemester = 1;
  String _curriculum = 'Kurikulum Merdeka';
  final _averageGradeController = TextEditingController(text: '85.0');
  final _achievementsController = TextEditingController();

  // 5, 6, 7, 8, 9, 10. MINAT & GAYA BELAJAR
  List<String> _selectedInterests = ['Matematika', 'Bahasa Indonesia', 'IPA'];
  List<String> _difficultSubjects = ['Fisika', 'Kimia'];
  List<String> _generalInterests = ['Teknologi', 'Sains', 'Coding'];
  List<String> _learningStyles = ['Visual', 'Membaca', 'Video'];
  List<String> _learningGoals = ['Meningkatkan nilai', 'Belajar Mandiri'];
  double _targetGrade = 90.0;
  double _studyHoursPerDay = 1.5;
  List<String> _studyDays = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];

  // 12, 13. PREFERENSI AI & JADWAL
  String _aiLanguage = 'Bahasa Indonesia';
  String _aiExplanationMode = 'Interaktif';
  String _aiDifficulty = 'Adaptif AI (Rekomendasi)';
  List<String> _aiMediaTypes = ['Teks', 'Infografis', 'Kuis'];
  String _studyTimeFavorite = 'Sore';
  String _studyDuration = '30 menit';

  // 14. NOTIFIKASI
  bool _notifyStudyReminder = true;
  bool _notifyTaskReminder = true;
  bool _notifyExamReminder = true;
  bool _notifyWeeklySummary = true;
  bool _notifyDailyMotivation = true;
  bool _notifyAiRecommendation = true;

  // 15. KEAMANAN
  bool _enable2FA = false;

  // 16. PRIVASI
  bool _agreePrivacyPolicy = true;
  bool _agreeTerms = true;
  bool _allowAiDataAnalysis = true;
  bool _allowPersonalization = true;

  // DYNAMIC OPTION LISTS
  final List<String> _genderOptions = const ['Laki-laki', 'Perempuan'];
  final List<String> _educationLevelOptions = const [
    'Kelompok Bermain (KB)',
    'Taman Kanak-Kanak A (TK A)',
    'Taman Kanak-Kanak B (TK B)',
    'SD Kelas 1', 'SD Kelas 2', 'SD Kelas 3',
    'SD Kelas 4', 'SD Kelas 5', 'SD Kelas 6',
    'SMP Kelas 7', 'SMP Kelas 8', 'SMP Kelas 9',
    'SMA Kelas 10', 'SMA Kelas 11', 'SMA Kelas 12',
    'SMK Kelas 10', 'SMK Kelas 11', 'SMK Kelas 12',
    'Perguruan Tinggi'
  ];
  final List<String> _majorOptions = const ['Umum', 'IPA', 'IPS', 'Bahasa'];
  final List<String> _vocationalOptions = const [
    'Rekayasa Perangkat Lunak (RPL)',
    'Teknik Komputer dan Jaringan (TKJ)',
    'Teknik Elektronika',
    'Desain Komunikasi Visual (DKV)',
    'Multimedia',
    'Akuntansi',
    'Farmasi'
  ];
  final List<String> _collegeStatusOptions = const [
    'Diploma (D1)', 'Diploma (D2)', 'Diploma (D3)', 'Diploma (D4)',
    'Sarjana (S1)', 'Magister (S2)', 'Doktor (S3)', 'Pendidikan Profesi'
  ];
  final List<String> _schoolStatusOptions = const ['Negeri', 'Swasta'];
  final List<String> _accreditationOptions = const ['A', 'B', 'C', 'Belum Terakreditasi'];
  final List<String> _curriculumOptions = const ['Kurikulum Merdeka', 'Kurikulum 2013', 'Kurikulum Kampus'];
  final List<String> _subjectOptions = const [
    'Membaca', 'Berhitung', 'Mengenal Huruf', 'Mengenal Warna',
    'Matematika', 'Bahasa Indonesia', 'IPA', 'IPS', 'PPKn', 'Bahasa Inggris',
    'Fisika', 'Kimia', 'Biologi', 'Ekonomi', 'Geografi', 'Sejarah', 'Sosiologi',
    'Informatika', 'Pemrograman', 'Statistik', 'Akuntansi'
  ];
  final List<String> _interestOptions = const [
    'Teknologi', 'Artificial Intelligence', 'Robotika', 'Sains', 'Matematika',
    'Bahasa', 'Bisnis', 'Ekonomi', 'Seni', 'Musik', 'Desain', 'Coding',
    'Public Speaking', 'Menulis', 'Membaca', 'Penelitian', 'Kewirausahaan', 'Olahraga'
  ];
  final List<String> _learningStyleOptions = const [
    'Visual', 'Audio', 'Kinestetik', 'Membaca', 'Video', 'Praktik', 'Diskusi', 'Project Based Learning'
  ];
  final List<String> _learningGoalOptions = const [
    'Meningkatkan nilai', 'Persiapan Ujian Sekolah', 'Persiapan ANBK', 'Persiapan SNBT',
    'Persiapan UTBK', 'Persiapan Olimpiade', 'Persiapan Kompetisi', 'Persiapan Kuliah',
    'Persiapan Dunia Kerja', 'Belajar Mandiri'
  ];
  final List<String> _studyDayOptions = const ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  final List<String> _aiLanguageOptions = const ['Bahasa Indonesia', 'English'];
  final List<String> _aiExplanationModeOptions = const ['Singkat', 'Detail', 'Interaktif'];
  final List<String> _aiDifficultyOptions = const ['Mudah', 'Sedang', 'Sulit', 'Adaptif AI (Rekomendasi)'];
  final List<String> _aiMediaTypeOptions = const ['Teks', 'Video', 'Audio', 'Infografis', 'Simulasi', 'Kuis'];
  final List<String> _studyTimeOptions = const ['Pagi', 'Siang', 'Sore', 'Malam'];
  final List<String> _studyDurationOptions = const ['15 menit', '30 menit', '45 menit', '60 menit', '90 menit', '120 menit'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authControllerProvider);
      if (authState.fullName != null && authState.fullName!.isNotEmpty) {
        _fullNameController.text = authState.fullName!;
      }
      if (authState.photoPath != null) {
        setState(() {
          _photoPath = authState.photoPath;
        });
      }
      if (authState.schoolName != null) {
        _schoolNameController.text = authState.schoolName!;
      }
      if (authState.educationLevel != null) {
        setState(() {
          _educationLevel = authState.educationLevel!;
        });
      }
      if (authState.gender != null) {
        setState(() {
          _gender = authState.gender!;
        });
      }
      if (authState.email != null) {
        _emailController.text = authState.email!;
      }
      _bioController.text = 'Saya seorang pelajar yang berdedikasi tinggi dan ingin mendalami literasi adaptif bersama LITERA-AI.';
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nickNameController.dispose();
    _birthPlaceController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _addressController.dispose();
    _collegeMajorController.dispose();
    _collegeNameController.dispose();
    _nimController.dispose();
    _schoolNameController.dispose();
    _npsnController.dispose();
    _averageGradeController.dispose();
    _achievementsController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _photoPath = pickedFile.path;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil dipilih!'),
            backgroundColor: Colors.indigo,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil gambar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Ambil via Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_photoPath != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Hapus Foto Profil', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _photoPath = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Foto profil dihapus.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepIndicator() {
    final titles = ['Pribadi', 'Akademik', 'Minat', 'AI & Privasi'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50.withOpacity(0.4),
        border: Border(
          bottom: BorderSide(color: Colors.indigo.shade50, width: 1.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(4, (index) {
          final isCompleted = _currentStep > index;
          final isActive = _currentStep == index;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isCompleted || isActive
                              ? const LinearGradient(
                                  colors: [Colors.indigo, Colors.purple],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: !isCompleted && !isActive ? Colors.grey.shade300 : null,
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: Colors.indigo.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: isCompleted || isActive ? Colors.white : Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        titles[index],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          color: isActive ? Colors.indigo.shade900 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < 3)
                  Container(
                    width: 30,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Divider(
                      color: isCompleted ? Colors.indigo : Colors.grey.shade300,
                      thickness: 2,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      case 3:
        return _buildStep4();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informasi Pribadi & Kontak',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
        ),
        const SizedBox(height: 16),
        Center(
          child: InkWell(
            onTap: _showPhotoOptions,
            borderRadius: BorderRadius.circular(50),
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.indigo.shade200, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.indigo.shade50,
                    backgroundImage: _photoPath != null ? FileImage(File(_photoPath!)) : null,
                    child: _photoPath == null
                        ? Icon(Icons.person, size: 54, color: Colors.indigo.shade800)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.indigo,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _fullNameController,
          label: 'Nama Lengkap',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _nickNameController,
          label: 'Nama Panggilan',
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 12),
        _buildDropdown(
          label: 'Jenis Kelamin',
          value: _gender,
          options: _genderOptions,
          icon: Icons.wc_outlined,
          onChanged: (val) => setState(() => _gender = val!),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _birthPlaceController,
                label: 'Tempat Lahir',
                icon: Icons.place_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _birthDate,
                    firstDate: DateTime(1980),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _birthDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Lahir',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    '${_birthDate.day}-${_birthDate.month}-${_birthDate.year}',
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _phoneController,
          label: 'Nomor HP',
          icon: Icons.phone_android_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _bioController,
          label: 'Biodata Singkat',
          icon: Icons.info_outline,
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _countryController,
          label: 'Negara',
          icon: Icons.public_outlined,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _provinceController,
                label: 'Provinsi',
                icon: Icons.map_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _cityController,
                label: 'Kota/Kabupaten',
                icon: Icons.location_city_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _districtController,
          label: 'Kecamatan',
          icon: Icons.explore_outlined,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _addressController,
          label: 'Alamat Lengkap (Opsional)',
          icon: Icons.home_outlined,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenjang Pendidikan & Sekolah',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Jenjang Pendidikan',
          value: _educationLevel,
          options: _educationLevelOptions,
          icon: Icons.school_outlined,
          onChanged: (val) => setState(() => _educationLevel = val!),
        ),
        const SizedBox(height: 12),

        // DYNAMIC FIELDS
        if (_educationLevel.startsWith('SMA')) ...[
          _buildDropdown(
            label: 'Jurusan',
            value: _major,
            options: _majorOptions,
            icon: Icons.align_horizontal_left_outlined,
            onChanged: (val) => setState(() => _major = val!),
          ),
          const SizedBox(height: 12),
        ] else if (_educationLevel.startsWith('SMK')) ...[
          _buildDropdown(
            label: 'Program Keahlian',
            value: _vocationalProgram,
            options: _vocationalOptions,
            icon: Icons.settings_suggest_outlined,
            onChanged: (val) => setState(() => _vocationalProgram = val!),
          ),
          const SizedBox(height: 12),
        ] else if (_educationLevel == 'Perguruan Tinggi') ...[
          _buildDropdown(
            label: 'Status Pendidikan',
            value: _collegeStatus,
            options: _collegeStatusOptions,
            icon: Icons.military_tech_outlined,
            onChanged: (val) => setState(() => _collegeStatus = val!),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _collegeNameController,
            label: 'Nama Perguruan Tinggi',
            icon: Icons.account_balance_outlined,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _collegeMajorController,
                  label: 'Program Studi',
                  icon: Icons.menu_book_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _collegeSemester,
                  decoration: const InputDecoration(
                    labelText: 'Semester',
                    prefixIcon: Icon(Icons.numbers_outlined),
                  ),
                  items: List.generate(
                    14,
                    (i) => DropdownMenuItem(value: i + 1, child: Text('Smstr ${i + 1}')),
                  ),
                  onChanged: (val) => setState(() => _collegeSemester = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _nimController,
            label: 'NIM (Opsional)',
            icon: Icons.card_membership_outlined,
          ),
          const SizedBox(height: 12),
        ],

        _buildTextField(
          controller: _schoolNameController,
          label: _educationLevel == 'Perguruan Tinggi' ? 'Nama Fakultas/Kampus Utama' : 'Nama Sekolah',
          icon: Icons.apartment_outlined,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                label: 'Status Lembaga',
                value: _schoolStatus,
                options: _schoolStatusOptions,
                icon: Icons.business_outlined,
                onChanged: (val) => setState(() => _schoolStatus = val!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                label: 'Akreditasi',
                value: _schoolAccreditation,
                options: _accreditationOptions,
                icon: Icons.star_border_outlined,
                onChanged: (val) => setState(() => _schoolAccreditation = val!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _npsnController,
          label: 'NPSN (Opsional)',
          icon: Icons.pin_outlined,
        ),
        const SizedBox(height: 20),
        const Text(
          'Informasi Akademik',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.indigo),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                label: 'Kurikulum',
                value: _curriculum,
                options: _curriculumOptions,
                icon: Icons.architecture_outlined,
                onChanged: (val) => setState(() => _curriculum = val!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _averageGradeController,
                label: 'Nilai Rata-Rata',
                icon: Icons.analytics_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _achievementsController,
          label: 'Prestasi Akademik (Opsional)',
          icon: Icons.emoji_events_outlined,
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Minat, Target & Gaya Belajar',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
        ),
        const SizedBox(height: 16),
        const Text(
          'Mata Pelajaran yang Diminati:',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        _buildChoiceChips(
          options: _subjectOptions,
          selectedList: _selectedInterests,
          onChanged: (newList) => setState(() => _selectedInterests = newList),
        ),
        const SizedBox(height: 16),
        const Text(
          'Mata Pelajaran yang Dirasa Sulit:',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        _buildChoiceChips(
          options: _subjectOptions,
          selectedList: _difficultSubjects,
          onChanged: (newList) => setState(() => _difficultSubjects = newList),
        ),
        const SizedBox(height: 16),
        const Text(
          'Minat Pembelajaran Umum:',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        _buildChoiceChips(
          options: _interestOptions,
          selectedList: _generalInterests,
          onChanged: (newList) => setState(() => _generalInterests = newList),
        ),
        const SizedBox(height: 16),
        const Text(
          'Gaya Belajar Terfavorit:',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        _buildChoiceChips(
          options: _learningStyleOptions,
          selectedList: _learningStyles,
          onChanged: (newList) => setState(() => _learningStyles = newList),
        ),
        const SizedBox(height: 16),
        const Text(
          'Tujuan Belajar Utama:',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        _buildChoiceChips(
          options: _learningGoalOptions,
          selectedList: _learningGoals,
          onChanged: (newList) => setState(() => _learningGoals = newList),
        ),
        const SizedBox(height: 20),
        const Text(
          'Target & Jadwal Mingguan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.indigo),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Target Nilai: ${_targetGrade.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Slider(
                    value: _targetGrade,
                    min: 50,
                    max: 100,
                    activeColor: Colors.indigo,
                    inactiveColor: Colors.indigo.shade100,
                    divisions: 10,
                    label: _targetGrade.round().toString(),
                    onChanged: (val) => setState(() => _targetGrade = val),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Belajar/Hari: $_studyHoursPerDay Jam', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Slider(
                    value: _studyHoursPerDay,
                    min: 0.5,
                    max: 6.0,
                    activeColor: Colors.indigo,
                    inactiveColor: Colors.indigo.shade100,
                    divisions: 11,
                    label: '$_studyHoursPerDay Jam',
                    onChanged: (val) => setState(() => _studyHoursPerDay = val),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Hari Belajar Mingguan:',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        _buildChoiceChips(
          options: _studyDayOptions,
          selectedList: _studyDays,
          onChanged: (newList) => setState(() => _studyDays = newList),
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferensi AI & Privasi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Bahasa Pengantar AI',
          value: _aiLanguage,
          options: _aiLanguageOptions,
          icon: Icons.g_translate_outlined,
          onChanged: (val) => setState(() => _aiLanguage = val!),
        ),
        const SizedBox(height: 12),
        _buildDropdown(
          label: 'Mode Penjelasan AI',
          value: _aiExplanationMode,
          options: _aiExplanationModeOptions,
          icon: Icons.rate_review_outlined,
          onChanged: (val) => setState(() => _aiExplanationMode = val!),
        ),
        const SizedBox(height: 12),
        _buildDropdown(
          label: 'Tingkat Kesulitan Soal',
          value: _aiDifficulty,
          options: _aiDifficultyOptions,
          icon: Icons.bolt_outlined,
          onChanged: (val) => setState(() => _aiDifficulty = val!),
        ),
        const SizedBox(height: 12),
        const Text(
          'Media Pembelajaran Favorit:',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        _buildChoiceChips(
          options: _aiMediaTypeOptions,
          selectedList: _aiMediaTypes,
          onChanged: (newList) => setState(() => _aiMediaTypes = newList),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                label: 'Waktu Belajar',
                value: _studyTimeFavorite,
                options: _studyTimeOptions,
                icon: Icons.wb_twilight_outlined,
                onChanged: (val) => setState(() => _studyTimeFavorite = val!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                label: 'Durasi Sesi',
                value: _studyDuration,
                options: _studyDurationOptions,
                icon: Icons.schedule_outlined,
                onChanged: (val) => setState(() => _studyDuration = val!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        const Text(
          'Pengaturan Notifikasi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.indigo),
        ),
        const SizedBox(height: 8),
        _buildSwitchTile('Pengingat Belajar Harian', _notifyStudyReminder, (val) => setState(() => _notifyStudyReminder = val)),
        _buildSwitchTile('Pengingat Tugas', _notifyTaskReminder, (val) => setState(() => _notifyTaskReminder = val)),
        _buildSwitchTile('Pengingat Ujian', _notifyExamReminder, (val) => setState(() => _notifyExamReminder = val)),
        _buildSwitchTile('Ringkasan Belajar Mingguan', _notifyWeeklySummary, (val) => setState(() => _notifyWeeklySummary = val)),
        _buildSwitchTile('Rekomendasi Materi AI', _notifyAiRecommendation, (val) => setState(() => _notifyAiRecommendation = val)),
        const SizedBox(height: 20),

        const Text(
          'Keamanan & Privasi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.indigo),
        ),
        const SizedBox(height: 8),
        _buildSwitchTile('Autentikasi Dua Faktor (2FA)', _enable2FA, (val) => setState(() => _enable2FA = val)),
        _buildSwitchTile('Izin analisis data pembelajaran oleh AI', _allowAiDataAnalysis, (val) => setState(() => _allowAiDataAnalysis = val)),
        _buildSwitchTile('Izin personalisasi materi oleh AI', _allowPersonalization, (val) => setState(() => _allowPersonalization = val)),
        const SizedBox(height: 8),
        
        CheckboxListTile(
          value: _agreeTerms,
          title: const Text('Saya menyetujui Syarat & Ketentuan aplikasi.', style: TextStyle(fontSize: 12)),
          onChanged: (val) => setState(() => _agreeTerms = val ?? false),
          activeColor: Colors.indigo,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          value: _agreePrivacyPolicy,
          title: const Text('Saya menyetujui Kebijakan Privasi data.', style: TextStyle(fontSize: 12)),
          onChanged: (val) => setState(() => _agreePrivacyPolicy = val ?? false),
          activeColor: Colors.indigo,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Profil Komprehensif AI'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo.shade900,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Card(
                  elevation: 6,
                  shadowColor: Colors.black12.withOpacity(0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStepContent(),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            if (_currentStep > 0)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _loading ? null : () => setState(() => _currentStep -= 1),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    side: BorderSide(color: Colors.indigo.shade200),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text('Kembali'),
                                ),
                              ),
                            if (_currentStep > 0) const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _loading ? null : () {
                                  if (_currentStep < 3) {
                                    setState(() => _currentStep += 1);
                                  } else {
                                    _submit();
                                  }
                                },
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  backgroundColor: Colors.indigo,
                                ),
                                icon: _loading && _currentStep == 3
                                    ? const SizedBox.square(
                                        dimension: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Icon(_currentStep == 3 ? Icons.check : Icons.arrow_forward),
                                label: Text(_currentStep == 3 ? 'Simpan & Selesai' : 'Lanjutkan'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET BUILDER HELPERS

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> options,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: options.contains(value) ? value : options.first,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      items: options.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildChoiceChips({
    required List<String> options,
    required List<String> selectedList,
    required ValueChanged<List<String>> onChanged,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selectedList.contains(option);
        return FilterChip(
          label: Text(option),
          labelStyle: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black87,
          ),
          selected: isSelected,
          selectedColor: Colors.indigo,
          checkmarkColor: Colors.white,
          backgroundColor: Colors.grey.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: isSelected ? Colors.indigo : Colors.grey.shade300),
          ),
          onSelected: (selected) {
            final newList = List<String>.from(selectedList);
            if (selected) {
              newList.add(option);
            } else {
              newList.remove(option);
            }
            onChanged(newList);
          },
        );
      }).toList(),
    );
  }

  Widget _buildSwitchTile(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(fontSize: 13)),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeColor: Colors.indigo,
    );
  }

  Future<void> _submit() async {
    if (!_agreeTerms || !_agreePrivacyPolicy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus menyetujui Syarat, Ketentuan, dan Kebijakan Privasi.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(authControllerProvider.notifier).completeProfile(
            fullName: _fullNameController.text.trim(),
            photoPath: _photoPath,
            schoolName: _schoolNameController.text.trim(),
            educationLevel: _educationLevel,
            gender: _gender,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil komprehensif berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/student'); // Redirect to dashboard
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil gagal disimpan. Coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
