# BellyButton

A modern event management and photo-sharing app built with Flutter and GetX. BellyButton helps users create, manage, and share events with friends and family through an intuitive mobile experience.

## Features

### Authentication
- Phone number login with OTP verification
- Profile setup for new users
- Secure session management

### Event Management
- Create and manage events with date, time, and location
- Upcoming and past event views with smart sorting
- Event invitations system
- Invite users via contacts or manual entry

### Photo Gallery
- Event-specific photo galleries
- Shared event gallery for invited users
- Photo preview with zoom and share functionality
- Cached image loading for performance

### Notifications
- Push notifications via Firebase Cloud Messaging
- In-app notification center
- Real-time event updates

### Profile & Settings
- Account details management
- Terms and conditions
- Premium features

## Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter 3.7+ (Dart) |
| State Management | GetX |
| Networking | Dio with interceptors |
| Backend | Firebase (Auth, Messaging, Crashlytics) |
| Local Storage | Hive |
| Image Handling | cached_network_image, photo_manager, wechat_assets_picker |
| Deep Linking | app_links |

## Project Structure

```
lib/
├── app/
│   ├── api/                    # API services and endpoints
│   ├── Controllers/            # Global controllers (OAuth, device info)
│   ├── core/
│   │   ├── constants/          # App colors, images, texts
│   │   ├── network/            # Dio client, auth interceptor
│   │   ├── services/           # Notifications, deep links, showcase
│   │   └── utils/              # Helpers, storage, initializers
│   ├── database/models/        # Data models (Event, Notification, etc.)
│   ├── global_widgets/         # Reusable UI components
│   ├── modules/
│   │   ├── Auth/               # phone_login, login_otp, profile_setup
│   │   ├── Dashboard/          # Events, galleries, invitations
│   │   ├── Notifications/
│   │   ├── Profile/
│   │   ├── Premium/
│   │   ├── SharedEventGallery/
│   │   └── onboarding/
│   └── routes/                 # App navigation
└── main.dart
```

### Module Pattern

Each feature module follows GetX conventions:
```
module_name/
├── bindings/       # Dependency injection
├── controllers/    # Business logic
├── models/         # Module-specific models
└── views/          # UI screens
```

## Setup

### Prerequisites
- Flutter SDK 3.7.2 or higher
- Dart SDK
- Android Studio / VS Code
- Firebase project configured

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/bellybuttonapp/Bellybutton_Frontend.git
   cd bellybutton
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Configure Firebase
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`

4. Run the app
   ```bash
   flutter run
   ```

### Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Key Dependencies

- **get** - State management and routing
- **dio** - HTTP client with interceptors
- **firebase_core/messaging/crashlytics** - Firebase services
- **cached_network_image** - Image caching
- **hive_flutter** - Local database
- **table_calendar** - Calendar widget for events
- **photo_manager/wechat_assets_picker** - Photo selection
- **shimmer** - Loading placeholders
- **country_picker** - Phone number country codes
- **showcaseview** - Feature onboarding

## Architecture

The app follows Clean Architecture principles with GetX:

- **Presentation Layer**: Views and Controllers handle UI and user interactions
- **Domain Layer**: Models define business entities
- **Data Layer**: API services and local storage manage data operations

Key architectural decisions:
- Reactive state management with GetX observables
- Dependency injection via GetX bindings
- Centralized error handling through interceptors
- Modular feature organization for scalability

## Platforms

- Android (API 21+)
- iOS (12.0+)
- macOS (desktop support available)

## Developer

**Aravinth Kannan**
Flutter Mobile Application Developer

- Email: [flutterdev.aravinth@gmail.com](mailto:flutterdev.aravinth@gmail.com)
- Portfolio: [aravinth-codes.netlify.app](https://aravinth-codes.netlify.app)
- LinkedIn: [arvindhkannan](https://www.linkedin.com/in/arvindhkannan/)

## License

This project is proprietary software. All rights reserved.