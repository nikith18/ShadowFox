// login_screen.dart  (Liquid Glass Edition)
// ────────────────────────────────────────────────────────────────
// Animated gradient background + glass card form panel.
// All original functionality is preserved:
//   • Form validation, dummy login, Snackbar, lifecycle observer
//   • TextEditingController + FocusNode event listeners
//   • Hero logo animation, dark-mode toggle, remember-me, loading
// ────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/validators.dart';
import '../viewmodels/login_viewmodel.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_toggle.dart';
import 'welcome_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.viewModel});
  final LoginViewModel viewModel;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // ── Form ─────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  // ── Background orb animation ─────────────────────────────────────
  late final AnimationController _orbController;

  // ── Entry animation ───────────────────────────────────────────────
  late final AnimationController _entryController;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;

  LoginViewModel get _vm => widget.viewModel;

  @override
  void initState() {
    super.initState();

    // Slowly rotate/pulse the background orbs for a liquid-feel.
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entryFade = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));
    _entryController.forward();
  }

  @override
  void dispose() {
    _orbController.dispose();
    _entryController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ── LOGIN LOGIC ───────────────────────────────────────────────────
  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final success = await _vm.attemptLogin(
      username: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: AppConstants.heroDuration,
          pageBuilder: (_, _, _) => WelcomeScreen(viewModel: _vm),
          transitionsBuilder: (_, anim, _, child) => FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeIn),
            child: child,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Invalid Username or Password'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      );
    }
  }

  // ── BACKGROUND PAINTER ────────────────────────────────────────────
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
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF0D0D2B),
                          const Color(0xFF1a1035),
                          const Color(0xFF0a1628),
                        ]
                      : [
                          const Color(0xFFe0e8ff),
                          const Color(0xFFf0e8ff),
                          const Color(0xFFe8f4ff),
                        ],
                ),
              ),
            ),
            Positioned(
              left: -80 + 40 * math.sin(t * 2 * math.pi),
              top: -60 + 30 * math.cos(t * 2 * math.pi),
              child: _glowOrb(
                isDark ? const Color(0xFF6C63FF) : const Color(0xFF7C6FFF),
                220,
                isDark ? 0.25 : 0.3,
              ),
            ),
            Positioned(
              right: -60 + 30 * math.cos(t * 2 * math.pi + 1),
              bottom: -40 + 40 * math.sin(t * 2 * math.pi + 1),
              child: _glowOrb(
                isDark ? const Color(0xFF00D4FF) : const Color(0xFF60B8FF),
                180,
                isDark ? 0.2 : 0.25,
              ),
            ),
            Positioned(
              right: 40 + 20 * math.sin(t * 2 * math.pi + 2),
              top: 200 + 20 * math.cos(t * 2 * math.pi + 2),
              child: _glowOrb(
                isDark ? const Color(0xFFFF6CD4) : const Color(0xFFFF8CE0),
                140,
                isDark ? 0.15 : 0.2,
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

  // ── BUILD ─────────────────────────────────────────────────────────
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
              // ── Animated liquid background ────────────────────────
              Positioned.fill(child: _buildBackground(isDark)),

              // ── Foreground content ────────────────────────────────
              SafeArea(
                child: Column(
                  children: [
                    // ── Top bar (dark mode toggle) ──────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingMedium,
                        vertical: AppConstants.paddingSmall,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GlassToggle(
                            isDark: isDark,
                            onToggle: _vm.toggleDarkMode,
                          ),
                        ],
                      ),
                    ),

                    // ── Scrollable form (responsive) ─────────────────
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final hPad = constraints.maxWidth > 600
                              ? 48.0
                              : constraints.maxWidth > 400
                              ? AppConstants.paddingLarge
                              : AppConstants.paddingMedium;
                          return SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: hPad),
                            child: FadeTransition(
                              opacity: _entryFade,
                              child: SlideTransition(
                                position: _entrySlide,
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 480,
                                    ),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            height: AppConstants.paddingMedium,
                                          ),

                                          // ── Hero Logo ──────────────
                                          Hero(
                                            tag: 'app_logo',
                                            child: _buildLogo(scheme),
                                          ),
                                          const SizedBox(
                                            height: AppConstants.paddingLarge,
                                          ),

                                          // ── Title & Subtitle ───────
                                          Text(
                                            AppConstants.appName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black87,
                                                  letterSpacing: 0.5,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            AppConstants.appTagline,
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.white54
                                                  : Colors.black45,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: AppConstants.paddingXL,
                                          ),

                                          // ── Glass Card: Form fields ─
                                          GlassCard(
                                            padding: const EdgeInsets.all(
                                              AppConstants.paddingLarge,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Sign In',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w700,
                                                    color: isDark
                                                        ? Colors.white
                                                        : Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height:
                                                      AppConstants.paddingLarge,
                                                ),

                                                // Email
                                                CustomTextField(
                                                  controller: _emailController,
                                                  label: 'Email / Username',
                                                  hint: 'student@demo.com',
                                                  prefixIcon: Icons
                                                      .person_outline_rounded,
                                                  focusNode: _emailFocus,
                                                  nextFocusNode: _passwordFocus,
                                                  keyboardType: TextInputType
                                                      .emailAddress,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  validator: Validators
                                                      .validateUsernameOrEmail,
                                                ),
                                                const SizedBox(
                                                  height: AppConstants
                                                      .paddingMedium,
                                                ),

                                                // Password
                                                CustomTextField(
                                                  controller:
                                                      _passwordController,
                                                  label: 'Password',
                                                  hint: 'Minimum 6 characters',
                                                  prefixIcon: Icons
                                                      .lock_outline_rounded,
                                                  focusNode: _passwordFocus,
                                                  textInputAction:
                                                      TextInputAction.done,
                                                  isPassword: true,
                                                  validator: Validators
                                                      .validatePassword,
                                                  onFieldSubmitted: (_) =>
                                                      _handleLogin(),
                                                ),
                                                const SizedBox(
                                                  height:
                                                      AppConstants.paddingSmall,
                                                ),

                                                // Remember Me & Forgot
                                                Row(
                                                  children: [
                                                    Theme(
                                                      data: Theme.of(context)
                                                          .copyWith(
                                                            unselectedWidgetColor:
                                                                isDark
                                                                ? Colors.white38
                                                                : Colors
                                                                      .black26,
                                                          ),
                                                      child: Checkbox(
                                                        value: _vm.rememberMe,
                                                        onChanged: (v) =>
                                                            _vm.setRememberMe(
                                                              v ?? false,
                                                            ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                4,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      'Remember me',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: isDark
                                                            ? Colors.white70
                                                            : Colors.black54,
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    TextButton(
                                                      onPressed: () {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              'Forgot Password – coming soon!',
                                                            ),
                                                            behavior:
                                                                SnackBarBehavior
                                                                    .floating,
                                                          ),
                                                        );
                                                      },
                                                      child: Text(
                                                        'Forgot Password?',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: scheme.primary,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: AppConstants
                                                      .paddingMedium,
                                                ),

                                                // Login Button
                                                CustomButton(
                                                  label: 'Sign In',
                                                  onPressed: _handleLogin,
                                                  isLoading: _vm.isLoading,
                                                  icon: Icons.login_rounded,
                                                ),

                                                // Failed attempt counter
                                                if (_vm.loginAttempts > 0) ...[
                                                  const SizedBox(
                                                    height: AppConstants
                                                        .paddingSmall,
                                                  ),
                                                  Center(
                                                    child: Text(
                                                      '${_vm.loginAttempts} failed attempt${_vm.loginAttempts > 1 ? 's' : ''}',
                                                      style: TextStyle(
                                                        color: scheme.error,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),

                                          const SizedBox(
                                            height: AppConstants.paddingMedium,
                                          ),

                                          // Create Account
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Don't have an account?",
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.white54
                                                      : Colors.black45,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                      transitionDuration:
                                                          AppConstants
                                                              .heroDuration,
                                                      pageBuilder: (_, _, _) =>
                                                          RegisterScreen(
                                                            viewModel: _vm,
                                                          ),
                                                      transitionsBuilder:
                                                          (
                                                            _,
                                                            anim,
                                                            _,
                                                            child,
                                                          ) => SlideTransition(
                                                            position:
                                                                Tween<Offset>(
                                                                  begin:
                                                                      const Offset(
                                                                        0,
                                                                        1,
                                                                      ),
                                                                  end: Offset
                                                                      .zero,
                                                                ).animate(
                                                                  CurvedAnimation(
                                                                    parent:
                                                                        anim,
                                                                    curve: Curves
                                                                        .easeOut,
                                                                  ),
                                                                ),
                                                            child: child,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: const Text(
                                                  'Create Account',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          // Demo hint
                                          GlassCard(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  AppConstants.paddingMedium,
                                              vertical:
                                                  AppConstants.paddingSmall,
                                            ),
                                            opacity: 0.08,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.info_outline_rounded,
                                                  size: 16,
                                                  color: isDark
                                                      ? Colors.white54
                                                      : Colors.black45,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Demo: student@demo.com / 123456',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isDark
                                                        ? Colors.white54
                                                        : Colors.black45,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: AppConstants.paddingLarge,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogo(ColorScheme scheme) {
    return Container(
      width: AppConstants.logoSize,
      height: AppConstants.logoSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.5),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: const Icon(Icons.school_rounded, color: Colors.white, size: 52),
    );
  }
}
