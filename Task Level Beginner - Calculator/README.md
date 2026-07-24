# Smart Modern Calculator 🧮

A **production-quality Flutter Android Calculator** featuring a liquid-glass / glassmorphism UI, animated dark/light theme, clean architecture with Provider state management, and comprehensive input validation.

---

## Project Overview

Smart Modern Calculator is a fully-featured, beautifully designed mobile calculator application built with Flutter. It demonstrates professional Flutter development practices including clean architecture, responsive layouts, smooth animations, persistent theme preferences, and robust error handling — making it an ideal portfolio or learning project.

---

## Features

| Category | Details |
|---|---|
| **Operations** | +, −, ×, ÷, %, decimal, ±, AC, ⌫ |
| **Display** | Live expression + animated result preview |
| **UI** | Glassmorphism, gradient background, accent blobs |
| **Theme** | Animated dark ↔ light toggle, persisted via SharedPreferences |
| **Responsive** | Portrait, landscape, phone, tablet |
| **State** | Provider + ChangeNotifier, immutable state |
| **Validation** | Full input state machine — no crashes |
| **Animation** | Scale buttons, AnimatedSwitcher display, AnimatedTheme |
| **Lifecycle** | WidgetsBindingObserver with all 5 states |

---

## Screenshots

> _Run the app and take screenshots here._
> 
> | Dark Mode | Light Mode | Landscape |
> |---|---|---|
> | _(screenshot)_ | _(screenshot)_ | _(screenshot)_ |

---

## Folder Structure

```
lib/
├── main.dart               # Entry point, MultiProvider, LifecycleObserver
├── app/
│   ├── app.dart            # MaterialApp with animated themes
│   └── theme/
│       └── app_theme.dart  # Light & Dark ThemeData (Material 3)
├── constants/
│   ├── app_colors.dart     # All colour constants
│   ├── app_sizes.dart      # Spacing, radii, breakpoints
│   └── app_typography.dart # Font sizes & weights
├── models/
│   └── calculator_state.dart   # Immutable state + ButtonType enum
├── providers/
│   ├── calculator_provider.dart # State machine + business logic
│   └── theme_provider.dart      # Dark/light toggle + persistence
├── services/
│   ├── calculator_service.dart  # Expression evaluator (math_expressions)
│   └── preference_service.dart  # SharedPreferences wrapper
├── screens/
│   └── calculator_screen.dart   # Main screen, portrait/landscape layouts
└── widgets/
    ├── calc_button.dart     # Animated, typed calculator button
    ├── display_screen.dart  # Expression + result with AnimatedSwitcher
    ├── glass_card.dart      # BackdropFilter glassmorphism card
    └── theme_toggle.dart    # Animated sliding toggle for AppBar
```

---

## Architecture

The app uses **Provider + ChangeNotifier** with a **unidirectional data flow**:

```
UI Widget
  └─▶  calls provider method (e.g. onButtonPressed)
         └─▶  CalculatorProvider updates CalculatorState
                └─▶  notifyListeners()
                       └─▶  Consumer/context.watch rebuilds affected widgets
```

Business logic lives exclusively in providers and services — **zero logic in widgets**.

---

## State Management

`CalculatorProvider` maintains an immutable `CalculatorState` with flags:

| Flag | Purpose |
|---|---|
| `isLastInputOperator` | Prevents consecutive operators |
| `isLastInputDigit` | Tracks last character type |
| `hasDot` | Prevents multiple decimals per number |
| `justEvaluated` | Handles post-`=` input correctly |

Live result preview: after every digit input, `CalculatorService.evaluate()` is called and `result` is updated immediately.

---

## Input Validation

The state machine silently rejects:
- Consecutive operators (`5++3`)
- Multiple decimals (`1..5`)
- Leading operators on empty expression
- Starting with zero padding (`00123`)

Delete re-evaluates the `hasDot` flag by scanning the current number segment.

---

## Error Handling

`CalculatorService.evaluate()` catches all exceptions and returns user-friendly strings:

| Condition | Display |
|---|---|
| Division by zero | `Cannot divide by zero` |
| Invalid expression | `Invalid Expression` |
| Number too large | `Overflow` |
| Any parse error | `Error` |

