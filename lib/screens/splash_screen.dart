import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _introController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideBottomAnim;
  late Animation<double> _pulseScaleAnim;
  late Animation<double> _pulseGlowAnim;
  late Animation<double> _titleLetterAnim;

  @override
  void initState() {
    super.initState();

    // Set immersive status & navigation bar to match theme
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF061A10),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // 1. Entrance Intro Animation Controller
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fadeAnim = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    );

    _scaleAnim = Tween<double>(begin: 0.70, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOutBack),
      ),
    );

    _titleLetterAnim = Tween<double>(begin: 1.5, end: 4.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.2, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _slideBottomAnim = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Ambient Continuous Pulse Controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseScaleAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _pulseGlowAnim = Tween<double>(begin: 0.25, end: 0.55).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    // 3. Floating Ambient Particles Controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _introController.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 2300));
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    await authProvider.checkAuth();
    if (!mounted) return;

    final targetWidget = authProvider.status == AuthStatus.authenticated
        ? const MainShell()
        : const LoginScreen();

    // Smooth Page Transition (Fade & Scale)
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (context, animation, secondaryAnimation) => targetWidget,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          final scale = Tween<double>(begin: 0.96, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );
          return FadeTransition(
            opacity: fade,
            child: ScaleTransition(scale: scale, child: child),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B2D1D),
      body: Stack(
        children: [
          // 1. Deep Gradient Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F3D27), // Deep Forest Green
                    Color(0xFF0B2D1D),
                    Color(0xFF061A10), // Midnight Pine
                  ],
                  stops: [0.0, 0.52, 1.0],
                ),
              ),
            ),
          ),

          // 2. Animated Ambient Floating Particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: _SplashParticlesPainter(progress: _particleController.value),
                size: Size.infinite,
              );
            },
          ),

          // 3. Ambient Glow Top Left
          Positioned(
            top: -80,
            left: -80,
            child: AnimatedBuilder(
              animation: _pulseGlowAnim,
              builder: (context, child) {
                return Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF22C55E).withValues(alpha: _pulseGlowAnim.value * 0.35),
                  ),
                );
              },
            ),
          ),

          // 4. Ambient Glow Center Right
          Positioned(
            top: 240,
            right: -90,
            child: AnimatedBuilder(
              animation: _pulseGlowAnim,
              builder: (context, child) {
                return Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF10B981).withValues(alpha: _pulseGlowAnim.value * 0.28),
                  ),
                );
              },
            ),
          ),

          // 5. Main Center Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),

                // Center Animated Logo & Branding
                FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Pulsing Halo & Emblem Container
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                // Pulsing Outer Aura Ring
                                Transform.scale(
                                  scale: _pulseScaleAnim.value * 1.15,
                                  child: Container(
                                    width: 110,
                                    height: 110,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF22C55E)
                                          .withValues(alpha: _pulseGlowAnim.value * 0.28),
                                    ),
                                  ),
                                ),

                                // Main Emblem Circular Badge
                                Container(
                                  width: 108,
                                  height: 108,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF22C55E),
                                        Color(0xFF059669),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF22C55E)
                                            .withValues(alpha: _pulseGlowAnim.value * 0.8),
                                        blurRadius: 36,
                                        spreadRadius: 6,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.45),
                                      width: 2.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 84,
                                      height: 84,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withValues(alpha: 0.16),
                                      ),
                                      child: const Icon(
                                        Icons.eco_rounded,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 26),

                        // App Title with Animated Letter Spacing
                        AnimatedBuilder(
                          animation: _titleLetterAnim,
                          builder: (context, child) {
                            return Text(
                              'VERDATICA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: _titleLetterAnim.value,
                                height: 1.1,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFF22C55E).withValues(alpha: 0.5),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        // Subtitle Pill Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF4ADE80),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'SMART FARMING & IOT ECOSYSTEM',
                                style: TextStyle(
                                  color: Color(0xFF86EFAC),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // Sleek Loading Ring with Glow
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                    child: const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Color(0xFF4ADE80),
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Footer: SMK Wikrama & BIA 2026 Branding
                SlideTransition(
                  position: _slideBottomAnim,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'POWERED & DEVELOPED BY',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.school_rounded,
                                  color: Color(0xFF4ADE80),
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'SMK WIKRAMA BOGOR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'BIA 2026 • Version 1.0.0',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
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
        ],
      ),
    );
  }
}

/// Floating ambient particle painter for sleek organic atmosphere
class _SplashParticlesPainter extends CustomPainter {
  final double progress;

  _SplashParticlesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final particles = [
      {'x': 0.18, 'y': 0.22, 'r': 2.5, 'speed': 1.0, 'alpha': 0.25},
      {'x': 0.82, 'y': 0.35, 'r': 3.2, 'speed': 0.7, 'alpha': 0.20},
      {'x': 0.28, 'y': 0.65, 'r': 2.0, 'speed': 1.2, 'alpha': 0.30},
      {'x': 0.75, 'y': 0.78, 'r': 3.5, 'speed': 0.8, 'alpha': 0.22},
      {'x': 0.48, 'y': 0.15, 'r': 1.8, 'speed': 1.4, 'alpha': 0.35},
      {'x': 0.88, 'y': 0.60, 'r': 2.2, 'speed': 0.9, 'alpha': 0.24},
    ];

    for (final p in particles) {
      final baseY = (p['y'] as double) * size.height;
      final baseX = (p['x'] as double) * size.width;
      final speed = p['speed'] as double;
      final radius = p['r'] as double;
      final alpha = p['alpha'] as double;

      // Floating sine oscillation
      final floatY = math.sin((progress * 2 * math.pi * speed) + baseX) * 14.0;
      final floatX = math.cos((progress * 2 * math.pi * speed) + baseY) * 8.0;

      paint.color = const Color(0xFF4ADE80).withValues(alpha: alpha);
      canvas.drawCircle(Offset(baseX + floatX, baseY + floatY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SplashParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
