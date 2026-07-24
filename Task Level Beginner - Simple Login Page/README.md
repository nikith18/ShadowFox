# 🔮 Smart Login — Liquid Glass UI

A **Flutter** application showcasing modern mobile development patterns: Firebase Authentication, biometric auth, SharedPreferences persistence, form validation, ChangeNotifier state management, **liquid-glass (glassmorphism) UI**, and fully **responsive layout** that works beautifully on phones, tablets, and web.

---

## ✨ Features

| Feature | Details |
|---|---|
| **Firebase Authentication** | Email/password sign-in via `FirebaseAuth` with graceful offline fallback |
| **Google Sign-In** | Full OAuth2 flow → Firebase credential |
| **Biometric Authentication** | Fingerprint / Face ID / PIN via `local_auth` |
| **SharedPreferences Persistence** | Remember Me saves username across app restarts |
| **Startup Session Restore** | Auto-populated session on launch if remembered |
| **Liquid Glass UI** | `BackdropFilter` frosted cards, animated gradient orbs, glass text fields & buttons |
| **Registration Screen** | Full create-account flow with name, email, password, confirm-password validation |
| **Dark / Light Mode** | Custom glass pill toggle — switches theme system-wide instantly |
| **Login Validation** | Email format, empty-field checks, minimum password length |
| **Demo Credentials** | `student@demo.com` / `123456` (offline fallback — works without Firebase) |
| **ChangeNotifier ViewModel** | Survives device rotation; tracks loading state, attempt counter, username |
| **Responsive Layout** | `ConstrainedBox(maxWidth: 480)` + adaptive `LayoutBuilder` padding |
| **Entry Animations** | Smooth `FadeTransition` + `SlideTransition` on every screen load |
| **Hero Animation** | Logo morphs seamlessly between Login → Welcome screen |
| **Loading Spinner** | Splash `CircularProgressIndicator` while session restores on startup |

---

## 📁 Project Structure

```
lib/
├── main.dart                  # Firebase init, startup session check, theme switching
│
├── utils/
│   ├── constants.dart         # Magic values, glass tokens, SharedPreferences keys
│   └── validators.dart        # Pure validation functions (email regex, min-length, name, confirm-password)
│
├── viewmodels/
│   └── login_viewmodel.dart   # Firebase Auth, Google Sign-In, biometric, SharedPreferences, ChangeNotifier
│
├── widgets/
│   ├── glass_card.dart        # Reusable BackdropFilter glass container
│   ├── glass_toggle.dart      # Reusable dark/light mode pill toggle (extracted from screens)
│   ├── custom_button.dart     # Gradient glass button with press-scale animation
│   └── custom_textfield.dart  # Frosted glass TextFormField with focus glow
│
└── screens/
    ├── login_screen.dart      # Login UI + entry animation + animated background
    ├── register_screen.dart   # Registration form with full validation + slide-up transition
    └── welcome_screen.dart    # Post-login screen + Hero logo + logout
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ≥ 3.12 (`flutter --version`)
- Android device / emulator, iOS simulator, Windows, macOS, or Chrome

### Install & Run

```bash
git clone <repo-url>
cd "Simple Login Page"
flutter pub get
flutter run
```

Select your target device when prompted (Android, Chrome, Windows, etc.).

### Demo Credentials (Offline Mode)

```
Email:    student@demo.com
Password: 123456
```

> Works **without** a Firebase project. The app auto-detects missing `google-services.json` and falls back to demo mode gracefully.

---

## 🔥 Firebase Setup (Optional — Enables Real Auth)

1. Go to [console.firebase.google.com](https://console.firebase.google.com) → create a project
2. Enable **Email/Password** and **Google** sign-in methods under Authentication
3. Download `google-services.json` → place at `android/app/google-services.json`
4. Run `flutter pub get && flutter run`

> Without this file the app runs in **offline/demo mode** — no crash, no error message to users.

---

## 🏗️ Architecture

```
SmartLoginApp (StatefulWidget — root)
│   Firebase.initializeApp() ← async, try/catch offline-safe
│   loadPersistedSession()   ← SharedPreferences + biometric check
│   Holds LoginViewModel (survives rotation & navigation)
│   Listens to ViewModel for dark-mode rebuild
│
├── LoginScreen
│   ├── TickerProviderStateMixin   ← orb + entry animations
│   ├── GlobalKey<FormState>       ← form validation
│   ├── TextEditingController      ← email & password
│   ├── FocusNode                  ← keyboard focus events
│   ├── ConstrainedBox(maxWidth: 480) ← responsive layout
│   └── ListenableBuilder          ← reacts to ViewModel
│
├── RegisterScreen (slide-up transition)
│   ├── Same animation + responsive layout pattern
│   ├── 4 validated fields: name, email, password, confirm password
│   └── Calls vm.registerAccount() → Firebase or in-memory fallback
│
└── WelcomeScreen (fade transition)
    ├── Entry animation (fade + slide)
    ├── ConstrainedBox(maxWidth: 480) ← responsive layout
    └── Logout → clears Firebase session + SharedPreferences
