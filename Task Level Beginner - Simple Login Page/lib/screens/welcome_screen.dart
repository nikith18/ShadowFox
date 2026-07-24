// welcome_screen.dart  (Liquid Glass Edition)
// ────────────────────────────────────────────────────────────────
// Post-login screen with glass profile card and Hero logo.
// Logout navigates back to LoginScreen with pushReplacement.
// ────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../viewmodels/login_viewmodel.dart';
import '../widgets/custom_button.dart';
import '../widgets/glass_card.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, required this.viewModel});
  final LoginViewModel viewModel;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _orbController;
  late final AnimationController _entryController;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;

  LoginViewModel get _vm => widget.viewModel;

  @override
  void initState() {
    super.initState();

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _entryFade = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));

    _entryController.forward();
  }

  @override
  void dispose() {
    _orbController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _handleLogout() {
    _vm.logout();
    // EXPLICIT NAVIGATION: replace WelcomeScreen with LoginScreen.
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: AppConstants.heroDuration,
        pageBuilder: (_, _, _) => LoginScreen(viewModel: _vm),
        transitionsBuilder: (_, anim, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeIn),
          child: child,
        ),
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return AnimatedBuilder(
      animation: _orbController,
      builder: (_, _) {
        final t = _orbController.value;
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: isDark
                      ? [
                          const Color(0xFF0a1628),
                          const Color(0xFF1a1035),
                          const Color(0xFF0D0D2B),
                        ]
                      : [
                          const Color(0xFFf0e8ff),
                          const Color(0xFFe0f4ff),
                          const Color(0xFFe8e0ff),
                        ],
                ),
              ),
            ),
            Positioned(
              right: -60 + 40 * math.sin(t * 2 * math.pi),
              top: -40 + 30 * math.cos(t * 2 * math.pi),
              child: _glowOrb(
                isDark ? const Color(0xFF00D4FF) : const Color(0xFF60B8FF),
                200,
                isDark ? 0.22 : 0.28,
              ),
            ),
            Positioned(
              left: -80 + 30 * math.cos(t * 2 * math.pi + 1),
              bottom: -50 + 40 * math.sin(t * 2 * math.pi + 1),
              child: _glowOrb(
                isDark ? const Color(0xFF6C63FF) : const Color(0xFF9C8FFF),
                200,
                isDark ? 0.22 : 0.28,
              ),
            ),
            Positioned(
              left: 60 + 20 * math.sin(t * 2 * math.pi + 2),
              top: 160 + 20 * math.cos(t * 2 * math.pi + 2),
              child: _glowOrb(
                isDark ? const Color(0xFFFF6CD4) : const Color(0xFFFF9EE0),
                120,
                isDark ? 0.14 : 0.18,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _glowOrb(Color color, double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Positioned.fill(child: _buildBackground(isDark)),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: FadeTransition(
                    opacity: _entryFade,
                    child: SlideTransition(
                      position: _entrySlide,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Column(
                            children: [
                              const SizedBox(height: AppConstants.paddingXL),

                              // ── Hero Logo ────────────────────────────
                              Hero(
                                tag: 'app_logo',
                                child: Container(
                                  width: AppConstants.logoSize * 1.1,
                                  height: AppConstants.logoSize * 1.1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [scheme.primary, scheme.tertiary],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.35,
                                      ),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: scheme.primary.withValues(
                                          alpha: 0.55,
                                        ),
                                        blurRadius: 36,
                                        offset: const Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.school_rounded,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                                ),
                              ),

                              const SizedBox(height: AppConstants.paddingXL),

                              // ── Profile Glass Card ───────────────────
                              GlassCard(
                                child: Column(
                                  children: [
                                    // Avatar
                                    Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            scheme.primary.withValues(
                                              alpha: 0.6,
                                            ),
                                            scheme.tertiary.withValues(
                                              alpha: 0.6,
                                            ),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.4,
                                          ),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.person_rounded,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: AppConstants.paddingMedium,
                                    ),

                                    Text(
                                      'Welcome back,',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.black45,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _vm.loggedInUsername,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(
                                      height: AppConstants.paddingLarge,
                                    ),

                                    // Success badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: isDark
                                            ? Colors.greenAccent.withValues(
                                                alpha: 0.12,
                                              )
                                            : Colors.green.withValues(
                                                alpha: 0.1,
                                              ),
                                        border: Border.all(
                                          color: Colors.green.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.verified_rounded,
                                            color: Colors.green,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Login Successful',
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.greenAccent
                                                  : Colors.green.shade700,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(
                                height: AppConstants.paddingMedium,
                              ),

                              // ── Feature chips glass card ──────────────
                              GlassCard(
                                opacity: 0.08,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.paddingMedium,
                                  vertical: AppConstants.paddingMedium,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Future Features',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white38
                                            : Colors.black38,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _chip(
                                          context,
                                          Icons.fingerprint_rounded,
                                          'Biometric',
                                          isDark,
                                        ),
                                        _chip(
                                          context,
                                          Icons.g_mobiledata_rounded,
                                          'Google Sign-In',
                                          isDark,
                                        ),
                                        _chip(
                                          context,
                                          Icons.cloud_rounded,
                                          'Firebase Auth',
                                          isDark,
                                        ),
                                        _chip(
                                          context,
                                          Icons.save_rounded,
                                          'SharedPrefs',
                                          isDark,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: AppConstants.paddingLarge),

                              // ── Logout Button ─────────────────────────
                              CustomButton(
                                label: 'Sign Out',
                                icon: Icons.logout_rounded,
                                onPressed: _handleLogout,
                              ),
                              const SizedBox(height: AppConstants.paddingLarge),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(BuildContext context, IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isDark ? Colors.white54 : Colors.black45),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
