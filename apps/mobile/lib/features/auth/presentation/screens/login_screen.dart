import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:litera_ai_mobile/app/router/route_names.dart';
import 'package:litera_ai_mobile/features/auth/application/auth_controller.dart';
import 'package:litera_ai_mobile/features/auth/domain/user_role.dart';

enum AuthScreenState {
  roleSelection,
  loginSiswa,
  loginGuru,
  loginOrangTua,
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  AuthScreenState _currentScreen = AuthScreenState.roleSelection;
  UserRole _role = UserRole.student;
  bool _loading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _rememberMe = false;
  String _language = 'ID'; // ID or EN
  bool _isDark = false;
  bool _isOnline = true; // Connection status mock

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _changeScreen(AuthScreenState screen, UserRole role, String defaultEmail) {
    setState(() {
      _currentScreen = screen;
      _role = role;
      _emailController.text = defaultEmail;
      _passwordController.text = 'Password123!';
      _errorMessage = null;
    });
    // Haptic feedback trigger
    HapticFeedback.mediumImpact();
  }

  void _goBack() {
    setState(() {
      _currentScreen = AuthScreenState.roleSelection;
      _errorMessage = null;
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            role: _role,
          );
    } on SocketException {
      setState(() => _errorMessage = 'Koneksi internet terputus. Silakan periksa jaringan Anda.');
    } on TimeoutException {
      setState(() => _errorMessage = 'Server tidak tersedia. Silakan coba sesaat lagi.');
    } catch (e) {
      setState(() => _errorMessage = 'Identitas atau sandi salah. Coba lagi.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _handleOAuthLogin(String provider) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).loginWithGoogle(role: _role);
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _handleForgotPassword() {
    showDialog<void>(
      context: context,
      builder: (context) {
        final emailCtrl = TextEditingController(text: _emailController.text);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            _language == 'ID' ? 'Lupa Password?' : 'Forgot Password?',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _language == 'ID' 
                    ? 'Masukkan alamat email Anda untuk menerima tautan pemulihan sandi.' 
                    : 'Enter your email address to receive password recovery link.',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: _language == 'ID' ? 'Email Pemulihan' : 'Recovery Email',
                  prefixIcon: const Icon(Icons.mail_outline),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_language == 'ID' ? 'Batal' : 'Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _language == 'ID'
                          ? 'Tautan pemulihan telah dikirim ke ${emailCtrl.text}'
                          : 'Recovery link has been sent to ${emailCtrl.text}',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(_language == 'ID' ? 'Kirim' : 'Send'),
            ),
          ],
        );
      },
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _language == 'ID' ? 'Identitas tidak boleh kosong' : 'Identity cannot be empty';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return _language == 'ID' ? 'Password tidak boleh kosong' : 'Password cannot be empty';
    }
    if (value.length < 8) {
      return _language == 'ID' ? 'Password minimal 8 karakter' : 'Password must be at least 8 characters';
    }
    return null;
  }

