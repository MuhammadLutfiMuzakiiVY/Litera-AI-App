import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:litera_ai_mobile/features/auth/application/auth_controller.dart';
import 'package:litera_ai_mobile/features/auth/domain/user_role.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  String _otp = '';
  
  bool _loading = false;
  bool _isVerified = false; // Local state to display Success screen before Riverpod redirect
  int _secondsRemaining = 59;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Pre-fill mock OTP code '123456' for immediate interactive convenience
    for (int i = 0; i < 6; i++) {
      _controllers[i].text = (i + 1).toString();
    }
    _otp = '123456';
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _secondsRemaining = 59;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _resendCode() async {
    _startCountdown();
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kode OTP baru telah dikirim ke email Anda.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Final confirmation to update status & trigger GoRouter redirect
  Future<void> _completeRedirect() async {
    setState(() => _loading = true);
    try {
      await ref.read(authControllerProvider.notifier).verifyEmail(otp: _otp);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan verifikasi email.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _submit() {
    if (_otp != '123456') {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP tidak valid. Coba kode "123456".'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    HapticFeedback.mediumImpact();
    setState(() {
      _isVerified = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Detect Role based on active registered user details
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

    if (_isVerified) {
      return _buildSuccessScreen(displayRole);
    }

    switch (displayRole) {
      case 'guru':
        return _buildGuruVerificationView(email);
      case 'orang_tua':
        return _buildOrangTuaVerificationView(email);
      default:
        return _buildSiswaVerificationView(email);
    }
  }

  // ==========================================
  // SUCCESS SCREEN
  // ==========================================
  Widget _buildSuccessScreen(String role) {
    Color primaryColor;
    String message;
    String btnLabel;
    IconData icon;
    Gradient bgGradient;

    if (role == 'guru') {
      primaryColor = const Color(0xFF1E3A8A); // Navy
      message = 'Verifikasi berhasil. Dashboard Guru siap digunakan.';
      btnLabel = 'Masuk ke Dashboard';
      icon = Icons.assessment_outlined;
      bgGradient = const LinearGradient(
        colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (role == 'orang_tua') {
      primaryColor = const Color(0xFF16A34A); // Green
      message = 'Email berhasil diverifikasi. Kini Anda dapat memantau perkembangan belajar anak.';
      btnLabel = 'Lanjutkan';
      icon = Icons.family_restroom;
      bgGradient = const LinearGradient(
        colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else {
      primaryColor = const Color(0xFF2563EB); // Blue
      message = 'Selamat! Email berhasil diverifikasi.';
      btnLabel = 'Mulai Belajar';
      icon = Icons.school;
      bgGradient = const LinearGradient(
        colors: [Color(0xFFDBEAFE), Color(0xFFEFF6FF)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: bgGradient),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Success particles decoration
            if (role == 'siswa') ...[
              const Positioned(
                left: 60,
                top: 140,
                child: Icon(Icons.star, color: Colors.amber, size: 28),
              ),
              const Positioned(
                right: 50,
                bottom: 180,
                child: Icon(Icons.rocket_launch, color: Colors.cyan, size: 38),
              ),
            ],
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Giant Success Checkmark Badge
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(icon, size: 68, color: primaryColor),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      role == 'siswa' ? 'Horee! 🎉' : (role == 'guru' ? 'Verifikasi Sukses' : 'Verifikasi Berhasil'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: role == 'guru' ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: role == 'guru' ? Colors.grey[300] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 36),
                    // Action button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _completeRedirect,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                              )
                            : Text(btnLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 1. SISWA VERIFICATION VIEW
  // ==========================================
  Widget _buildSiswaVerificationView(String email) {
    final primaryColor = const Color(0xFF2563EB);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDBEAFE), Color(0xFFF8FAFC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Rocket & Stars decoration
            Positioned(
              left: 40,
              top: 100,
              child: Opacity(
                opacity: 0.8,
                child: Icon(Icons.rocket_launch_outlined, color: Colors.cyan.shade300, size: 28),
              ),
            ),
            Positioned(
              right: 40,
              top: 140,
              child: Opacity(
                opacity: 0.8,
                child: Icon(Icons.star_outline_rounded, color: Colors.amber.shade300, size: 20),
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
                      // Centered letter stack illustration
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
                            ],
                          ),
                          child: Icon(Icons.mark_email_unread_outlined, size: 48, color: primaryColor),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Verifikasi Email Kamu',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.blue.shade900),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kami telah mengirimkan kode OTP ke email yang kamu daftarkan. Masukkan kode tersebut untuk mengaktifkan akun LITERA-AI.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          _maskEmail(email),
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Form input card wrapper
                      _buildVerificationCard(
                        primaryColor: primaryColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OtpInputField(
                              controllers: _controllers,
                              focusNodes: _focusNodes,
                              onChanged: (val) => setState(() => _otp = val),
                            ),
                            const SizedBox(height: 24),
                            _buildTimerWidget(primaryColor),
                            const SizedBox(height: 18),
                            _buildVerifyButton(primaryColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 2. GURU VERIFICATION VIEW
  // ==========================================
  Widget _buildGuruVerificationView(String email) {
    final primaryColor = const Color(0xFF1E3A8A); // Navy
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Professional Analytics Icon background glow
            Positioned(
              right: 20,
              top: 100,
              child: Opacity(
                opacity: 0.05,
                child: Icon(Icons.analytics_outlined, size: 120, color: primaryColor),
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
                      // Centered analytics school dashboard icon
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.badge_outlined, size: 48, color: primaryColor),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Verifikasi Akun Guru',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: primaryColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Masukkan kode verifikasi yang telah dikirim ke email Anda untuk mengaktifkan akses ke dashboard guru.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          _maskEmail(email),
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Form input card wrapper
                      _buildVerificationCard(
                        primaryColor: primaryColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OtpInputField(
                              controllers: _controllers,
                              focusNodes: _focusNodes,
                              onChanged: (val) => setState(() => _otp = val),
                            ),
                            const SizedBox(height: 24),
                            _buildTimerWidget(primaryColor),
                            const SizedBox(height: 18),
                            _buildVerifyButton(primaryColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 3. ORANG TUA VERIFICATION VIEW
  // ==========================================
  Widget _buildOrangTuaVerificationView(String email) {
    final primaryColor = const Color(0xFF16A34A); // Green
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF0FDF4), Color(0xFFF8FAFC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Family & nature overlay decoration
            Positioned(
              left: -20,
              top: 80,
              child: Opacity(
                opacity: 0.05,
                child: Icon(Icons.nature_outlined, size: 120, color: primaryColor),
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
                      // Centered warm logo
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.family_restroom_outlined, size: 48, color: primaryColor),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Konfirmasi Email Anda',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: primaryColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Masukkan kode OTP yang telah dikirim ke email Anda agar dapat memantau perkembangan belajar anak.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          _maskEmail(email),
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Form input card wrapper
                      _buildVerificationCard(
                        primaryColor: primaryColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OtpInputField(
                              controllers: _controllers,
                              focusNodes: _focusNodes,
                              onChanged: (val) => setState(() => _otp = val),
                            ),
                            const SizedBox(height: 24),
                            _buildTimerWidget(primaryColor),
                            const SizedBox(height: 18),
                            _buildVerifyButton(primaryColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SHARED UTILITIES
  // ==========================================
  Widget _buildVerificationCard({required Color primaryColor, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTimerWidget(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_secondsRemaining > 0) ...[
          Icon(Icons.timer_outlined, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 6),
          Text(
            'Kirim ulang dalam $_secondsRemaining s',
            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold),
          ),
        ] else ...[
          Text(
            'Tidak menerima kode? ',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          InkWell(
            onTap: _resendCode,
            child: Text(
              'Kirim Ulang Kode',
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVerifyButton(Color color) {
    final isBtnEnabled = _otp.length == 6;
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: isBtnEnabled ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0.5,
        ),
        child: const Text('Verifikasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }

  String _maskEmail(String email) {
    if (email.isEmpty) return '';
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 3) {
      return '${name[0]}***@$domain';
    }
    return '${name.substring(0, 3)}***@$domain';
  }
}

// ----------------------------------------------------
// OTP INPUT DIGIT MATRIX FIELD
// ----------------------------------------------------
class OtpInputField extends StatefulWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final ValueChanged<String> onChanged;

  const OtpInputField({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return Container(
          width: 44,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: widget.controllers[index],
            focusNode: widget.focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) {
              if (value.isNotEmpty) {
                if (index < 5) {
                  widget.focusNodes[index + 1].requestFocus();
                } else {
                  widget.focusNodes[index].unfocus();
                }
              } else {
                if (index > 0) {
                  widget.focusNodes[index - 1].requestFocus();
                }
              }
              // Callback full OTP string
              final otp = widget.controllers.map((c) => c.text).join();
              widget.onChanged(otp);
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
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
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.8),
              ),
            ),
          ),
        );
      }),
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
