// validators.dart
// ────────────────────────────────────────────────────────────────
// Pure functions for form validation.
// Returning null  → field is valid.
// Returning String → error message shown below the field.
//
// Keeping validation here (not inside widgets) satisfies the
// Single-Responsibility Principle and makes unit-testing easy.
//
// SECURITY NOTE:
//   Input is trimmed before validation to prevent whitespace-only
//   submissions. The email regex is a reasonable client-side check,
//   but the authoritative validation happens on the backend.
//   SQL Injection prevention is entirely a *backend* responsibility
//   (parameterised queries / ORM). Never trust client-side alone.
// ────────────────────────────────────────────────────────────────

class Validators {
  Validators._(); // utility class

  // Simple RFC-5322-inspired regex for email format checking.
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  /// Validates the username / email field.
  /// - Must not be empty after trimming.
  /// - If it contains '@', it must match the email format.
  static String? validateUsernameOrEmail(String? value) {
    final trimmed = value?.trim() ?? '';

    if (trimmed.isEmpty) {
      return 'Username or email cannot be empty.';
    }

    // If the user typed something that looks like an email, validate its format.
    if (trimmed.contains('@') && !_emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address.';
    }

    return null; // valid
  }

  /// Validates the password field.
  /// - Must not be empty.
  /// - Minimum 6 characters (matches the dummy credential length).
  ///
  /// NOTE: Password is intentionally never logged or printed anywhere.
  static String? validatePassword(String? value) {
    // Do NOT trim passwords – leading/trailing spaces are intentional chars.
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Password cannot be empty.';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    return null; // valid
  }

  /// Validates a full name field.
  /// - Must not be empty after trimming.
  /// - Minimum 2 characters.
  static String? validateFullName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Full name cannot be empty.';
    if (trimmed.length < 2) return 'Name must be at least 2 characters.';
    return null;
  }

  /// Validates an email field (strict – must always be email format).
  static String? validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Email cannot be empty.';
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  /// Validates the confirm-password field.
  /// [original] is the value of the primary password field.
  static String? validateConfirmPassword(String? value, String original) {
    final password = value ?? '';
    if (password.isEmpty) return 'Please confirm your password.';
    if (password != original) return 'Passwords do not match.';
    return null;
  }
}
