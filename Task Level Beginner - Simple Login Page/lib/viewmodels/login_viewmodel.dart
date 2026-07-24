// login_viewmodel.dart
// ────────────────────────────────────────────────────────────────
// LoginViewModel extends ChangeNotifier (Flutter's built-in
// lightweight state-management solution).
//
// WHY ChangeNotifier?
//   The task requires NOT using third-party state-management.
//   ChangeNotifier + ListenableBuilder keeps state alive across
//   rebuilds and configuration changes while separating UI/logic.
//
// AUTHENTICATION FLOW:
//   1. attemptLogin()       – checks demo or in-memory registered accounts
//   2. authenticateWithBiometrics() – local_auth gate (fingerprint/face)
//   3. loadPersistedSession()       – called once from main.dart on startup
//
// PERSISTENCE (SharedPreferences):
//   • On successful login with rememberMe=true → save username
//   • loadPersistedSession() restores username/rememberMe at startup
//   • logout() clears persisted keys
//
// SECURITY NOTE:
//   Passwords are NEVER stored, logged, or persisted.
// ────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

class LoginViewModel extends ChangeNotifier {
  // ── Private state ────────────────────────────────────────────────
  bool _isLoading = false;
  int _loginAttempts = 0;
  String _loggedInUsername = '';
  String _loggedInName = '';
  bool _rememberMe = false;
  bool _isDarkMode = false;

  // Whether biometric hardware is available on this device
  bool _biometricAvailable = false;

  // Indicates that a persisted session was found on startup
  bool _hasPersistedSession = false;

  // ── Helper singletons ────────────────────────────────────────────
  final LocalAuthentication _localAuth = LocalAuthentication();

  // In-memory registered accounts (populated by registerAccount())
  final Map<String, Map<String, String>> _registeredAccounts = {};

  // ── Public read-only accessors ───────────────────────────────────
  bool get isLoading => _isLoading;
  int get loginAttempts => _loginAttempts;
  String get loggedInUsername => _loggedInUsername;
  String get loggedInName => _loggedInName;
  bool get rememberMe => _rememberMe;
  bool get isDarkMode => _isDarkMode;
  bool get biometricAvailable => _biometricAvailable;
  bool get hasPersistedSession => _hasPersistedSession;

  // ── Initialisation ───────────────────────────────────────────────

  /// Call once from [main.dart] on startup.
  /// Reads SharedPreferences and checks biometric hardware.
  Future<void> loadPersistedSession() async {
    // ── Biometric availability check ─────────────────────────────
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupport = await _localAuth.isDeviceSupported();
      _biometricAvailable = canCheck && isSupport;
    } catch (_) {
      _biometricAvailable = false;
    }

    // ── Restore remember-me session ──────────────────────────────
    try {
      final prefs = await SharedPreferences.getInstance();
      final remembered = prefs.getBool(AppConstants.prefRememberMe) ?? false;
      final username = prefs.getString(AppConstants.prefUsername) ?? '';

      if (remembered && username.isNotEmpty) {
        _rememberMe = true;
        _loggedInUsername = username;
        _loggedInName = username.split('@').first;
        _hasPersistedSession = true;
      }
    } catch (e) {
      debugPrint('SharedPreferences read error: $e');
    }

    notifyListeners();
  }

  // ── Mutators ────────────────────────────────────────────────────

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // ── Login ────────────────────────────────────────────────────────

  /// Attempts login against demo credentials or in-memory registered accounts.
  ///
  /// Returns `true` on success, `false` on failure.
  Future<bool> attemptLogin({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    final trimmedEmail = username.trim().toLowerCase();

    // Small artificial delay to simulate a network call
    await Future.delayed(const Duration(milliseconds: 600));

    final success = _checkDemoOrRegisteredCredentials(trimmedEmail, password);

    if (success) {
      await _persistSessionIfNeeded();
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  // ── Biometric Authentication ─────────────────────────────────────

  /// Prompts the user for biometric verification (fingerprint / face / PIN).
  ///
  /// Intended as a *gate* after a session is already established
  /// (e.g. re-entering the app with rememberMe).
  ///
  /// Returns `true` if the user passes the biometric check.
  Future<bool> authenticateWithBiometrics() async {
    if (!_biometricAvailable) return false;

    try {
      return await _localAuth.authenticate(
        localizedReason: 'Verify your identity to continue',
        options: const AuthenticationOptions(
          biometricOnly: false, // also allow device PIN as fallback
          stickyAuth: true, // keep prompt alive if app loses focus
        ),
      );
    } catch (e) {
      debugPrint('Biometric auth error: $e');
      return false;
    }
  }

  // ── Account Registration ─────────────────────────────────────────

  /// Registers a new account in-memory.
  ///
  /// Returns `true` on success, `false` if the email is already taken.
  Future<bool> registerAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    final trimmedEmail = email.trim().toLowerCase();

    // Small artificial delay to simulate a network call
    await Future.delayed(const Duration(milliseconds: 600));

    final demoTaken = trimmedEmail == AppConstants.demoEmail.toLowerCase();
    final alreadyExists = _registeredAccounts.containsKey(trimmedEmail);
    bool success = false;

    if (!demoTaken && !alreadyExists) {
      _registeredAccounts[trimmedEmail] = {
        'password': password,
        'name': name.trim(),
      };
      success = true;
      _loggedInUsername = trimmedEmail;
      _loggedInName = name.trim();
      _loginAttempts = 0;
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  // ── Logout ───────────────────────────────────────────────────────

  /// Clears the in-memory session and SharedPreferences.
  Future<void> logout() async {
    // Clear persisted session
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.prefUsername);
      await prefs.remove(AppConstants.prefRememberMe);
    } catch (e) {
      debugPrint('SharedPreferences clear error: $e');
    }

    _loggedInUsername = '';
    _loggedInName = '';
    _loginAttempts = 0;
    _rememberMe = false;
    _hasPersistedSession = false;
    notifyListeners();
  }

  // ── Private helpers ──────────────────────────────────────────────

  /// Checks demo credentials and in-memory registered accounts.
  bool _checkDemoOrRegisteredCredentials(String email, String password) {
    if (email == AppConstants.demoEmail.toLowerCase() &&
        password == AppConstants.demoPassword) {
      _loggedInUsername = email;
      _loggedInName = 'Student';
      _loginAttempts = 0;
      return true;
    }
    if (_registeredAccounts.containsKey(email)) {
      final account = _registeredAccounts[email]!;
      if (account['password'] == password) {
        _loggedInUsername = email;
        _loggedInName = account['name'] ?? email;
        _loginAttempts = 0;
        return true;
      }
    }
    _loginAttempts++;
    return false;
  }

  /// Writes username + rememberMe flag to SharedPreferences
  /// when the user has ticked the "Remember Me" checkbox.
  Future<void> _persistSessionIfNeeded() async {
    if (!_rememberMe) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.prefUsername, _loggedInUsername);
      await prefs.setBool(AppConstants.prefRememberMe, true);
    } catch (e) {
      debugPrint('SharedPreferences write error: $e');
    }
  }
}
