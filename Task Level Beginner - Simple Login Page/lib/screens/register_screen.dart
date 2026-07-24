// register_screen.dart  (Liquid Glass Edition)
// ────────────────────────────────────────────────────────────────
// Registration form screen with identical liquid-glass styling to
// LoginScreen. Allows new users to create an account with:
//   • Full Name, Email, Password, Confirm Password
//   • Inline validation via Validators
//   • Loading spinner during account creation
//   • Success / failure Snackbar feedback
//   • Navigates back to LoginScreen on success
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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.viewModel});
  final LoginViewModel viewModel;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  // ── Form ─────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  // ── REGISTRATION LOGIC ────────────────────────────────────────────
  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final success = await _vm.registerAccount(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Account created! Please sign in.'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(child: Text('This email is already registered.')),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      );
    }
  }

  // ── BACKGROUND ────────────────────────────────────────────────────
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
                          const Color(0xFF0D0D2B),
                          const Color(0xFF1a1035),
                          const Color(0xFF0a1628),
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
              right: -70 + 40 * math.sin(t * 2 * math.pi),
              top: -50 + 30 * math.cos(t * 2 * math.pi),
              child: _glowOrb(
                isDark ? const Color(0xFF00D4FF) : const Color(0xFF60B8FF),
                210,
                isDark ? 0.22 : 0.28,
              ),
            ),
            Positioned(
              left: -70 + 30 * math.cos(t * 2 * math.pi + 1),
              bottom: -50 + 40 * math.sin(t * 2 * math.pi + 1),
              child: _glowOrb(
                isDark ? const Color(0xFF6C63FF) : const Color(0xFF9C8FFF),
                200,
                isDark ? 0.22 : 0.28,
              ),
            ),
            Positioned(
              right: 50 + 20 * math.sin(t * 2 * math.pi + 2),
              top: 240 + 20 * math.cos(t * 2 * math.pi + 2),
              child: _glowOrb(
                isDark ? const Color(0xFFFF6CD4) : const Color(0xFFFF9EE0),
                130,
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
              Positioned.fill(child: _buildBackground(isDark)),

              SafeArea(
                child: Column(
                  children: [
                    // ── Top bar ──────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingMedium,
                        vertical: AppConstants.paddingSmall,
                      ),
                      child: Row(
                        children: [
                          // Back button
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: GlassCard(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              borderRadius: 30,
                              blur: 16,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 15,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Back',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
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

                                          // ── Icon ──────────────────
                                          Container(
                                            width: AppConstants.logoSize,
                                            height: AppConstants.logoSize,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  scheme.primary,
                                                  scheme.tertiary,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(26),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: scheme.primary
                                                      .withValues(alpha: 0.5),
                                                  blurRadius: 30,
                                                  offset: const Offset(0, 10),
                                                ),
                                              ],
                                              border: Border.all(
                                                color: Colors.white.withValues(
                                                  alpha: 0.3,
                                                ),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.person_add_alt_1_rounded,
                                              color: Colors.white,
                                              size: 48,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: AppConstants.paddingLarge,
                                          ),

                                          // ── Title ─────────────────
                                          Text(
                                            'Create Account',
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
                                            'Join us – it only takes a moment',
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

                                          // ── Glass Card: Form ──────
                                          GlassCard(
                                            padding: const EdgeInsets.all(
                                              AppConstants.paddingLarge,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Sign Up',
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

                                                // Full Name
                                                CustomTextField(
                                                  controller: _nameController,
                                                  label: 'Full Name',
                                                  hint: 'e.g. Jane Smith',
                                                  prefixIcon:
                                                      Icons.badge_outlined,
                                                  focusNode: _nameFocus,
                                                  nextFocusNode: _emailFocus,
                                                  keyboardType:
                                                      TextInputType.name,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  validator: Validators
                                                      .validateFullName,
                                                ),
                                                const SizedBox(
                                                  height: AppConstants
                                                      .paddingMedium,
                                                ),

                                                // Email
                                                CustomTextField(
                                                  controller: _emailController,
                                                  label: 'Email Address',
                                                  hint: 'you@example.com',
                                                  prefixIcon:
                                                      Icons.email_outlined,
                                                  focusNode: _emailFocus,
                                                  nextFocusNode: _passwordFocus,
                                                  keyboardType: TextInputType
                                                      .emailAddress,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  validator:
                                                      Validators.validateEmail,
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
                                                  nextFocusNode: _confirmFocus,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  isPassword: true,
                                                  validator: Validators
                                                      .validatePassword,
                                                ),
                                                const SizedBox(
                                                  height: AppConstants
                                                      .paddingMedium,
                                                ),

                                                // Confirm Password
                                                CustomTextField(
                                                  controller:
                                                      _confirmController,
                                                  label: 'Confirm Password',
                                                  hint:
                                                      'Re-enter your password',
                                                  prefixIcon:
                                                      Icons.lock_reset_rounded,
                                                  focusNode: _confirmFocus,
                                                  textInputAction:
                                                      TextInputAction.done,
                                                  isPassword: true,
                                                  validator: (v) =>
                                                      Validators.validateConfirmPassword(
                                                        v,
                                                        _passwordController
                                                            .text,
                                                      ),
                                                  onFieldSubmitted: (_) =>
                                                      _handleRegister(),
                                                ),
                                                const SizedBox(
                                                  height:
                                                      AppConstants.paddingLarge,
                                                ),

                                                // Create Account Button
                                                CustomButton(
                                                  label: 'Create Account',
                                                  onPressed: _handleRegister,
                                                  isLoading: _vm.isLoading,
                                                  icon:
                                                      Icons.person_add_rounded,
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(
                                            height: AppConstants.paddingMedium,
                                          ),

                                          // ── Back to Sign In link ──
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Already have an account?',
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.white54
                                                      : Colors.black45,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text(
                                                  'Sign In',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: scheme.primary,
                                                  ),
                                                ),
                                              ),
                                            ],
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
}
