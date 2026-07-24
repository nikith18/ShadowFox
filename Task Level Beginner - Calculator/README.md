# SmartCalc

SmartCalc is a modern Flutter calculator with a responsive glass-style interface, reliable expression evaluation, scientific functions, animated themes, and touch-friendly controls.

The application is designed for phones, tablets, desktop windows, and web browsers. Its layout adapts automatically to portrait, landscape, and wide-screen environments.

## Highlights

- Basic arithmetic: addition, subtraction, multiplication, division, percentages, decimals, and sign switching.
- Scientific mode: sine, cosine, tangent, logarithm, natural logarithm, square root, square, and factorial.
- Live result preview while entering an expression.
- Clear, delete, long-press delete, and error-safe input handling.
- Physical keyboard support for desktop users.
- Copy-answer action from the result display.
- Animated dark and light themes with saved preferences.
- Touch feedback, haptic feedback, tooltips, and accessible labels.
- Responsive layouts for Android, iOS, Windows, macOS, Linux, and the web.

## User experience

The interface uses a layered gradient background, translucent cards, rounded calculator keys, animated result transitions, and a focused visual hierarchy. On smaller screens the display is placed above the keypad. On wide or landscape screens the display and keypad are arranged side by side.

The Scientific control adds advanced functions without overwhelming the compact phone layout. The theme control preserves the selected appearance between launches.

## Supported operations

| Group | Operations |
| --- | --- |
| Arithmetic | `+`, `−`, `×`, `÷` |
| Input | Decimal point, percentage, positive/negative toggle |
| Controls | Clear all, delete, long-press delete, equals |
| Scientific | `sin`, `cos`, `tan`, `log`, `ln`, `sqrt`, square, factorial |

## Architecture

SmartCalc follows a simple layered architecture:

- **Screens** compose the responsive application layout.
- **Widgets** provide reusable display, keypad, glass-card, and theme controls.
- **CalculatorProvider** owns the input state machine and notifies the interface when state changes.
- **CalculatorService** normalizes display operators, evaluates expressions, formats results, and handles percentages.
- **PreferenceService** persists the selected theme.
- **CalculatorState** stores the immutable display and input flags.

The UI sends user actions to the provider. The provider updates the state and delegates mathematical evaluation to the service. This keeps presentation, input rules, and calculation logic separate.

## Input behavior

The calculator protects users from common input mistakes by:

- Replacing an operator when another operator is selected.
- Preventing duplicate decimal points in the current number.
- Supporting negative numbers at the beginning of an expression.
- Handling incomplete expressions during live preview.
- Starting a fresh expression after a completed result when a number is entered.
- Preserving the scientific-mode selection when the calculator is cleared.

## Error handling

Invalid or unsafe expressions never crash the application. The calculation service returns a readable result for each condition:

| Condition | Displayed result |
| --- | --- |
| Division by zero | Cannot divide by zero |
| Invalid expression | Invalid expression |
| Excessively large number | Overflow |
| Parser failure | Error |

Error results are highlighted in the display so they are easy to identify.

## Responsive design

The calculator uses constraint-based layout rules instead of fixed device dimensions:

- Compact screens use a stacked display-and-keypad layout.
- Wide screens and landscape orientation use a split display-and-keypad layout.
- The main content has a readable maximum width on large monitors.
- Key proportions adapt to the available height and width.
- The keypad remains scrollable when scientific mode needs additional rows.
- Controls maintain touch-safe hit areas across mobile and desktop devices.

## Project organization

| Location | Responsibility |
| --- | --- |
| `lib/main.dart` | Application startup and lifecycle observer |
| `lib/app` | Material application configuration and themes |
| `lib/constants` | Shared colors, spacing, sizing, and typography |
| `lib/models` | Immutable calculator state and button types |
| `lib/providers` | Calculator and theme state management |
| `lib/services` | Expression evaluation and preference persistence |
| `lib/screens` | Main responsive calculator screen |
| `lib/widgets` | Reusable calculator interface components |
| `test` | Calculation and interaction tests |

## Dependencies

| Package | Purpose |
| --- | --- |
| Provider | State management with `ChangeNotifier` |
| Shared Preferences | Persistent theme selection |
| Math Expressions | Safe mathematical expression parsing and evaluation |
| Flutter Material and Cupertino icons | Cross-platform interface icons |

## Quality coverage

The test suite covers arithmetic precedence, display operators, incomplete expressions, percentages, scientific functions, provider state transitions, decimal and delete behavior, sign switching, and real calculator button taps.

## Possible future enhancements

- Calculation history.
- Memory functions.
- Unit conversion.
- Custom accent themes.
- Localized number formats.
- Optional voice-input interface.