  Widget _buildIllustration(Color ambientColor) {
    return Container(
      height: 120,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Glow ring
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  ambientColor.withOpacity(_isDark ? 0.10 : 0.15),
                  ambientColor.withOpacity(0.0),
                ],
              ),
            ),
          ),
          // Inner White Circle with Drop Shadow
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.psychology,
                  size: 24,
                  color: ambientColor,
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.menu_book,
                  size: 20,
                  color: ambientColor.withOpacity(0.85),
                ),
              ],
            ),
          ),
          // Sparks
          Positioned(
            left: 20,
            top: 20,
            child: Icon(Icons.auto_awesome, size: 10, color: Colors.amber[400]),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: Icon(Icons.star_rounded, size: 8, color: Colors.amber[300]),
          ),
        ],
      ),
    );
  }

  // Language & Theme bar helper
  Widget _buildGlobalActionHeader() {
    return Positioned(
      top: 10,
      right: 16,
      left: 16,
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Connection indicator
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isOnline ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isOnline 
                      ? (_language == 'ID' ? 'Terhubung' : 'Connected')
                      : (_language == 'ID' ? 'Offline' : 'Offline'),
                  style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.bold),
                ),
              ],
            ),
            // Actions
            Row(
              children: [
                // Theme Toggle
                IconButton(
                  icon: Icon(_isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, size: 20),
                  onPressed: () {
                    setState(() => _isDark = !_isDark);
                    HapticFeedback.lightImpact();
                  },
                ),
                // Language Toggle
                TextButton(
                  onPressed: () {
                    setState(() => _language = _language == 'ID' ? 'EN' : 'ID');
                    HapticFeedback.lightImpact();
                  },
                  child: Text(
                    _language,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
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

  // Common footer helper
  Widget _buildFooter(Color linkColor) {
    final isIndo = _language == 'ID';

    return Column(
      children: [
        const SizedBox(height: 16),
        // Row 1: Privacy Policy • Terms & Conditions • Help Center
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    title: Text(isIndo ? 'Kebijakan Privasi' : 'Privacy Policy', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                    content: Text(
                      isIndo
                          ? 'LITERA-AI berkomitmen untuk menjaga keamanan data pembelajaran Anda. Data evaluasi Anda hanya digunakan oleh sistem AI untuk mempersonalisasi materi belajar secara adaptif.'
                          : 'LITERA-AI is committed to maintaining the security of your learning data. Your evaluation data is only used by the AI system to personalize learning materials adaptively.',
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: Text(isIndo ? 'Tutup' : 'Close')),
                    ],
                  ),
                );
              },
              child: Text(
                isIndo ? 'Kebijakan Privasi' : 'Privacy Policy',
                style: TextStyle(
                  fontSize: 10,
                  color: _isDark ? Colors.grey[400] : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('•', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
            ),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    title: Text(isIndo ? 'Syarat & Ketentuan' : 'Terms & Conditions', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                    content: Text(
                      isIndo
                          ? 'Dengan menggunakan LITERA-AI, Anda menyetujui analisis progres akademik adaptif guna mendapatkan rekomendasi belajar berstandar kurikulum.'
                          : 'By using LITERA-AI, you agree to adaptive academic progress analysis to obtain curriculum-standardized learning recommendations.',
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: Text(isIndo ? 'Tutup' : 'Close')),
                    ],
                  ),
                );
              },
              child: Text(
                isIndo ? 'Syarat & Ketentuan' : 'Terms & Conditions',
                style: TextStyle(
                  fontSize: 10,
                  color: _isDark ? Colors.grey[400] : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('•', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
            ),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    title: Text(isIndo ? 'Pusat Bantuan' : 'Help Center', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                    content: Text(
                      isIndo
                          ? 'Butuh bantuan sebelum login?\n\nHubungi tim asisten LITERA-AI via email di support@litera-ai.id atau silakan masuk menggunakan salah satu email uji coba demo untuk menjelajahi aplikasi.'
                          : 'Need help before logging in?\n\nContact the LITERA-AI assistant team via email at support@litera-ai.id or please sign in using one of the demo trial emails to explore the app.',
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: Text(isIndo ? 'Tutup' : 'Close')),
                    ],
                  ),
                );
              },
              child: Text(
                isIndo ? 'Pusat Bantuan' : 'Help Center',
                style: TextStyle(
                  fontSize: 10,
                  color: linkColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Glassmorphic / clean metadata card for credits
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          decoration: BoxDecoration(
            color: _isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Powered by Team UNITECH • Universitas Riau',
                style: TextStyle(
                  fontSize: 9.5,
                  color: _isDark ? Colors.grey[300] : Colors.grey[800],
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isIndo
                    ? 'Ketua Tim: Muhammad Lutfi Muzaki'
                    : 'Project Leader: Muhammad Lutfi Muzaki',
                style: TextStyle(
                  fontSize: 8.5,
                  color: _isDark ? Colors.grey[300] : Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isIndo
                    ? 'Anggota: Suci Aulia Sya\'ban • M. Rafli Maulana • Murni Syakira'
                    : 'Members: Suci Aulia Sya\'ban • M. Rafli Maulana • Murni Syakira',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8.5,
                  color: _isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isIndo
                    ? 'Dosen Pendamping: Zulhafizh, S.Pd., M.Pd'
                    : 'Academic Supervisor: Zulhafizh, S.Pd., M.Pd',
                style: TextStyle(
                  fontSize: 8.5,
                  color: _isDark ? Colors.grey[400] : Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Row 5: © 2026 LITERA-AI • Version v2.2.26
        Text(
          isIndo ? '© 2026 LITERA-AI • Versi v2.2.26' : '© 2026 LITERA-AI • Version v2.2.26',
          style: TextStyle(
            fontSize: 9,
            color: _isDark ? Colors.grey[500] : Colors.grey[500],
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentScreen == AuthScreenState.roleSelection,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goBack();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Switch current visual body
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.08, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _buildCurrentScreenBody(),
            ),
            _buildGlobalActionHeader(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScreenBody() {
    switch (_currentScreen) {
      case AuthScreenState.roleSelection:
        return _buildRoleSelectionView();
      case AuthScreenState.loginSiswa:
        return _buildLoginSiswaView();
      case AuthScreenState.loginGuru:
        return _buildLoginGuruView();
      case AuthScreenState.loginOrangTua:
        return _buildLoginOrangTuaView();
    }
  }

  // ==========================================
  // 1. ROLE SELECTION VIEW
  // ==========================================
  Widget _buildRoleSelectionView() {
    return Container(
      key: const ValueKey('roleSelection'),
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isDark
              ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
              : [const Color(0xFFEFF6FF), const Color(0xFFF8FAFC)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 36),
              // App Logo Stack
              Center(
                child: SvgPicture.asset(
                  'assets/images/logo.svg',
                  width: 56,
                  height: 56,
                  placeholderBuilder: (context) => const Icon(
                    Icons.auto_stories,
                    size: 50,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Litera ',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const TextSpan(
                        text: 'AI',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  _language == 'ID' 
                      ? 'Literacy Intelligent Assistant'
                      : 'Literacy Intelligent Assistant',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 32),
              if (isBelowAndroid10()) ...[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.shade200, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _language == 'ID'
                              ? 'Android < 10 Terdeteksi. LITERA-AI merekomendasikan Android 10 ke atas agar aplikasi berjalan lancar.'
                              : 'Android < 10 Detected. LITERA-AI recommends Android 10 and above to run smoothly.',
                          style: TextStyle(fontSize: 11, color: Colors.amber.shade900, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Center(
                child: Text(
                  _language == 'ID' ? 'Pilih Peran Anda' : 'Choose Your Role',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: _isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Role Card: Siswa
              _buildRoleCard(
                title: _language == 'ID' ? 'Siswa' : 'Student',
                subtitle: _language == 'ID' ? 'Belajar seru berbasis AI' : 'Fun AI-driven learning',
                icon: Icons.school_outlined,
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
                ),
                onTap: () => _changeScreen(AuthScreenState.loginSiswa, UserRole.student, 'siswa@litera.ai'),
              ),
              const SizedBox(height: 16),

              // Role Card: Guru
              _buildRoleCard(
                title: _language == 'ID' ? 'Guru' : 'Teacher',
                subtitle: _language == 'ID' ? 'Kelola kelas & analytics AI' : 'Manage class & AI analytics',
                icon: Icons.co_present_outlined,
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF059669)],
                ),
                onTap: () => _changeScreen(AuthScreenState.loginGuru, UserRole.teacher, 'guru@litera.ai'),
              ),
              const SizedBox(height: 16),

              // Role Card: Orang Tua
              _buildRoleCard(
                title: _language == 'ID' ? 'Orang Tua' : 'Parent',
                subtitle: _language == 'ID' ? 'Pantau progres belajar anak' : 'Monitor child learning progress',
                icon: Icons.family_restroom_outlined,
                gradient: const LinearGradient(
                  colors: [Color(0xFF16A34A), Color(0xFFFB923C)],
                ),
                onTap: () => _changeScreen(AuthScreenState.loginOrangTua, UserRole.student, 'orangtua@litera.ai'),
              ),
              const SizedBox(height: 24),
              _buildFooter(const Color(0xFF2563EB)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 2. LOGIN SISWA VIEW
  // ==========================================
  Widget _buildLoginSiswaView() {
    final primaryColor = const Color(0xFF2563EB);
    return Container(
      key: const ValueKey('loginSiswa'),
      width: double.infinity,
      height: double.infinity,
      color: _isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      child: Stack(
        children: [
          // Background visual elements
          Positioned(
            left: -40,
            bottom: -40,
            child: const GraduationIllustration(),
          ),
          Positioned(
            top: 70,
            right: 24,
            child: CustomPaint(
              size: const Size(60, 60),
              painter: DotGridPainter(),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    IconButton(
                      alignment: Alignment.centerLeft,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: _goBack,
                    ),
                    const SizedBox(height: 8),
                    // Visual Header Vibe: Friendly & Fun
                    _buildIllustration(_role == UserRole.student ? primaryColor : const Color(0xFF06B6D4)),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        _language == 'ID' ? 'Halo 👋' : 'Hello 👋',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: _isDark ? Colors.white : const Color(0xFF0F172A)),
                      ),
                    ),
                    Center(
                      child: Text(
                        _language == 'ID' ? 'Siap belajar hari ini?' : 'Ready to learn today?',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Card wrapper
                    _buildFormCardWrapper(
                      primaryColor: primaryColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTextField(
                            controller: _emailController,
                            label: _language == 'ID' ? 'Email, NISN, atau Username' : 'Email, NISN, or Username',
                            hint: 'Masukkan email atau NISN Anda',
                            icon: Icons.person_outline,
                            primaryColor: primaryColor,
                          ),
                          const SizedBox(height: 16),
                          _buildPasswordField(primaryColor),
                          const SizedBox(height: 8),
                          _buildForgotPasswordLink(primaryColor),
                          const SizedBox(height: 12),
                          _buildSubmitButton(primaryColor),
                          const SizedBox(height: 20),
                          _buildOAuthDivider(),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildOAuthButton(
                                  label: 'Google',
                                  logo: 'assets/images/google_logo.svg',
                                  onTap: () => _handleOAuthLogin('Google'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildOAuthButton(
                                  label: 'Microsoft',
                                  logo: 'assets/images/microsoft_logo.svg',
                                  onTap: () => _handleOAuthLogin('Microsoft'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Guest Mode Link
                          Center(
                            child: InkWell(
                              onTap: () => context.go(RouteNames.studentDashboard),
                              child: Text(
                                _language == 'ID' ? 'Masuk sebagai Tamu (Guest Mode)' : 'Login as Guest',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildRegisterLink(primaryColor),
                        ],
                      ),
                    ),
                    _buildFooter(primaryColor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. LOGIN GURU VIEW
  // ==========================================
  Widget _buildLoginGuruView() {
    final primaryColor = const Color(0xFF1E3A8A); // Navy Blue
    return Container(
      key: const ValueKey('loginGuru'),
      width: double.infinity,
      height: double.infinity,
      color: _isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      child: Stack(
        children: [
          // Background graphic elements: Analyst/Chart elements
          Positioned(
            right: 20,
            top: 80,
            child: Opacity(
              opacity: 0.05,
              child: Icon(Icons.analytics_outlined, size: 160, color: primaryColor),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    IconButton(
                      alignment: Alignment.centerLeft,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: _goBack,
                    ),
                    const SizedBox(height: 12),
                    // Centered chart vector icon header
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.assessment_outlined, size: 48, color: primaryColor),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        _language == 'ID' ? 'Selamat Datang' : 'Welcome',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _isDark ? Colors.white : const Color(0xFF1E3A8A)),
                      ),
                    ),
                    Center(
                      child: Text(
                        _language == 'ID' ? 'Kelola pembelajaran dengan AI.' : 'Manage classroom with AI.',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Card Form Wrapper
                    _buildFormCardWrapper(
                      primaryColor: primaryColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTextField(
                            controller: _emailController,
                            label: _language == 'ID' ? 'Email, NIP, atau Username' : 'Email, NIP, or Username',
                            hint: 'Masukkan email atau NIP Anda',
                            icon: Icons.badge_outlined,
                            primaryColor: primaryColor,
                          ),
                          const SizedBox(height: 16),
                          _buildPasswordField(primaryColor),
                          const SizedBox(height: 10),
                          // Remember me check box
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    activeColor: primaryColor,
                                    onChanged: (val) {
                                      setState(() => _rememberMe = val ?? false);
                                    },
                                  ),
                                  Text(
                                    _language == 'ID' ? 'Ingat Saya' : 'Remember Me',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              _buildForgotPasswordLink(primaryColor),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildSubmitButton(primaryColor),
                          const SizedBox(height: 20),
                          _buildOAuthDivider(),
                          const SizedBox(height: 16),
                          // Microsoft SSO & Google Workspace
                          Row(
                            children: [
                              Expanded(
                                child: _buildOAuthButton(
                                  label: 'Google Workspace',
                                  logo: 'assets/images/google_logo.svg',
                                  onTap: () => _handleOAuthLogin('Google'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildOAuthButton(
                                  label: 'Microsoft',
                                  logo: 'assets/images/microsoft_logo.svg',
                                  onTap: () => _handleOAuthLogin('Microsoft'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // SSO Sekolah Link
                          Center(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              ),
                              icon: const Icon(Icons.lan_outlined, size: 18),
                              label: Text(
                                _language == 'ID' ? 'SSO Sekolah' : 'School SSO',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildRegisterLink(primaryColor),
                        ],
                      ),
                    ),
                    _buildFooter(primaryColor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. LOGIN ORANG TUA VIEW
  // ==========================================
  Widget _buildLoginOrangTuaView() {
    final primaryColor = const Color(0xFF16A34A); // Green
    return Container(
      key: const ValueKey('loginOrangTua'),
      width: double.infinity,
      height: double.infinity,
      color: _isDark ? const Color(0xFF0F172A) : const Color(0xFFF0FDF4),
      child: Stack(
        children: [
          // Background organic leafy elements
          Positioned(
            left: -30,
            top: 80,
            child: Opacity(
              opacity: 0.1,
              child: Icon(Icons.nature_outlined, size: 140, color: primaryColor),
            ),
          ),
          Positioned(
            right: -20,
            bottom: 40,
            child: Opacity(
              opacity: 0.08,
              child: Icon(Icons.family_restroom, size: 200, color: primaryColor),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    IconButton(
                      alignment: Alignment.centerLeft,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: _goBack,
                    ),
                    const SizedBox(height: 12),
                    // Centered warm logo header
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.family_restroom, size: 48, color: primaryColor),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        _language == 'ID' ? 'Selamat Datang' : 'Welcome',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _isDark ? Colors.white : const Color(0xFF16A34A)),
                      ),
                    ),
                    Center(
                      child: Text(
                        _language == 'ID' ? 'Pantau perkembangan belajar anak.' : 'Monitor child learning progress.',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Card Form Wrapper
                    _buildFormCardWrapper(
                      primaryColor: primaryColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTextField(
                            controller: _emailController,
                            label: _language == 'ID' ? 'Email atau Nomor HP' : 'Email or Phone Number',
                            hint: 'Masukkan email atau nomor HP',
                            icon: Icons.contact_mail_outlined,
                            primaryColor: primaryColor,
                          ),
                          const SizedBox(height: 16),
                          _buildPasswordField(primaryColor),
                          const SizedBox(height: 8),
                          _buildForgotPasswordLink(primaryColor),
                          const SizedBox(height: 12),
                          _buildSubmitButton(primaryColor),
                          const SizedBox(height: 20),
                          _buildOAuthDivider(),
                          const SizedBox(height: 16),
                          Center(
                            child: OutlinedButton.icon(
                              onPressed: () => _handleOAuthLogin('Google'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                              ),
                              icon: SvgPicture.asset(
                                'assets/images/google_logo.svg',
                                width: 18,
                                height: 18,
                              ),
                              label: Text(
                                'Google',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildRegisterLink(primaryColor),
                        ],
                      ),
                    ),
                    _buildFooter(primaryColor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPERS FOR LOGIN FORMS
  // ==========================================
  Widget _buildFormCardWrapper({required Color primaryColor, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: child,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color primaryColor,
  }) {
    return TextFormField(
      controller: controller,
      validator: _validateEmail,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPasswordField(Color primaryColor) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      validator: _validatePassword,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: _language == 'ID' ? 'Masukkan password Anda' : 'Enter your password',
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.remove_red_eye_outlined : Icons.remove_red_eye,
            size: 20,
            color: Colors.grey.shade700,
          ),
          onPressed: _togglePasswordVisibility,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordLink(Color primaryColor) {
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: _handleForgotPassword,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            _language == 'ID' ? 'Lupa Password?' : 'Forgot Password?',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(Color primaryColor) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _loading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0.5,
        ),
        child: _loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Text(
                _language == 'ID' ? 'Masuk' : 'Log In',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildOAuthDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 0.8)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            _language == 'ID' ? 'Atau masuk dengan' : 'Or log in with',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Expanded(child: Divider(thickness: 0.8)),
      ],
    );
  }

  Widget _buildOAuthButton({
    required String label,
    required String logo,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: Colors.grey.shade300, width: 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: SvgPicture.asset(
        logo,
        width: 18,
        height: 18,
      ),
      label: Text(
        label,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
      ),
    );
  }

  Widget _buildRegisterLink(Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _language == 'ID' ? 'Belum memiliki akun? ' : "Don't have an account? ",
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        InkWell(
          onTap: () => context.push(RouteNames.register),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              _language == 'ID' ? 'Daftar Sekarang' : 'Register Now',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------
// DOT GRID BACKGROUND DECORATION PAINTER
// ----------------------------------------------------
class DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade200.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    const double spacing = 10.0;
    const int rows = 4;
    const int cols = 6;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        canvas.drawCircle(Offset(c * spacing, r * spacing), 2.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ----------------------------------------------------
// NATIVE VECTOR GRADUATION CAP, BOOK STACK & PLANT
// ----------------------------------------------------
class GraduationIllustration extends StatelessWidget {
  const GraduationIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) return const SizedBox();

    return SizedBox(
      width: 170,
      height: 130,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          // Little potted plant
          Positioned(
            left: 120,
            bottom: 0,
            child: SizedBox(
              width: 36,
              height: 56,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: 22,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    child: Icon(Icons.spa, color: Colors.blue.shade300, size: 26),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 2,
                    child: Transform.rotate(
                      angle: -0.4,
                      child: Icon(Icons.spa, color: Colors.blue.shade200, size: 16),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    right: 2,
                    child: Transform.rotate(
                      angle: 0.4,
                      child: Icon(Icons.spa, color: Colors.blue.shade200, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Book stack
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              width: 110,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(3),
                  bottomRight: Radius.circular(3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(width: 8, height: 18, color: Colors.white.withOpacity(0.7)),
              ),
            ),
          ),
          Positioned(
            left: 6,
            bottom: 15,
            child: Container(
              width: 104,
              height: 16,
              decoration: const BoxDecoration(
                color: Color(0xFF94A3B8),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(3),
                  bottomRight: Radius.circular(3),
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(width: 6, height: 16, color: Colors.white.withOpacity(0.7)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 27,
            child: Container(
              width: 94,
              height: 15,
              decoration: const BoxDecoration(
                color: Color(0xFF3B82F6),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(3),
                  bottomRight: Radius.circular(3),
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(width: 6, height: 15, color: Colors.white.withOpacity(0.7)),
              ),
            ),
          ),

          // Graduation Cap
          Positioned(
            left: 14,
            bottom: 37,
            child: SizedBox(
              width: 60,
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: 26,
                      height: 11,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E3A8A),
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    child: Transform.rotate(
                      angle: -0.15,
                      child: Container(
                        width: 44,
                        height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(2.5),
                          border: Border.all(color: const Color(0xFF1D4ED8), width: 0.8),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 4,
                    child: Container(
                      width: 1.5,
                      height: 12,
                      color: Colors.amber,
                    ),
                  ),
                  Positioned(
                    right: 5,
                    bottom: 0,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
