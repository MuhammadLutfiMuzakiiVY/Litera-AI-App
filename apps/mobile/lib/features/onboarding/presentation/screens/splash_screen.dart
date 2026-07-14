import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:litera_ai_mobile/app/router/route_names.dart';
import 'package:litera_ai_mobile/features/auth/application/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _masterController;
  late final AnimationController _pulseController;
  late final AnimationController _networkController;

  late final Animation<double> _bgFadeAnimation;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _logoFadeAnimation;
  late final Animation<double> _taglineSlideAnimation;
  late final Animation<double> _taglineFadeAnimation;
  late final Animation<double> _loadingProgressAnimation;

  final List<NodePoint> _networkPoints = [];
  DateTime _lastTickTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    // Initialize 25 random nodes for the AI Neural Network
    final random = math.Random();
    for (int i = 0; i < 25; i++) {
      _networkPoints.add(
        NodePoint(
          relativeX: random.nextDouble(),
          relativeY: random.nextDouble(),
          vx: (random.nextDouble() - 0.5) * 0.05, // very slow movement
          vy: (random.nextDouble() - 0.5) * 0.05,
          radius: random.nextDouble() * 2 + 1.5,
        ),
      );
    }

    // 1. Master controller (3 seconds total splash screen duration)
    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // 2. Pulse controller for the blue glow around the logo (runs 2 times)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    // 3. Network controller for the particle simulation (continuous)
    _networkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _networkController.addListener(_updateNetworkSimulation);

    // Define animation timelines
    // Background fade-in (0 - 500 ms)
    _bgFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.166, curve: Curves.easeOut),
      ),
    );

    // Logo scale and fade-in (400 ms - 1400 ms)
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.133, 0.466, curve: Curves.easeIn),
      ),
    );
    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.133, 0.466, curve: Curves.easeOutBack),
      ),
    );

    // Tagline slide-up and fade-in (1200 ms - 2200 ms)
    _taglineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.4, 0.733, curve: Curves.easeIn),
      ),
    );
    _taglineSlideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.4, 0.733, curve: Curves.easeOutCubic),
      ),
    );

    // Thin loading progress indicator (100 ms - 2800 ms)
    _loadingProgressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.033, 0.933, curve: Curves.easeInOutSine),
      ),
    );

    // Trigger the glow pulse after the logo appears and navigate on completion
    _masterController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        final auth = ref.read(authControllerProvider);
        if (auth.onboardingCompleted) {
          context.go(RouteNames.login);
        } else {
          context.go(RouteNames.introVideo);
        }
      }
      if (status == AnimationStatus.forward) {
        // Delay pulse trigger to match when logo finishes scaling in
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) {
            _pulseController.repeat(reverse: true);
            // Stop pulsing after 2 full cycles (4 half-cycles)
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                _pulseController.stop();
              }
            });
          }
        });
      }
    });

    _masterController.forward();
  }

  void _updateNetworkSimulation() {
    final now = DateTime.now();
    final dt = now.difference(_lastTickTime).inMicroseconds / 1000000.0;
    _lastTickTime = now;

    if (dt <= 0 || dt > 0.1) return; // ignore huge time deltas

    setState(() {
      for (final point in _networkPoints) {
        point.update(dt);
      }
    });
  }

  @override
  void dispose() {
    _networkController.removeListener(_updateNetworkSimulation);
    _masterController.dispose();
    _pulseController.dispose();
    _networkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Adjust theme color constants based on light/dark mode
    final Color primaryColor = const Color(0xFF2563EB);
    final Color secondaryColor = const Color(0xFF60A5FA);
    final Color accentColor = const Color(0xFF38BDF8);

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

    final textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);

    // Apply system navigation bar colors for premium layout integration
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
          // 1. Full-screen animated background gradient
          AnimatedBuilder(
            animation: _bgFadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _bgFadeAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: backgroundGradient,
                  ),
                ),
              );
            },
          ),

          // 2. Slow moving AI Neural Network background (CustomPainter)
          Positioned.fill(
            child: CustomPaint(
              painter: NeuralNetworkPainter(
                points: _networkPoints,
                animationValue: _networkController.value,
                lineColor: isDark ? accentColor : primaryColor,
              ),
            ),
          ),

          // 3. Central Content (Logo, app name, description, tagline)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Area with Glow and Scale Animation
                  AnimatedBuilder(
                    animation: _masterController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoFadeAnimation.value,
                        child: Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Pulsing glow effect behind logo
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  final pulseValue = _pulseController.value;
                                  return Container(
                                    width: 140 + (30 * pulseValue),
                                    height: 140 + (30 * pulseValue),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: secondaryColor.withValues(
                                            alpha: 0.25 * (1.0 - pulseValue),
                                          ),
                                          blurRadius: 25 + 15 * pulseValue,
                                          spreadRadius: 2 + 10 * pulseValue,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              // Glassmorphic ring around logo
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: (isDark ? Colors.white : primaryColor)
                                        .withValues(alpha: 0.08),
                                    width: 1.5,
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withValues(alpha: isDark ? 0.05 : 0.4),
                                      Colors.white.withValues(alpha: isDark ? 0.01 : 0.1),
                                    ],
                                  ),
                                ),
                              ),
                              // Actual Logo Image
                              SvgPicture.asset(
                                'assets/images/logo.svg',
                                width: 100,
                                height: 100,
                                placeholderBuilder: (context) => Icon(
                                  Icons.auto_stories,
                                  size: 56,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // App Name and Subtitle
                  AnimatedBuilder(
                    animation: _masterController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoFadeAnimation.value,
                        child: Column(
                          children: [
                            Text(
                              'Litera AI',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Literacy Intelligent Assistant',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Tagline with Slide-up + Fade-in
                  AnimatedBuilder(
                    animation: _masterController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _taglineFadeAnimation.value,
                        child: Transform.translate(
                          offset: Offset(0, _taglineSlideAnimation.value),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.white : primaryColor)
                                  .withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: (isDark ? Colors.white : primaryColor)
                                    .withValues(alpha: 0.06),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bolt,
                                  size: 14,
                                  color: isDark ? accentColor : primaryColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Belajar Adaptif Berbasis AI',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? accentColor : primaryColor,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 4. Loading indicator at the bottom
          Positioned(
            bottom: media.padding.bottom + 48,
            left: 64,
            right: 64,
            child: AnimatedBuilder(
              animation: _masterController,
              builder: (context, child) {
                return Opacity(
                  opacity: _bgFadeAnimation.value,
                  child: Column(
                    children: [
                      // Thin progress line
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: SizedBox(
                          height: 2,
                          child: LinearProgressIndicator(
                            value: _loadingProgressAnimation.value,
                            backgroundColor: (isDark ? Colors.white : primaryColor)
                                .withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? accentColor : primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NeuralNetworkPainter extends CustomPainter {
  NeuralNetworkPainter({
    required this.points,
    required this.animationValue,
    required this.lineColor,
  });

  final List<NodePoint> points;
  final double animationValue;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor.withValues(alpha: 0.15)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;

    // Draw lines between close points
    for (int i = 0; i < points.length; i++) {
      final p1 = points[i].getPosition(size);
      for (int j = i + 1; j < points.length; j++) {
        final p2 = points[j].getPosition(size);
        final dist = (p1 - p2).distance;
        if (dist < 130.0) {
          final linePaint = Paint()
            ..color = lineColor.withValues(alpha: 0.07 * (1.0 - dist / 130.0))
            ..strokeWidth = 1.0;
          canvas.drawLine(p1, p2, linePaint);
        }
      }
    }

    // Draw points
    for (final point in points) {
      final p = point.getPosition(size);
      canvas.drawCircle(p, point.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant NeuralNetworkPainter oldDelegate) => true;
}

class NodePoint {
  NodePoint({
    required this.relativeX,
    required this.relativeY,
    required this.vx,
    required this.vy,
    required this.radius,
  });

  double relativeX;
  double relativeY;
  double vx;
  double vy;
  double radius;

  void update(double dt) {
    relativeX += vx * dt;
    relativeY += vy * dt;

    if (relativeX < 0 || relativeX > 1) {
      vx = -vx;
      relativeX = relativeX.clamp(0.0, 1.0);
    }
    if (relativeY < 0 || relativeY > 1) {
      vy = -vy;
      relativeY = relativeY.clamp(0.0, 1.0);
    }
  }

  Offset getPosition(Size size) {
    return Offset(relativeX * size.width, relativeY * size.height);
  }
}
