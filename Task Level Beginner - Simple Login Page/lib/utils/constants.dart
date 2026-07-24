// constants.dart
// ────────────────────────────────────────────────────────────────
// Central place for every "magic value" in the app.
// Changing a value here propagates everywhere—no hunting.
//
// AUTHENTICATION STRATEGY:
//   Firebase Authentication is the primary auth provider.
//   - Email/password sign-in via FirebaseAuth.instance
//   - Google Sign-In via GoogleSignIn + FirebaseAuth credential
//   - Biometric gate via local_auth (fingerprint / Face ID / PIN)
//
//   The demoEmail/demoPassword below serve as an OFFLINE FALLBACK only.
//   They are used when Firebase is not initialised (e.g. missing
//   google-services.json during development). In a production build
//   remove them and rely solely on Firebase Auth.
//
// SETUP CHECKLIST (Firebase):
//   1. Create a project at https://console.firebase.google.com
//   2. Enable "Email/Password" and "Google" sign-in methods
//   3. Download google-services.json → android/app/google-services.json
//   4. Run: flutter pub get
// ────────────────────────────────────────────────────────────────

class AppConstants {
  AppConstants._(); // private constructor – utility class, not instantiated

  // ── Offline / demo credentials ──────────────────────────────────
  // Used as a fallback when Firebase is not configured.
  // REMOVE in production.
  static const String demoEmail = 'student@demo.com';
  static const String demoPassword = '123456';

  // ── Route names (for named-route navigation if added later) ──────
  static const String routeLogin = '/';
  static const String routeWelcome = '/welcome';

  // ── App meta ─────────────────────────────────────────────────────
  static const String appName = 'Simple Login Page';
  static const String appTagline = 'Your gateway to learning';

  // ── UI dimensions ─────────────────────────────────────────────────
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXL = 32.0;

  static const double borderRadius = 20.0; // bigger radius for liquid feel
  static const double buttonHeight = 54.0;
  static const double logoSize = 96.0;

  // ── Liquid Glass tokens ──────────────────────────────────────────
  static const double glassBlur = 28.0; // BackdropFilter sigma
  static const double glassOpacity = 0.15; // container fill alpha
  static const double glassBorder = 1.0; // border width

  // ── Durations ────────────────────────────────────────────────────
  static const Duration loginDelay = Duration(milliseconds: 1200);
  static const Duration heroDuration = Duration(milliseconds: 500);

  // ── SharedPreferences keys ───────────────────────────────────────
  static const String prefUsername = 'pref_username';
  static const String prefRememberMe = 'pref_remember_me';
}
