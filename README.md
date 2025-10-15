# 🌤️ Weather App

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Build](https://img.shields.io/badge/build-passing-brightgreen)
![Last Commit](https://img.shields.io/github/last-commit/Muzaffar47/weather-app)
![License](https://img.shields.io/github/license/Muzaffar47/weather-app)

A secure, cross-platform Flutter mobile app that provides real-time weather data with a focus on modern Interactive UI/UX, sophisticated data visualization, and advanced location management.

---

## 💡 Project Goal

The primary goal was to build a visually impressive weather utility demonstrating advanced Flutter techniques, including custom Glassmorphism UI, performance-optimized Charts, and robust API integration. The application acts as a showcase of a feature-complete, production-ready frontend design.

---

## ✨ Key Features & Functionalities

### 📊 Visualization & Data Interactivity

- ✅ **Interactive Line Chart:** Displays the hourly temperature forecast as a responsive line graph (fl_chart). Features a persistent tooltip that shows the temperature and time when a specific data point is selected.

- ✅ **Dynamic Backgrounds:** Background gradients change instantly based on the current weather condition (e.g., sunny blue, stormy deep blue) for an immersive experience.

- ✅ **Glassmorphism Panel:** The "Additional Info" panel (Humidity, Pressure, etc.) uses a custom, blurred BackdropFilter effect to provide a modern, frosted glass look.

- ✅ **Rotational Wind Direction:** The wind icon dynamically rotates to visually indicate the precise wind direction (in degrees) fetched from the API.

### 🔍 Location & Core Utility

- ✅ **Live City Search & Autocomplete:** Implements a debounced search feature that uses the OpenWeatherMap Geocoding API to provide real-time suggestions as the user types.

- ✅ **Search History:** Automatically saves recently searched cities locally (shared_preferences) for quick access via a dedicated list.

- ✅ **UI Contrast Enforcement:** AppBar title and icons are explicitly set to Colors.white to ensure maximum visibility and readability against any dynamic background gradient.

- ✅ **Time Format Consistency:** Last updated time is displayed in a user-friendly AM/PM format.

### 🔒 Security & Project Structure

- ✅ **API Key Separation:** The OpenWeatherMap API key is stored externally in a .env file and accessed via Dart's environment variables, ensuring it is never exposed in the public Git repository.

- ✅ **Modular Architecture:** The project utilizes a clean lib/ structure separating models, services, providers, screens, and widgets for maintainability.

---

## 🧰 Tech Stack

- **Frontend:** Flutter (Dart)

- **State Management:** Provider

- **Networking:** `http`

- **Persistence:** `shared_preferences`

- **Utilities:** `fl_chart`, `geolocator`, `weather_icons`, `intl`

---

## Getting Started

### 1. Secure Setup (API Key)

**This step is crucial for running the app as the key is NOT committed to Git.**

1. Obtain a free API key from [OpenWeatherMap].
2. In the project root, create a file named `.env` and add your key:
   `OPEN_WEATHER_API_KEY=YOUR_API_KEY_HERE`

### 2. Clone and Install:

```bash
git clone YOUR_REPO_URL
cd your-project-name
flutter pub get
```

### 3. Run the app (via terminal or IDE config):

💡 You must pass the API key using the `--dart-define` flag at runtime.

```bash
flutter run --dart-define=OPEN_WEATHER_API_KEY=YOUR_API_KEY_HERE
```

---

## 📄 License

This project is licensed under the **MIT License**.  
See the LICENSE file for details.

---

## 🙋‍♂️ Author

**Muzaffar Javed**  
📫 [GitHub Profile](https://github.com/Muzaffar47)

---

## 🤝 Contributions

Contributions, pull requests, and suggestions are welcome!  
Feel free to fork the repo and submit your improvements.