The result text turns **red** for any error state.

---

## Theme System

- `ThemeProvider` holds the `isDarkMode` boolean and calls `notifyListeners()` on toggle.
- `PreferenceService` persists the preference with `SharedPreferences`.
- `MaterialApp` uses `theme` / `darkTheme` + `themeMode` with a **400 ms animation**.
- On first launch, dark mode is the default.

---

## Responsive Design

`LayoutBuilder` inside `CalculatorScreen` checks:
- `constraints.maxWidth > constraints.maxHeight` → **Landscape** layout (display left, buttons right)
- `constraints.maxWidth >= 600` → **Tablet** layout (constrains max width to 480 dp)
- Otherwise → **Portrait** layout (display top, buttons bottom)

All buttons use `Expanded` + `AspectRatio` so they fill available space without hardcoded dimensions. `FittedBox` auto-scales button text and result numbers.

---

## Animations

| Animation | Widget | Trigger |
|---|---|---|
| Button press scale | `AnimatedController` + `ScaleTransition` | `GestureDetector.onTapDown` |
| Expression fade/slide | `AnimatedSwitcher` | Expression text changes |
| Result slide/fade | `AnimatedSwitcher` + `SlideTransition` | Result value changes |
| Theme transition | `MaterialApp.themeAnimationDuration` | Theme toggle |
| Background gradient | `AnimatedContainer` | Theme toggle |
| Theme toggle thumb | `AnimatedPositioned` + `AnimatedContainer` | Theme toggle |
| Theme toggle icon | `AnimatedSwitcher` | Theme toggle |

---

## Lifecycle Handling

`_LifecycleWrapperState` implements `WidgetsBindingObserver`:

| State | Meaning |
|---|---|
| `resumed` | App is foreground and interactive |
| `inactive` | App is partially obscured |
| `paused` | App sent to background |
| `hidden` | Hidden in multi-window environments |
| `detached` | Process terminating |

---

## How to Use

1. Launch the app.
2. Enter numbers using the on-screen buttons.
3. Tap an operator (+, −, ×, ÷).
4. Enter the next number.
5. Press **=** to calculate.
6. Press **AC** to clear everything.
7. Press **⌫** to delete the last character; **long-press ⌫** to clear all.
8. Press **±** to toggle positive/negative.
9. Press **%** to calculate percentage.
10. Tap the toggle in the top-right corner to switch between Dark and Light modes.
11. Your chosen theme is automatically saved and restored on next launch.

---

## Future Improvements

- 📐 **Scientific Calculator** – sin, cos, tan, log, sqrt, power, factorial
- 🎙 **Voice Commands** – "Five plus ten equals"
- 📋 **Calculation History** – Scrollable list of past calculations
- 💾 **Memory Functions** – M+, M−, MR, MC
- 🔄 **Unit Converter** – Length, weight, temperature
- 💱 **Currency Converter** – Live exchange rates
- 📳 **Haptic Feedback** – Custom vibration patterns per button type
- 🎨 **Custom Themes** – User-defined accent colours
- 🌐 **Multi-Language** – Localised number formats

---

## Dependencies

| Package | Purpose |
|---|---|
| `provider ^6.1.2` | State management |
| `shared_preferences ^2.3.2` | Theme persistence |
| `math_expressions ^2.6.0` | Safe expression evaluation |

---

## Learning Concepts Demonstrated

- **Flutter Widgets** – Custom reusable widgets, StatefulWidget lifecycle
- **Responsive Layouts** – `LayoutBuilder`, `Expanded`, `AspectRatio`, `FittedBox`
- **State Management** – Provider, ChangeNotifier, immutable state pattern
- **Event Handling** – GestureDetector, button dispatch, long-press
- **Animation** – AnimationController, AnimatedSwitcher, AnimatedContainer, ScaleTransition
- **Theme Management** – MaterialApp light/dark themes, animated transitions
- **Error Handling** – Try-catch, user-friendly messages, defensive UI rendering
- **Lifecycle Management** – WidgetsBindingObserver, all lifecycle states
- **Clean Architecture** – Separated concerns: models, services, providers, widgets
- **Professional UI** – Glassmorphism, gradient backgrounds, micro-interactions
