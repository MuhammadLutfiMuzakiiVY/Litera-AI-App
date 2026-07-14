import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:litera_ai_mobile/app/router/route_names.dart';
import 'package:litera_ai_mobile/features/auth/application/auth_controller.dart';

class IntroVideoScreen extends ConsumerStatefulWidget {
  const IntroVideoScreen({super.key});

  @override
  ConsumerState<IntroVideoScreen> createState() => _IntroVideoScreenState();
}

class _IntroVideoScreenState extends ConsumerState<IntroVideoScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset('assets/videos/intro.mp4');
    try {
      await _controller.initialize();
      _controller.addListener(_videoListener);
      await _controller.play();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
        // Automatically skip if the video fails to load/play to prevent blocking the user
        Future.delayed(const Duration(milliseconds: 500), _navigateToNextScreen);
      }
    }
  }

  void _videoListener() {
    if (_controller.value.position >= _controller.value.duration) {
      _navigateToNextScreen();
    } else {
      // Rebuild to update progress indicator
      setState(() {});
    }
  }

  void _navigateToNextScreen() {
    if (!mounted) return;
    
    // Dispose listener first
    _controller.removeListener(_videoListener);
    
    final auth = ref.read(authControllerProvider);
    if (!auth.onboardingCompleted) {
      context.go(RouteNames.onboarding);
    } else {
      context.go(RouteNames.login);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show standard bars again when leaving full-screen video
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);

    if (_hasError) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full-screen scale cover video
          if (_isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
