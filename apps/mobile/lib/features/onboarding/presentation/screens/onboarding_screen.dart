import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:litera_ai_mobile/features/auth/application/auth_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late final AnimationController _lightController;

  @override
  void initState() {
    super.initState();
    _lightController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  final List<OnboardingSlide> _slides = [
    const OnboardingSlide(
      title: 'Pengenalan Litera AI',
      description:
          'Asisten cerdas pendamping belajar literasi dan numerasi yang interaktif dan siap membantu Anda kapan saja.',
      icon: Icons.auto_awesome,
      accentColor: Color(0xFF2563EB), // Primary Blue
    ),
    const OnboardingSlide(
      title: 'Keunggulan AI Tutor',
      description:
          'Dapatkan penjelasan materi secara instan, tanya jawab interaktif, dan panduan belajar yang dipersonalisasi.',
      icon: Icons.psychology_outlined,
      accentColor: Color(0xFF8B5CF6), // Royal Purple
    ),
    const OnboardingSlide(
      title: 'Pembelajaran Adaptif',
      description:
          'Jalur belajar dan tingkat kesulitan soal otomatis menyesuaikan kecepatan pemahaman Anda untuk hasil maksimal.',
      icon: Icons.track_changes_outlined,
      accentColor: Color(0xFF10B981), // Emerald Green
    ),
    const OnboardingSlide(
      title: 'Privasi Data Terjamin',
      description:
          'Kami berkomitmen penuh melindungi data pribadi dan perkembangan belajar Anda dengan enkripsi keamanan terbaik.',
      icon: Icons.shield_outlined,
      accentColor: Color(0xFFEF4444), // Crimson Red
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _lightController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    ref.read(authControllerProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final backgroundGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
          );

    final cardColor = isDark
        ? const Color(0xFF1E293B).withValues(alpha: 0.8)
        : Colors.white.withValues(alpha: 0.85);

    final activeDotColor = _slides[_currentPage].accentColor;

    // Apply system status & navigation bar styling for immersive layout
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          // 1. Full-screen Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: backgroundGradient,
            ),
          ),

          // 2. Animated Floating Background Light Beams (Cahaya Tipis Bergerak Random)
          AnimatedBuilder(
            animation: _lightController,
            builder: (context, child) {
              final progress = _lightController.value;
              final angle = progress * 2 * math.pi;

              // Smooth drift calculation
              final x1 = math.sin(angle) * 70 + 30;
              final y1 = math.cos(angle) * 110 + 130;

              final x2 = math.cos(angle + math.pi / 2) * 90 + 140;
              final y2 = math.sin(angle + math.pi / 2) * 130 + 320;

              final x3 = math.sin(angle * 2) * 50 + 100;
              final y3 = math.cos(angle * 2) * 70 + 480;

              return Stack(
                children: [
                  // Light blue aura
                  Positioned(
                    left: x1,
                    top: y1,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF38BDF8).withValues(alpha: isDark ? 0.08 : 0.16),
                            const Color(0xFF38BDF8).withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Soft purple aura
                  Positioned(
                    left: x2,
                    top: y2,
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.06 : 0.12),
                            const Color(0xFF8B5CF6).withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Thin white/cyan glow
                  Positioned(
                    left: x3,
                    top: y3,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFE0F2FE).withValues(alpha: isDark ? 0.08 : 0.16),
                            const Color(0xFFE0F2FE).withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // 3. Main PageView content
          SafeArea(
            child: Column(
              children: [
                // Top Header actions
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Simple mini logo or indicator
                      Row(
                        children: [
                          Icon(
                            Icons.bolt,
                            color: activeDotColor,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Litera AI',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              color: isDark ? Colors.white : Colors.blueGrey[900],
                            ),
                          ),
                        ],
                      ),
                      // Skip button
                      if (_currentPage < _slides.length - 1)
                        TextButton(
                          onPressed: _finishOnboarding,
                          child: Text(
                            'Lewati',
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 48), // Spacer placeholder
                    ],
                  ),
                ),

                // Slide contents PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return _buildSlideContent(context, slide, isDark);
                    },
                  ),
                ),

                // Bottom Navigation Card (Indicators and Buttons)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: (isDark ? Colors.white : primaryColor)
                            .withValues(alpha: 0.08),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Page description text (rendered in bottom card for clarity)
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Column(
                            key: ValueKey<int>(_currentPage),
                            children: [
                              Text(
                                _slides[_currentPage].title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _slides[_currentPage].description,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF475569),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Indicators and Navigation Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Slide indicators (dots)
                            Row(
                              children: List.generate(
                                _slides.length,
                                (index) => _buildIndicatorDot(index),
                              ),
                            ),

                            // Next/Finish Action Button
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              width: _currentPage == _slides.length - 1 ? 160 : 64,
                              height: 60,
                              child: _currentPage == _slides.length - 1
                                  ? FilledButton(
                                      onPressed: _finishOnboarding,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: activeDotColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Mulai',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            Icons.arrow_forward,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    )
                                  : InkWell(
                                      onTap: _nextPage,
                                      borderRadius: BorderRadius.circular(20),
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          color: activeDotColor,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.chevron_right,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideContent(
    BuildContext context,
    OnboardingSlide slide,
    bool isDark,
  ) {
    final index = _slides.indexOf(slide);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Ambient Glow Backdrops
              _buildBackdropGlow(index, isDark),

              // 2. Outer Glass Ring
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: slide.accentColor.withValues(alpha: 0.15),
                    width: 2,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: isDark ? 0.05 : 0.25),
                      Colors.white.withValues(alpha: isDark ? 0.01 : 0.05),
                    ],
                  ),
                ),
              ),

              // 3. Middle Glow Circle
              Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: slide.accentColor.withValues(alpha: isDark ? 0.2 : 0.1),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: index == 0
                      ? SvgPicture.asset(
                          'assets/images/logo.svg',
                          width: 100,
                          height: 100,
                        )
                      : Icon(
                          slide.icon,
                          size: 76,
                          color: slide.accentColor,
                        ),
                ),
              ),

              // 4. Dynamic Floating Decorative Items ("Ramai" Visuals)
              ..._buildFloatingItems(index, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackdropGlow(int index, bool isDark) {
    Color color1;
    Color color2;

    switch (index) {
      case 0:
        color1 = const Color(0xFF2563EB); // Blue
        color2 = const Color(0xFF8B5CF6); // Purple
        break;
      case 1:
        color1 = const Color(0xFF8B5CF6); // Purple
        color2 = const Color(0xFFEC4899); // Pink
        break;
      case 2:
        color1 = const Color(0xFF10B981); // Green
        color2 = const Color(0xFF3B82F6); // Blue
        break;
      default:
        color1 = const Color(0xFFEF4444); // Red
        color2 = const Color(0xFFF59E0B); // Amber
    }

    return Stack(
      children: [
        Positioned(
          left: 30,
          top: 30,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color1.withValues(alpha: isDark ? 0.18 : 0.25),
                  color1.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 30,
          bottom: 30,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color2.withValues(alpha: isDark ? 0.18 : 0.25),
                  color2.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFloatingItems(int index, bool isDark) {
    final glassBg = isDark
        ? const Color(0xFF334155).withValues(alpha: 0.8)
        : Colors.white.withValues(alpha: 0.9);

    final glassBorder = (isDark ? Colors.white : Colors.blueGrey)
        .withValues(alpha: 0.15);

    Widget makeFloatingCard({
      required double left,
      required double top,
      required IconData icon,
      required Color color,
      double size = 20,
    }) {
      return Positioned(
        left: left,
        top: top,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: glassBg,
            shape: BoxShape.circle,
            border: Border.all(color: glassBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: size),
        ),
      );
    }

    if (index == 0) {
      // Pengenalan LITERA-AI: Vibrant book, stars, spark particles
      return [
        makeFloatingCard(
          left: 40,
          top: 30,
          icon: Icons.menu_book_rounded,
          color: const Color(0xFF3B82F6),
          size: 22,
        ),
        makeFloatingCard(
          left: 220,
          top: 50,
          icon: Icons.school_outlined,
          color: const Color(0xFFF59E0B),
          size: 22,
        ),
        makeFloatingCard(
          left: 30,
          top: 190,
          icon: Icons.auto_awesome_rounded,
          color: const Color(0xFF8B5CF6),
          size: 20,
        ),
        makeFloatingCard(
          left: 230,
          top: 180,
          icon: Icons.create_rounded,
          color: const Color(0xFF10B981),
          size: 20,
        ),
      ];
    } else if (index == 1) {
      // Keunggulan AI Tutor: Chat bubble, lightbulb, sparkles
      return [
        makeFloatingCard(
          left: 45,
          top: 40,
          icon: Icons.forum_outlined,
          color: const Color(0xFFEC4899),
          size: 22,
        ),
        makeFloatingCard(
          left: 215,
          top: 40,
          icon: Icons.lightbulb_outline_rounded,
          color: const Color(0xFFF59E0B),
          size: 22,
        ),
        makeFloatingCard(
          left: 35,
          top: 185,
          icon: Icons.mic_none_rounded,
          color: const Color(0xFF3B82F6),
          size: 20,
        ),
        makeFloatingCard(
          left: 225,
          top: 190,
          icon: Icons.star_rounded,
          color: const Color(0xFF8B5CF6),
          size: 20,
        ),
      ];
    } else if (index == 2) {
      // Pembelajaran Adaptif: Path target, progress nodes, trophy
      return [
        makeFloatingCard(
          left: 50,
          top: 35,
          icon: Icons.emoji_events_outlined,
          color: const Color(0xFFF59E0B),
          size: 22,
        ),
        makeFloatingCard(
          left: 220,
          top: 45,
          icon: Icons.trending_up_rounded,
          color: const Color(0xFF10B981),
          size: 22,
        ),
        makeFloatingCard(
          left: 30,
          top: 180,
          icon: Icons.flag_outlined,
          color: const Color(0xFFEF4444),
          size: 20,
        ),
        makeFloatingCard(
          left: 230,
          top: 185,
          icon: Icons.timeline_rounded,
          color: const Color(0xFF3B82F6),
          size: 20,
        ),
      ];
    } else {
      // Privasi Data: Lock, verified badge, shield check
      return [
        makeFloatingCard(
          left: 45,
          top: 45,
          icon: Icons.lock_outline_rounded,
          color: const Color(0xFF10B981),
          size: 22,
        ),
        makeFloatingCard(
          left: 215,
          top: 45,
          icon: Icons.verified_user_outlined,
          color: const Color(0xFF3B82F6),
          size: 22,
        ),
        makeFloatingCard(
          left: 35,
          top: 190,
          icon: Icons.key_outlined,
          color: const Color(0xFFF59E0B),
          size: 20,
        ),
        makeFloatingCard(
          left: 225,
          top: 185,
          icon: Icons.gpp_good_outlined,
          color: const Color(0xFFEF4444),
          size: 20,
        ),
      ];
    }
  }

  Widget _buildIndicatorDot(int index) {
    final isSelected = _currentPage == index;
    final dotColor = _slides[_currentPage].accentColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isSelected ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isSelected ? dotColor : dotColor.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}

class OnboardingSlide {
  const OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
}
