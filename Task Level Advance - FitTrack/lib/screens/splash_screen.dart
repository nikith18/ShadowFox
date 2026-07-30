import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _bgController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _bgRotate;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _bgRotate =
        Tween<double>(begin: 0, end: 2 * math.pi).animate(_bgController);

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0, 0.5)),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textSlide =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _logoController.forward().then((_) => _textController.forward());

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBgGradient),
        child: Stack(
          children: [
            // Animated orbs live in their own RepaintBoundary so the main
            // content tree is not involved in each rotation frame.
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _bgRotate,
                builder: (_, __) => Stack(
                  children: [
                    _buildOrb(
                      size,
                      Offset(
                        size.width * 0.15 + math.cos(_bgRotate.value) * 28,
                        size.height * 0.2 + math.sin(_bgRotate.value) * 28,
                      ),
                      200,
                      AppColors.primary.withValues(alpha: 0.28),
                    ),
                    _buildOrb(
                      size,
                      Offset(
                        size.width * 0.85 + math.sin(_bgRotate.value) * 18,
                        size.height * 0.75 + math.cos(_bgRotate.value) * 18,
                      ),
                      180,
                      AppColors.accent.withValues(alpha: 0.18),
                    ),
                    _buildOrb(
                      size,
                      Offset(size.width * 0.5, size.height * 0.5),
                      130,
                      AppColors.primaryLight.withValues(alpha: 0.08),
                    ),
                  ],
                ),
              ),
            ),

            // Static logo + text above the orbs
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _logoOpacity,
                      child: _buildLogoCard(),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: const Column(
                        children: [
                          Text(
                            'FitTrack Pro',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Smart Fitness Tracking',
                            style: TextStyle(
                              color: Color(0xB3FFFFFF),
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  FadeTransition(
                    opacity: _textOpacity,
                    child: const _LoadingDots(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: AppColors.cardGradientDark,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.glassBorderDark),
          ),
          child: const Center(
            child: Text('💪', style: TextStyle(fontSize: 56)),
          ),
        ),
      ),
    );
  }

  Widget _buildOrb(Size size, Offset center, double radius, Color color) {
    return Positioned(
      left: center.dx - radius,
      top: center.dy - radius,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with TickerProviderStateMixin {
  final List<AnimationController> _dotControllers = [];
  final List<Animation<double>> _dotAnims = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      final c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 450),
      );
      final a = Tween<double>(begin: 0, end: -8).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
      _dotControllers.add(c);
      _dotAnims.add(a);
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) c.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _dotControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return RepaintBoundary(
          child: AnimatedBuilder(
            animation: _dotAnims[i],
            builder: (_, __) => Transform.translate(
              offset: Offset(0, _dotAnims[i].value),
              child: Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xB3FFFFFF),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
