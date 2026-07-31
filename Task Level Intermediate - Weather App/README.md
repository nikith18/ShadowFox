# Weather App

![Cover Image](https://images.unsplash.com/photo-1592210454359-9043f067919b?w=800&q=80)  
*A comprehensive Flutter project demonstrating clean architecture, API integration, and responsive glassmorphism UI.*

---

## 🌪 Overview
A fully-featured, cross-platform weather application built with Flutter. It provides real-time current weather conditions alongside hourly and 7-day forecasting. 

This project utilizes the **Open-Meteo API**—an open-source weather API that requires no API keys, removing configuration overhead while providing highly accurate, localized forecasts and geocoding.

### ✨ Key Features
- **Open-Meteo Integration**: Fetches current weather, 7-day daily max/min forecasts, and 24-hour hourly projections using a single, efficient request without API Keys.
- **Advanced Visualizations**: 
  - **Dynamic 3D Sun Path**: Renders the sun's trajectory as a glowing curve matching the precise location's timezone layout for Sunrise/Sunset bounds.
  - **Temperature Trend Chart**: A smooth custom Bézier curve tracing the 12-hour future fluctuation in temperatures.
- **AI-Driven Contextual Insights**: Interprets active weather models to give human-readable conclusions (e.g. "Wind chill makes it feel colder than it is").
- **Offline & Persistence Mode**: Disconnected users retain full UI functionality displaying the last known cached data block safely stored in SharedPreferences.
- **Live Geocoding**: Real-time city search powered by Open-Meteo's Geocoding + BigDataCloud reverse geocoding providing human-readable localities.
- **Glassmorphism UI Framework**: A premium liquid-glass aesthetic combining `BackdropFilter` layers, crisp borders, and physics-based scaling physics on user interaction (tap & hover).
- **Personalization**: Contains an instant-conversion `SettingsProvider` for toggling exact mathematical UI updates between °C and °F entirely in-memory, alongside an accessibility profile for "Reduced Motion".

---

## 🏗 Architecture & Stack
- **Framework**: Flutter (SDK `^3.12.2`)
- **State Management**: `provider` 
- **API Setup**: `http` (Open-Meteo `/v1/forecast` & `/v1/search`)
- **Location**: `geolocator`
- **Persistence**: `shared_preferences` (Theme state saving)

## 🚀 Getting Started

### 1. Prerequisites
Ensure you have the Flutter SDK installed and environment set up for your target platform (Android / iOS / Web / Desktop).

### 2. Installation
Clone the repository, then retrieve all dependencies:
```bash
flutter pub get
```

### 3. Run the App
**No API Key Configuration Needed!** Because the app runs on Open-Meteo, you do not need to configure an `.env` file or provide authorization tokens.

To run on Chrome (Web):
```bash
flutter run -d chrome
```

To run on an Android Emulator or connected device:
```bash
flutter run -d android
```

---

## 📂 Project Structure
```
lib/
├── main.dart                   # Entry point, Provider initialization
├── models/
│   ├── weather_model.dart      # Current weather condition parsing
│   ├── forecast_model.dart     # Daily/Hourly weather parsing
│   └── location_model.dart     # Geocoding result data model
├── providers/
│   ├── weather_provider.dart   # Search context, API calling, Error tracking
│   └── theme_provider.dart     # Dark/Light mode tracking & storage
├── screens/
│   └── home_screen.dart        # Main animated dashboard & responsive layout
├── services/
│   ├── weather_service.dart    # Open-Meteo HTTP fetch logic
│   └── location_service.dart   # Geolocator GPS & Geocoding implementation
├── theme/
│   └── app_theme.dart          # Base material theme constants
├── utils/
│   ├── constants.dart          # API Endpoint URLs
│   └── weather_utils.dart      # WMO condition strings, icons, & gradient maps
└── widgets/
    ├── glass_card.dart         # Reusable backdrop filter widget
    ├── empty_state.dart        # Initial app view
    ├── error_state.dart        # Unified error handling view
    ├── loading_shimmer.dart    # Fake skeleton data while loading
    ├── search_bar_widget.dart  # Typeahead geocoding input
    └── [weather cards]         # Component breakdown of UI data
```

---

## 💡 Technical Highlights
- **WMO Code Mapping**: Open-Meteo outputs standard WMO (World Meteorological Organization) weather codes. `weather_utils.dart` comprehensively maps these into condition strings, icons, and dynamic gradients.
- **Debounced Searching**: When typing into the search bar, the app employs a `Timer()` debounce to prevent spamming the geocoding endpoint, keeping UI rendering smooth and API rate limits secure.
- **Graceful Degradation**: If Location Services are permanently denied or fail on an unsupported platform (e.g., Linux/Web without permissions), the `ErrorStateWidget` safely catches the error and instructs the user to use the manual text search instead. 


