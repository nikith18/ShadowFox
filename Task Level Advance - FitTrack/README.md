# FitTrack Pro – Smart Fitness Tracking App

> A complete, production-quality Flutter application for tracking fitness activities, visualizing statistics, and managing personalized goals — built with a premium Liquid Glass (glassmorphism) UI.

---

## Screenshots

| Splash | Home | Analytics | Goals | Profile |
|--------|------|-----------|-------|---------|
| Animated orbs + logo | Progress ring + stats | fl_chart charts | CRUD goals | BMI ring + edit form |

---

## Key Features

| Feature | Details |
|---|---|
| 🎨 Glassmorphism UI | Frosted glass cards, blur effects, gradient backgrounds |
| 📊 Analytics | Bar charts, line charts, pie charts via `fl_chart` |
| 🎯 Goals | Create, track, edit, and complete custom fitness goals |
| 📂 Dataset Mode | Parses bundled CSV fitness data – no internet needed |
| 🌙 Dark / Light Theme | Persisted across restarts via SharedPreferences |
| 🔄 60fps Animations | All animated widgets isolated with `RepaintBoundary` |
| 💾 Local Storage | SharedPreferences for all data persistence |
| 📱 Responsive Design | Works on phones, tablets, Chrome, Edge, and desktop |

---

## Screens

| Screen | Description |
|---|---|
| 🌟 Splash | Animated logo, revolving glass orbs, auto-navigates to Home |
| 🏠 Home | Dashboard with progress ring, stat cards, streak |
| 🏃 Activity | Detailed daily metrics with large progress ring |
| 🎯 Goals | Full CRUD goals list with progress bars and bottom sheet |
| 📊 Analytics | Three tabbed charts – steps, calories, activity distribution |
| 📋 History | Searchable, filterable, sortable activity log |
| 👤 Profile | BMI ring, user stats, editable profile form |
| ⚙️ Settings | Theme, units, data mode, notifications, data management |

---

## Architecture

```
lib/
├── core/
│   ├── constants/        app_constants, app_colors, app_theme
│   ├── models/           user_profile, fitness_goal, activity_record
│   ├── providers/        theme, user_profile, activity, goals, settings
│   └── services/         local_storage, dataset (CSV), fitness_calculator
├── widgets/              glass_card, animated_progress_ring, stat_card, goal_card
├── screens/              splash, home, activity, goals, analytics, history, profile, settings
├── main_shell.dart       NavigationBar shell with AnimatedSwitcher
└── main.dart             MultiProvider tree + MaterialApp + named routes
assets/
└── data/fitness_data.csv 45-day bundled fitness dataset
```

---

## Performance (60fps Architecture)

All animated and paint-heavy widgets are wrapped in `RepaintBoundary` to isolate their render layers:

| Widget | Strategy |
|---|---|
| `GlassCard` | `RepaintBoundary` around `BackdropFilter` — prevents blur from triggering parent repaints |
| `AnimatedProgressRing` | `RepaintBoundary` around `AnimatedBuilder + CustomPaint` |
| `StatCard` | `RepaintBoundary` + combined `FadeTransition + ScaleTransition` |
| Splash orbs | `RepaintBoundary` isolates the background orb loop from the foreground content |
| Loading dots | Each dot wrapped in `RepaintBoundary` |
| fl_chart widgets | Each chart `SizedBox` wrapped in `RepaintBoundary` |

Animation curves used: `easeOutCubic`, `easeOutBack`, `easeOut` — avoids expensive overdrive springs for web targets.

---

## State Management

Provider is used with a `MultiProvider` tree at the root (in `main.dart`):

| Provider | Responsibility |
|---|---|
| `ThemeProvider` | Dark/light mode with persistence |
| `UserProfileProvider` | Profile data: BMI, goals, name |
| `ActivityProvider` | History, today's stats, dataset loading, streaks |
| `GoalsProvider` | CRUD for fitness goals + progress tracking |
| `SettingsProvider` | Units, notifications, sensor/dataset toggles |

All business logic lives in providers and services — never inside widgets.

---

## Dataset Handling

Bundled `assets/data/fitness_data.csv` contains 45 days of sample fitness data. The `DatasetService` parses it safely:
- Skips malformed rows without crashing
- Missing columns fall back to safe defaults
- Loaded automatically on first launch for an immediate rich experience

---

## Data Visualization

The Analytics screen uses `fl_chart` for:
- **Bar Chart** – daily steps (last 7 days)
- **Line Chart** – monthly steps trend (30 days)
- **Pie Chart** – activity type distribution (30 days)

All charts animate on load and are isolated in `RepaintBoundary` layers.

---

## Local Storage

All data is persisted using `SharedPreferences`:

| Key | Data |
|---|---|
| `theme_mode` | Dark/light preference |
| `user_profile` | JSON-encoded UserProfile |
| `fitness_goals` | JSON list of FitnessGoal |
| `activity_history` | JSON list of ActivityRecord |
| `app_settings` | Units, notifications, mode flags |
| `streak_count` | Current activity streak |

---

## Packages

| Package | Purpose |
|---|---|
| `provider ^6.1.2` | State management |
| `shared_preferences ^2.3.2` | Local storage |
| `google_fonts ^6.2.1` | Outfit font |
| `fl_chart ^0.69.0` | Data visualization |
| `csv ^6.0.0` | CSV parsing |
| `intl ^0.19.0` | Date formatting |
| `lottie ^3.1.2` | Future animation support |

---

## How to Use

1. **Launch** – Splash plays, then auto-navigates to the Home Dashboard
2. **Home** – Shows today's steps, calories, distance, and active minutes with an animated progress ring
3. **Activity** – View detailed metrics and heart rate / sleep from the dataset
4. **Goals** – Tap **+** to create a goal; tap a goal card to edit or complete it
5. **Analytics** – Switch tabs to view Steps / Calories / Activity distribution charts
6. **History** – Search, filter by workout type, and sort results
7. **Profile** – Tap ✏️ to edit name, age, height, weight, and daily targets
8. **Settings** – Toggle theme, units, dataset mode, or sensor mode; reload or clear all data

---

## Fitness Calculations

| Metric | Formula |
|---|---|
| Calories | `MET × weight(kg) × duration(h)` – Walking 3.5, Running 8.0, Cycling 6.0 |
| Distance | `steps ÷ 1312` (avg steps/km) |
| BMI | `weight(kg) ÷ height(m)²` |
| Streak | Consecutive days with active (non-rest) workout entries |

---

## Future Enhancements

- Firebase Authentication + Cloud Firestore sync
- Real pedometer sensor integration (`sensors_plus`)
- Local push notifications (`flutter_local_notifications`)
- Google Fit / Apple Health integration
- AI-powered fitness recommendations
- Water intake, diet, and sleep tracking
- Smartwatch / Wear OS support

---

## Security Notes

- All data stays on-device; no network requests are made
- SharedPreferences is appropriate for non-sensitive profile data
- For production: migrate to encrypted storage (`flutter_secure_storage`)

---

*FitTrack Pro — built with Flutter, Provider, fl_chart, and a lot of `RepaintBoundary`.*