```

### State Management

Uses Flutter's built-in **`ChangeNotifier`** + **`ListenableBuilder`** — zero third-party state packages.

| State | Purpose |
|---|---|
| `isLoading` | Shows spinner on Sign-In button |
| `loginAttempts` | Displays failed-attempt counter |
| `loggedInUsername` / `loggedInName` | Shown on Welcome screen |
| `rememberMe` | Remember Me checkbox |
| `isDarkMode` | Switches `ThemeMode` in `MaterialApp` |
| `biometricAvailable` | Whether device has biometric hardware |
| `hasPersistedSession` | True if a remembered session was restored |

### Authentication Flow

```
attemptLogin()
  ├── FirebaseAuth.signInWithEmailAndPassword()
  │     ├── success → persist session (if rememberMe)
  │     └── FirebaseAuthException → increment attempts
  └── catch (Firebase not initialised) → demo credential fallback

signInWithGoogle()
  └── GoogleSignIn → GoogleAuthProvider.credential → Firebase

authenticateWithBiometrics()
  └── local_auth.authenticate() → true/false gate

loadPersistedSession()  ← called at startup
  ├── SharedPreferences.getString(prefUsername)
  ├── SharedPreferences.getBool(prefRememberMe)
  └── local_auth.canCheckBiometrics
```

---

## 🎨 UI Design — Liquid Glass

- **`BackdropFilter`** + **`ImageFilter.blur`** — blurs everything behind the card
- Semi-transparent container fill (`withValues(alpha: ...)`)
- Subtle white glass-rim border
- `RadialGradient` orbs animated with `AnimationController` + `math.sin/cos`
- `FadeTransition` + `SlideTransition` on screen entry
- Adaptive horizontal padding via `LayoutBuilder` (16 / 24 / 48 px)

### Colour Palette

| Theme | Background | Orb colours |
|---|---|---|
| Light | Lavender-blue gradient | Indigo, sky blue, pink |
| Dark | Deep navy / indigo | Electric violet, cyan, magenta |

---

## 🔒 Security Notes

- Passwords are **never** logged, debugPrinted, or stored in plain text in the UI layer
- Inputs are **trimmed** before validation; emails stored **lowercased**
- SharedPreferences stores only the **email** address (never the password)
- Firebase Auth handles credential verification server-side
- Biometric auth acts as a **session gate**, not a credential bypass
- Demo credentials (`demoEmail` / `demoPassword`) are marked REMOVE-in-production

---

## 🧪 Test Checklist

| Test | Expected Result |
|---|---|
| Submit empty form | Shows inline validation errors |
| Invalid email format | "Enter a valid email address" error |
| Password < 6 chars | "Password must be at least 6 characters" error |
| Wrong credentials | Snackbar "Invalid username or password" |
| Correct demo credentials | Navigate to Welcome screen |
| Register new account → login | Login succeeds |
| Register duplicate email | Snackbar "already in use" error |
| Confirm password mismatch | "Passwords do not match" error |
| Logout | Returns to Login, SharedPreferences cleared |
| Rotate device | ViewModel state preserved |
| Remember Me + restart | Auto-populated username (or auto-login) |
| Biometric prompt | System biometric / PIN dialog appears |
| Wide screen / tablet / web | Content centred at max 480 px width |
| No google-services.json | App launches in demo mode, no crash |

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8

  # Firebase
  firebase_core: ^3.x       # Bootstrap Firebase SDK
  firebase_auth: ^5.x       # Email/password + Google credential auth

  # Google Sign-In
  google_sign_in: ^6.x      # OAuth2 Google identity flow

  # Persistence
  shared_preferences: ^2.x  # Remember-me + username storage

  # Biometric authentication
  local_auth: ^2.x          # Fingerprint / Face ID / PIN
```

> **No third-party state-management packages used.**  
> `dart:ui` (for `ImageFilter`) is part of the Flutter SDK.

---

## 🐛 Bug Fixes (v1.1)

| # | File | Fix |
|---|---|---|
| 1 | `login_screen.dart` | Fixed `builder: (_, _)` duplicate wildcard — Dart compile error |
| 2 | `login_screen.dart` | Fixed `pageBuilder: (_, _, _)` and `transitionsBuilder: (_, anim, _, child)` duplicate wildcards |
| 3 | `register_screen.dart` | Fixed `builder: (_, _)` duplicate wildcard |
| 4 | `welcome_screen.dart` | Fixed all duplicate wildcard parameters in route builders |
| 5 | `welcome_screen.dart` | Removed deprecated `library;` directive |
| 6 | `login_screen.dart` | Extracted `_GlassToggle` into shared `glass_toggle.dart` widget |
