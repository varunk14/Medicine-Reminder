# Medicine Reminder

A simple and elegant Flutter app to help you manage daily medication schedules with timely reminders.

## Features

- **Add Medicines** - Easily add medicines with name, dosage, and reminder time
- **Daily Reminders** - Get notified at scheduled times, even when the app is in background
- **Sorted List** - Medicines automatically sorted by time (earliest first)
- **Clean UI** - Modern Material Design with Teal & Orange theme
- **Offline First** - All data stored locally, no internet required

## Screenshots

| Home Screen | Add Medicine | Empty State |
|-------------|--------------|-------------|
| Medicine list sorted by time | Form with time picker | Friendly placeholder |

## Tech Stack

- **Framework:** Flutter
- **State Management:** Provider
- **Local Storage:** Hive
- **Notifications:** flutter_local_notifications
- **Architecture:** Clean Architecture (Repository Pattern)

## Getting Started

### Prerequisites

- Flutter SDK (3.10.0 or higher)
- Android Studio / VS Code
- Android SDK / Xcode (for iOS)

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/medicine_reminder_app.git
cd medicine_reminder_app
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

### Build APK

```bash
flutter build apk --release
```

The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`

## Project Structure

```
lib/
├── main.dart                     # App entry point
├── core/
│   ├── theme/                    # App theme configuration
│   └── utils/                    # Utility functions
├── data/
│   ├── models/                   # Data models (Medicine)
│   ├── repositories/             # Data layer (CRUD operations)
│   └── services/                 # Services (Notifications)
└── presentation/
    ├── providers/                # State management
    ├── screens/                  # UI screens
    └── widgets/                  # Reusable widgets
```

## Permissions

### Android
- `RECEIVE_BOOT_COMPLETED` - Reschedule alarms after device restart
- `VIBRATE` - Vibration for notifications
- `POST_NOTIFICATIONS` - Show notifications
- `SCHEDULE_EXACT_ALARM` - Schedule precise reminders
- `USE_EXACT_ALARM` - Use exact alarms (Android 12+)

### iOS
- Notification permissions requested at runtime

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) for notification support
- [Hive](https://pub.dev/packages/hive) for fast local storage
- [Provider](https://pub.dev/packages/provider) for state management
