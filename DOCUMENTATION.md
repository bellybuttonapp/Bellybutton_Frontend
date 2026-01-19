# BellyButton Flutter App - Complete Documentation & Tutorial

> **Version**: 1.0.0+2
> **Framework**: Flutter 3.7.2+
> **Architecture**: GetX + Clean Architecture
> **Developer**: Aravinth Kannan

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Project Structure](#2-project-structure)
3. [Architecture Pattern](#3-architecture-pattern)
4. [Getting Started](#4-getting-started)
5. [Core Modules](#5-core-modules)
6. [API Reference](#6-api-reference)
7. [State Management](#7-state-management)
8. [Routing System](#8-routing-system)
9. [Database & Storage](#9-database--storage)
10. [UI Components](#10-ui-components)
11. [Authentication Flow](#11-authentication-flow)
12. [Services](#12-services)
13. [Dependencies](#13-dependencies)
14. [Code Patterns & Examples](#14-code-patterns--examples)
15. [Build & Deployment](#15-build--deployment)

---

## 1. Project Overview

**BellyButton** is a modern event management and photo-sharing mobile application. It enables users to:

- Create and manage events
- Invite participants via phone contacts
- Share photos within collaborative event galleries
- Receive real-time push notifications
- Access shared galleries via deep links

### Key Features

| Feature | Description |
|---------|-------------|
| Phone OTP Auth | Secure authentication with SMS verification |
| Event Management | Create, edit, delete events with timezone support |
| Photo Galleries | Upload, view, and share event photos |
| Invitations | Invite users and manage invitation responses |
| Push Notifications | Firebase-powered real-time notifications |
| Deep Linking | Share events via links (app & web) |
| Offline Support | Local caching with Hive database |

---

## 2. Project Structure

```
lib/
├── main.dart                           # App entry point
├── app/
│   ├── api/                            # API Layer
│   │   ├── PublicApiService.dart       # Main API client (45+ methods)
│   │   ├── firebase_api.dart           # Firebase FCM setup
│   │   └── end_points.dart             # Endpoint constants
│   │
│   ├── core/                           # Core Functionality
│   │   ├── constants/                  # App Configuration
│   │   │   ├── app_colors.dart         # Color system (dark/light)
│   │   │   ├── app_constant.dart       # Base URLs, timeouts
│   │   │   ├── app_images.dart         # Asset paths
│   │   │   ├── app_texts.dart          # Localized strings
│   │   │   └── app_animations.dart     # Animation assets
│   │   │
│   │   ├── network/                    # Networking
│   │   │   ├── dio_client.dart         # HTTP client singleton
│   │   │   └── auth_interceptor.dart   # JWT token handling
│   │   │
│   │   ├── services/                   # Core Services
│   │   │   ├── deep_link_service.dart
│   │   │   ├── firebase_notification_service.dart
│   │   │   ├── notification_service.dart
│   │   │   ├── cache_manager_service.dart
│   │   │   └── showcase_service.dart
│   │   │
│   │   └── utils/
│   │       ├── initializer/            # App startup
│   │       ├── storage/                # Local storage (Hive)
│   │       ├── themes/                 # Design system
│   │       └── helpers/                # Utility functions
│   │
│   ├── database/                       # Data Models
│   │   └── models/
│   │       ├── EventModel.dart
│   │       ├── InvitedEventModel.dart
│   │       ├── NotificationModel.dart
│   │       └── MemberModel.dart
│   │
│   ├── global_widgets/                 # Reusable UI (27 widgets)
│   │   ├── Button/
│   │   ├── GlobalTextField/
│   │   ├── CustomSnackbar/
│   │   ├── eventCard/
│   │   └── ...
│   │
│   ├── modules/                        # Feature Modules
│   │   ├── Auth/                       # Authentication
│   │   │   ├── phone_login/
│   │   │   ├── login_otp/
│   │   │   └── profile_setup/
│   │   │
│   │   ├── Dashboard/                  # Main Screen
│   │   │   └── Innermodule/
│   │   │       ├── Upcomming_Event/
│   │   │       ├── Past_Event/
│   │   │       ├── create_event/
│   │   │       ├── Event_gallery/
│   │   │       └── inviteuser/
│   │   │
│   │   ├── Notifications/
│   │   ├── Profile/
│   │   ├── Premium/
│   │   └── SharedEventGallery/
│   │
│   └── routes/                         # Navigation
│       ├── app_pages.dart              # Route definitions
│       └── app_routes.dart             # Route constants
```

---

## 3. Architecture Pattern

### GetX + Clean Architecture

The app follows **Clean Architecture** principles with **GetX** framework:

```
┌─────────────────────────────────────────┐
│           PRESENTATION LAYER            │
│  ┌─────────────┐    ┌────────────────┐  │
│  │   Views     │◄───│  Controllers   │  │
│  │   (UI)      │    │ (Business Logic)│  │
│  └─────────────┘    └────────────────┘  │
├─────────────────────────────────────────┤
│             DOMAIN LAYER                │
│  ┌─────────────────────────────────┐    │
│  │     Models (EventModel, etc.)   │    │
│  └─────────────────────────────────┘    │
├─────────────────────────────────────────┤
│              DATA LAYER                 │
│  ┌──────────────┐  ┌────────────────┐   │
│  │ API Services │  │ Local Storage  │   │
│  │ (Dio Client) │  │    (Hive)      │   │
│  └──────────────┘  └────────────────┘   │
└─────────────────────────────────────────┘
```

### Module Structure (MVVM Pattern)

Each feature module follows this structure:

```
module_name/
├── bindings/
│   └── module_binding.dart      # Dependency injection
├── controllers/
│   └── module_controller.dart   # Business logic & state
└── views/
    └── module_view.dart         # UI widgets
```

**Example - Dashboard Module:**

```dart
// bindings/dashboard_binding.dart
class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DashboardController());
  }
}

// controllers/dashboard_controller.dart
class DashboardController extends GetxController {
  var events = <EventModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    isLoading.value = true;
    final response = await PublicApiService().getMyEvents();
    if (response["success"]) {
      events.value = response["data"];
    }
    isLoading.value = false;
  }
}

// views/dashboard_view.dart
class DashboardView extends GetView<DashboardController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => controller.isLoading.value
        ? CircularProgressIndicator()
        : ListView.builder(
            itemCount: controller.events.length,
            itemBuilder: (_, i) => EventCard(event: controller.events[i]),
          ),
      ),
    );
  }
}
```

---

## 4. Getting Started

### Prerequisites

- Flutter SDK 3.7.2+
- Dart 3.7.2+
- Android Studio / VS Code
- Firebase project configured

### Installation

```bash
# Clone the repository
git clone https://github.com/bellybuttonapp/Bellybutton_Frontend.git

# Navigate to project
cd bellybutton

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Environment Configuration

Edit `lib/app/core/constants/app_constant.dart`:

```dart
class AppConstants {
  // Development
  static const String BASE_URL = "https://mobapidev.bellybutton.global/api";

  // Testing
  // static const String BASE_URL = "https://mobapitest.bellybutton.global/api";

  // Production
  // static const String BASE_URL = "https://mobapi.bellybutton.global/api";

  static const int CONNECTION_TIMEOUT = 30000;
  static const int RECEIVE_TIMEOUT = 30000;
}
```

---

## 5. Core Modules

### 5.1 Authentication Module

**Location:** `lib/app/modules/Auth/`

#### Phone Login (`phone_login/`)

- Country auto-detection from device locale
- Phone number validation per country
- Terms & Conditions checkbox

```dart
// Controller usage
class PhoneLoginController extends GetxController {
  var phoneController = TextEditingController();
  var selectedCountry = Rxn<Country>();

  Future<void> sendOtp() async {
    final response = await PublicApiService().sendOtp(
      phone: phoneController.text,
      countryCode: selectedCountry.value?.phoneCode,
    );
    if (response["success"]) {
      Get.toNamed(AppRoutes.LOGIN_OTP, arguments: {
        "phone": phoneController.text,
        "countryCode": selectedCountry.value?.phoneCode,
      });
    }
  }
}
```

#### OTP Verification (`login_otp/`)

- 6-digit OTP input
- SMS autofill support (Android)
- 30-second resend timer

```dart
class LoginOtpController extends GetxController with CodeAutoFill {
  var otpController = TextEditingController();
  var resendTimer = 30.obs;

  @override
  void codeUpdated() {
    // SMS autofill callback
    otpController.text = code ?? '';
    if (code?.length == 6) {
      verifyOtp();
    }
  }

  Future<void> verifyOtp() async {
    final response = await PublicApiService().verifyOtp(
      phone: phone,
      otp: otpController.text,
    );
    if (response["success"]) {
      // Save token & navigate
      Preference.token = response["data"]["token"];
      Preference.isLoggedIn = true;
      Get.offAllNamed(AppRoutes.DASHBOARD);
    }
  }
}
```

#### Profile Setup (`profile_setup/`)

- First-time user profile creation
- Profile photo upload with cropping
- Name, email, bio fields

---

### 5.2 Dashboard Module

**Location:** `lib/app/modules/Dashboard/`

The main app screen with tab navigation containing:

| Inner Module | Purpose |
|--------------|---------|
| `Upcomming_Event/` | List of future events |
| `Past_Event/` | Archive of past events |
| `create_event/` | Event creation form |
| `Event_gallery/` | Photos for user's events |
| `inviteuser/` | Invite contacts to event |
| `EventInvitations/` | Received invitations |
| `InvitedEventGallery/` | Photos in invited events |

---

### 5.3 Events System

#### Event Model

```dart
class EventModel {
  final String? eventId;
  final String? eventName;
  final String? eventDescription;
  final String? eventDate;        // "2024-12-25"
  final String? eventStartTime;   // "14:00"
  final String? eventEndTime;     // "18:00"
  final String? eventTimezone;    // "Asia/Kolkata"
  final String? timezoneOffset;   // "+05:30"
  final List<String>? invitedPeople;
  final String? creatorId;
  final String? shareToken;
  final String? status;           // "ACTIVE", "COMPLETED"
}
```

#### Event Lifecycle

```
1. Create Event (title, date, time, timezone)
         ↓
2. Invite Users (by phone/contact)
         ↓
3. Users Accept/Reject Invitations
         ↓
4. Participants Upload Photos
         ↓
5. Gallery Shared (with permissions)
```

#### Permission Levels

| Level | Capabilities |
|-------|--------------|
| `view-only` | View photos only |
| `view-sync` | View + upload photos |

---

### 5.4 Notifications Module

**Location:** `lib/app/modules/Notifications/`

```dart
class NotificationsController extends GetxController {
  var notifications = <NotificationModel>[].obs;
  var unreadCount = 0.obs;

  Future<void> fetchNotifications() async {
    final response = await PublicApiService().getNotifications();
    if (response["success"]) {
      notifications.value = (response["data"] as List)
          .map((e) => NotificationModel.fromJson(e))
          .toList();
      unreadCount.value = notifications.where((n) => !n.isRead).length;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await PublicApiService().markNotificationRead(notificationId);
    fetchNotifications();
  }
}
```

---

## 6. API Reference

### Base Configuration

```dart
// lib/app/core/network/dio_client.dart
class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;

  DioClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: AppConstants.BASE_URL,
      connectTimeout: Duration(milliseconds: AppConstants.CONNECTION_TIMEOUT),
      receiveTimeout: Duration(milliseconds: AppConstants.RECEIVE_TIMEOUT),
    ));

    dio.interceptors.add(AuthInterceptor());
    dio.interceptors.add(PrettyDioLogger());
  }
}
```

### Endpoints Reference

#### Authentication (9 endpoints)

```
POST   /userresource/auth/send-otp          # Send OTP to phone
POST   /userresource/auth/verify-otp        # Verify OTP & get token
POST   /userresource/auth/resend-otp        # Resend OTP
POST   /userresource/register/user          # Register new user
POST   /userresource/logout                 # Logout
POST   /userresource/token/refresh          # Refresh JWT token
POST   /userresource/auth/save-fcm-token    # Save FCM token
```

#### User Management (6 endpoints)

```
GET    /userresource/user                   # Get current user
PUT    /userresource/user/update            # Update user info
DELETE /userresource/delete                 # Delete account
GET    /profile/view/{id}                   # Get profile by ID
PUT    /profile/update                      # Update profile + photo
```

#### Event Management (5 endpoints)

```
POST   /eventresource/create/event          # Create event
GET    /eventresource/view/event/{id}       # Get event details
GET    /eventresource/list/my/events        # List user's events
DELETE /eventresource/delete/event/{id}     # Delete event
PUT    /eventresource/update/event/{id}     # Update event
```

#### Event Invitations (6 endpoints)

```
GET    /eventresource/list/invited/events   # Get invited events
POST   /eventresource/accept/event/{id}     # Accept invitation
POST   /eventresource/deny/event/{id}       # Deny invitation
POST   /eventresource/admin/invite/{id}     # Invite users
DELETE /eventresource/admin/remove-invite   # Remove invited user
GET    /eventresource/join/event/{token}    # Join by deep link
```

#### Event Photos (3 endpoints)

```
POST   /userresource/event/upload           # Upload photos
GET    /userresource/event/sync/{id}        # Fetch event photos
GET    /userresource/media/{id}             # Get photo info
```

#### Event Sharing (3 endpoints)

```
GET    /eventresource/share/event/{id}      # Generate share link
GET    /eventresource/share/event/open/{id} # Open shared event
GET    /public/event/gallery/{id}           # Public gallery (no auth)
```

#### Notifications (2 endpoints)

```
GET    /notifications/list                  # Get notifications
PUT    /notifications/read/{id}             # Mark as read
```

### API Service Usage

```dart
// lib/app/api/PublicApiService.dart
class PublicApiService {
  final _dio = DioClient().dio;

  // Create Event
  Future<Map<String, dynamic>> createEvent({
    required String name,
    required String description,
    required String date,
    required String startTime,
    required String endTime,
    required String timezone,
  }) async {
    try {
      final response = await _dio.post(
        EndPoints.CREATE_EVENT,
        data: {
          "eventName": name,
          "eventDescription": description,
          "eventDate": date,
          "eventStartTime": startTime,
          "eventEndTime": endTime,
          "eventTimezone": timezone,
        },
      );
      return {"success": true, "data": response.data};
    } on DioException catch (e) {
      return {"success": false, "message": e.message};
    }
  }

  // Get My Events
  Future<Map<String, dynamic>> getMyEvents() async {
    try {
      final response = await _dio.get(EndPoints.LIST_MY_EVENTS);
      return {"success": true, "data": response.data};
    } on DioException catch (e) {
      return {"success": false, "message": e.message};
    }
  }
}
```

---

## 7. State Management

### GetX Reactive Variables

```dart
// Primitive observables
var isLoading = false.obs;        // RxBool
var eventName = "".obs;           // RxString
var eventCount = 0.obs;           // RxInt

// Nullable observables
var selectedEvent = Rxn<EventModel>();  // RxnString

// List observables
var events = <EventModel>[].obs;  // RxList<EventModel>

// Map observables
var formData = <String, dynamic>{}.obs;
```

### Observing Changes

```dart
// In View - using Obx
Obx(() => Text("Count: ${controller.eventCount.value}"))

// In View - using GetX widget
GetX<DashboardController>(
  builder: (c) => Text("Events: ${c.events.length}"),
)

// In Controller - using ever/debounce
@override
void onInit() {
  ever(events, (list) => print("Events updated: ${list.length}"));
  debounce(searchQuery, (query) => search(query), time: Duration(ms: 500));
}
```

### Dependency Injection

```dart
// Register dependency
Get.put(DashboardController());           // Immediate
Get.lazyPut(() => DashboardController()); // Lazy

// Find dependency
final controller = Get.find<DashboardController>();

// In bindings
class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DashboardController());
    Get.put(EventService());
  }
}
```

---

## 8. Routing System

### Route Definitions

```dart
// lib/app/routes/app_routes.dart
abstract class AppRoutes {
  static const SPLASH = '/splash';
  static const ONBOARDING = '/onboarding';
  static const PHONE_LOGIN = '/phone-login';
  static const LOGIN_OTP = '/login-otp';
  static const PROFILE_SETUP = '/profile-setup';
  static const DASHBOARD = '/dashboard';
  static const UPCOMING_EVENT = '/upcomming-event';
  static const PAST_EVENT = '/past-event';
  static const CREATE_EVENT = '/create-event';
  static const EVENT_GALLERY = '/event-gallery';
  static const NOTIFICATIONS = '/notifications';
  static const PROFILE = '/profile';
  static const SHARED_EVENT_GALLERY = '/shared-event-gallery';
}
```

### Route Pages

```dart
// lib/app/routes/app_pages.dart
class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.DASHBOARD,
      page: () => DashboardView(),
      binding: DashboardBinding(),
      children: [
        GetPage(
          name: AppRoutes.UPCOMING_EVENT,
          page: () => UpcommingEventView(),
          binding: UpcommingEventBinding(),
        ),
        GetPage(
          name: AppRoutes.CREATE_EVENT,
          page: () => CreateEventView(),
          binding: CreateEventBinding(),
        ),
      ],
    ),
  ];
}
```

### Navigation

```dart
// Basic navigation
Get.toNamed(AppRoutes.DASHBOARD);

// With arguments
Get.toNamed(AppRoutes.EVENT_GALLERY, arguments: {"eventId": "123"});

// Replace current
Get.offNamed(AppRoutes.DASHBOARD);

// Clear stack
Get.offAllNamed(AppRoutes.PHONE_LOGIN);

// Back with result
Get.back(result: selectedEvent);

// Receive arguments
final eventId = Get.arguments["eventId"];
```

### Deep Linking

```dart
// lib/app/core/services/deep_link_service.dart
class DeepLinkService extends GetxService {
  static const _channel = MethodChannel('com.bellybutton/deeplink');

  Future<void> init() async {
    // Handle initial link (cold start)
    final initialLink = await _channel.invokeMethod('getInitialLink');
    if (initialLink != null) {
      _handleLink(initialLink);
    }

    // Handle incoming links (runtime)
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onNewLink') {
        _handleLink(call.arguments as String);
      }
    });
  }

  void _handleLink(String link) {
    final uri = Uri.parse(link);

    if (uri.path.contains("join/event")) {
      final token = uri.pathSegments.last;
      _joinEventByToken(token);
    } else if (uri.path.contains("share/event")) {
      final eventId = uri.pathSegments.last;
      Get.toNamed(AppRoutes.SHARED_EVENT_GALLERY, arguments: {"eventId": eventId});
    }
  }
}
```

---

## 9. Database & Storage

### Hive Local Storage

```dart
// lib/app/core/utils/storage/preference.dart
class Preference {
  static late Box _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('appBox');
  }

  // Authentication
  static String? get token => _box.get('TOKEN');
  static set token(String? value) => _box.put('TOKEN', value);

  static bool get isLoggedIn => _box.get('IS_LOGGED_IN', defaultValue: false);
  static set isLoggedIn(bool value) => _box.put('IS_LOGGED_IN', value);

  static String? get fcmToken => _box.get('FCM_TOKEN');
  static set fcmToken(String? value) => _box.put('FCM_TOKEN', value);

  // User Profile
  static String? get userId => _box.get('USER_ID');
  static set userId(String? value) => _box.put('USER_ID', value);

  static String? get userName => _box.get('USER_NAME');
  static set userName(String? value) => _box.put('USER_NAME', value);

  static String? get userEmail => _box.get('USER_EMAIL');
  static set userEmail(String? value) => _box.put('USER_EMAIL', value);

  static String? get profileImage => _box.get('PROFILE_IMAGE');
  static set profileImage(String? value) => _box.put('PROFILE_IMAGE', value);

  // App Settings
  static bool get onboardingComplete => _box.get('ONBOARDING_COMPLETE', defaultValue: false);
  static set onboardingComplete(bool value) => _box.put('ONBOARDING_COMPLETE', value);

  static bool get termsAccepted => _box.get('TERMS_ACCEPTED', defaultValue: false);
  static set termsAccepted(bool value) => _box.put('TERMS_ACCEPTED', value);

  // Clear all data
  static Future<void> clear() async {
    await _box.clear();
  }
}
```

### Preference Keys Reference

| Category | Keys |
|----------|------|
| **Auth** | TOKEN, IS_LOGGED_IN, FCM_TOKEN, REMEMBER_ME |
| **User** | USER_ID, USER_NAME, USER_EMAIL, PROFILE_IMAGE, BIO, PHONE |
| **Settings** | ONBOARDING_COMPLETE, TERMS_ACCEPTED, LANGUAGE_CODE |
| **Showcase** | SHOWCASE_DASHBOARD, SHOWCASE_CREATE_EVENT, SHOWCASE_GALLERY |

---

## 10. UI Components

### Global Widgets Library

| Widget | Location | Purpose |
|--------|----------|---------|
| `GlobalButton` | `Button/` | Primary CTA buttons |
| `GlobalTextField` | `GlobalTextField/` | Styled text inputs |
| `CustomSnackbar` | `CustomSnackbar/` | Toast notifications |
| `CustomPopup` | `CustomPopup/` | Dialog popups |
| `CustomBottomSheet` | `CustomBottomSheet/` | Bottom sheets |
| `CustomAppBar` | `custom_app_bar/` | Branded app bar |
| `EventCard` | `eventCard/` | Event display card |
| `InvitedEventCard` | `eventCard/InvitedEventCard/` | Invited event card |
| `PhotoPreviewWidget` | `photo_preview_widget/` | Full-screen photo |
| `ShimmerLoader` | `Shimmers/` | Loading skeleton |
| `CustomErrorWidget` | `ErrorWidget/` | Error state |
| `MembersListWidget` | `MembersListWidget/` | Member list |
| `CountryPickerDialog` | `CountryPickerDialog/` | Country selection |
| `SlideshowPreview` | `slideshow_preview/` | Photo slideshow |

### Usage Examples

```dart
// GlobalButton
GlobalButton(
  text: "Create Event",
  onPressed: () => controller.createEvent(),
  isLoading: controller.isLoading.value,
)

// GlobalTextField
GlobalTextField(
  controller: nameController,
  label: "Event Name",
  hint: "Enter event name",
  validator: (v) => v!.isEmpty ? "Required" : null,
)

// CustomSnackbar
showCustomSnackBar(
  "Event created successfully!",
  SnackbarState.success,
);

// CustomPopup
showCustomPopup(
  title: "Delete Event?",
  message: "This action cannot be undone.",
  onConfirm: () => controller.deleteEvent(),
);

// EventCard
EventCard(
  event: event,
  onTap: () => Get.toNamed(AppRoutes.EVENT_GALLERY, arguments: {"event": event}),
)
```

### Design System

#### Colors (`app_colors.dart`)

```dart
class AppColors {
  // Primary
  static const Color primary = Color(0xFF004C99);
  static const Color secondary = Color(0xFF212B4F);

  // Status
  static const Color success = Color(0xFF43A047);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF1E88E5);

  // Background
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
}
```

#### Typography (`font_style.dart`)

```dart
class AppTextStyles {
  static const String fontFamily = 'DM Sans';

  static TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static TextStyle body1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}
```

#### Spacing (`dimensions.dart`)

```dart
class AppDimensions {
  // Padding
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Margin
  static const double marginS = 8.0;
  static const double marginM = 16.0;
  static const double marginL = 24.0;

  // Border Radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 16.0;
}
```

---

## 11. Authentication Flow

### Complete Flow Diagram

```
┌─────────────────┐
│   App Launch    │
└────────┬────────┘
         ▼
┌─────────────────┐     No      ┌─────────────────┐
│  Is Logged In?  │────────────►│   Onboarding    │
└────────┬────────┘             └────────┬────────┘
         │ Yes                           ▼
         │                      ┌─────────────────┐
         │                      │  Phone Login    │
         │                      └────────┬────────┘
         │                               ▼
         │                      ┌─────────────────┐
         │                      │  OTP Verify     │
         │                      └────────┬────────┘
         │                               ▼
         │                      ┌─────────────────┐
         │                      │ Profile Setup   │◄── First time only
         │                      └────────┬────────┘
         │                               │
         ▼                               ▼
┌─────────────────────────────────────────────────┐
│                  Dashboard                       │
└─────────────────────────────────────────────────┘
```

### Implementation

```dart
// main.dart - Initial route determination
String get initialRoute {
  if (!Preference.onboardingComplete) {
    return AppRoutes.ONBOARDING;
  }
  if (!Preference.isLoggedIn) {
    return AppRoutes.PHONE_LOGIN;
  }
  return AppRoutes.DASHBOARD;
}

// Auth Interceptor - Token injection
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = Preference.token;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired - logout
      _handleSessionExpired();
    }
    handler.next(err);
  }

  void _handleSessionExpired() {
    Preference.clear();
    Get.offAllNamed(AppRoutes.PHONE_LOGIN);
    showCustomSnackBar("Session expired. Please login again.", SnackbarState.error);
  }
}
```

---

## 12. Services

### 12.1 Deep Link Service

Handles app deep links for event sharing.

```dart
class DeepLinkService extends GetxService {
  String? pendingLink;  // Store link if user not logged in

  Future<void> handleLink(String link) async {
    if (!Preference.isLoggedIn) {
      pendingLink = link;
      return;
    }

    final uri = Uri.parse(link);

    // Join event by token
    if (uri.path.contains("join/event")) {
      final token = uri.pathSegments.last;
      final response = await PublicApiService().joinEventByToken(token);
      if (response["success"]) {
        Get.toNamed(AppRoutes.EVENT_INVITATIONS);
      }
    }

    // View shared gallery
    if (uri.path.contains("share/event")) {
      final eventId = uri.pathSegments.last;
      Get.toNamed(AppRoutes.SHARED_EVENT_GALLERY, arguments: {"eventId": eventId});
    }
  }

  void processPendingLink() {
    if (pendingLink != null) {
      handleLink(pendingLink!);
      pendingLink = null;
    }
  }
}
```

### 12.2 Firebase Notification Service

Handles push notifications via FCM.

```dart
class FirebaseNotificationService {
  final _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    final token = await _messaging.getToken();
    if (token != null) {
      Preference.fcmToken = token;
      await PublicApiService().saveFcmToken(token);
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle terminated state tap
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Show in-app notification
    showInAppNotification(
      title: message.notification?.title ?? "",
      body: message.notification?.body ?? "",
      onTap: () => _navigateToScreen(message.data),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    _navigateToScreen(message.data);
  }

  void _navigateToScreen(Map<String, dynamic> data) {
    final type = data["type"];
    final eventId = data["eventId"];

    switch (type) {
      case "EVENT_INVITATION":
        Get.toNamed(AppRoutes.EVENT_INVITATIONS);
        break;
      case "NEW_PHOTO":
        Get.toNamed(AppRoutes.EVENT_GALLERY, arguments: {"eventId": eventId});
        break;
    }
  }
}
```

### 12.3 Notification Service

Manages notification state and API calls.

```dart
class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  var notifications = <NotificationModel>[].obs;
  var unreadCount = 0.obs;
  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (_) {
      fetchNotifications();
    });
  }

  Future<void> fetchNotifications() async {
    final response = await PublicApiService().getNotifications();
    if (response["success"]) {
      notifications.value = (response["data"] as List)
          .map((e) => NotificationModel.fromJson(e))
          .toList();
      unreadCount.value = notifications.where((n) => !n.isRead).length;
    }
  }

  Future<void> markAsRead(String id) async {
    await PublicApiService().markNotificationRead(id);
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index].isRead = true;
      notifications.refresh();
      unreadCount.value = notifications.where((n) => !n.isRead).length;
    }
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }
}
```

### 12.4 Cache Manager Service

Handles image caching.

```dart
class CacheManagerService {
  static final CacheManager _cacheManager = CacheManager(
    Config(
      'eventPhotosCache',
      stalePeriod: Duration(days: 7),
      maxNrOfCacheObjects: 200,
    ),
  );

  static Future<File> getImage(String url) async {
    return await _cacheManager.getSingleFile(url);
  }

  static Future<void> clearCache() async {
    await _cacheManager.emptyCache();
  }

  static Future<void> removeFile(String url) async {
    await _cacheManager.removeFile(url);
  }
}
```

---

## 13. Dependencies

### Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management & Navigation
  get: ^4.7.2

  # Networking
  dio: ^5.9.0
  pretty_dio_logger: ^1.4.0

  # Firebase
  firebase_core: ^4.2.1
  firebase_messaging: ^16.0.4
  firebase_crashlytics: ^5.0.5
  firebase_app_check: ^0.4.1+2

  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Image Handling
  cached_network_image: ^3.4.1
  flutter_cache_manager: ^3.4.1
  photo_manager: ^3.7.1
  wechat_assets_picker: ^10.0.0
  photo_view: ^0.15.0
  image_picker: ^1.2.0
  image_cropper: ^11.0.0

  # UI Components
  flutter_svg: ^2.0.10
  shimmer: ^3.0.0
  table_calendar: ^3.2.0
  carousel_slider: ^5.0.0
  flutter_staggered_grid_view: ^0.7.0
  auto_size_text: ^3.0.0
  badges: ^3.1.2
  showcaseview: ^3.0.0

  # Device & Permissions
  permission_handler: ^12.0.1
  device_info_plus: ^12.3.0
  connectivity_plus: ^7.0.0

  # Utilities
  intl: ^0.20.2
  country_picker: ^2.0.27
  phone_numbers_parser: ^8.3.0
  sms_autofill: ^2.4.0
  flutter_local_notifications: ^19.5.0
  share_plus: ^12.0.1
  gallery_saver_plus: ^3.2.9
```

---

## 14. Code Patterns & Examples

### 14.1 Controller Pattern

```dart
class EventGalleryController extends GetxController {
  // Observables
  var photos = <PhotoModel>[].obs;
  var isLoading = false.obs;
  var isUploading = false.obs;
  var uploadProgress = 0.0.obs;

  // Dependencies
  final String eventId;

  EventGalleryController({required this.eventId});

  @override
  void onInit() {
    super.onInit();
    fetchPhotos();
  }

  Future<void> fetchPhotos() async {
    isLoading.value = true;
    try {
      final response = await PublicApiService().getEventPhotos(eventId);
      if (response["success"]) {
        photos.value = (response["data"] as List)
            .map((e) => PhotoModel.fromJson(e))
            .toList();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> uploadPhotos(List<File> files) async {
    isUploading.value = true;
    uploadProgress.value = 0;

    try {
      for (int i = 0; i < files.length; i++) {
        await PublicApiService().uploadPhoto(eventId, files[i]);
        uploadProgress.value = (i + 1) / files.length;
      }
      await fetchPhotos();
      showCustomSnackBar("Photos uploaded!", SnackbarState.success);
    } catch (e) {
      showCustomSnackBar("Upload failed", SnackbarState.error);
    } finally {
      isUploading.value = false;
    }
  }
}
```

### 14.2 View Pattern

```dart
class EventGalleryView extends GetView<EventGalleryController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Event Gallery"),
      body: Obx(() {
        if (controller.isLoading.value) {
          return ShimmerLoader();
        }

        if (controller.photos.isEmpty) {
          return EmptyPlaceholder(
            message: "No photos yet",
            icon: Icons.photo_library_outlined,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchPhotos,
          child: GridView.builder(
            padding: EdgeInsets.all(AppDimensions.paddingM),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: controller.photos.length,
            itemBuilder: (_, index) => PhotoThumbnail(
              photo: controller.photos[index],
              onTap: () => _openPhotoPreview(index),
            ),
          ),
        );
      }),
      floatingActionButton: Obx(() => controller.isUploading.value
        ? FloatingActionButton(
            onPressed: null,
            child: CircularProgressIndicator(
              value: controller.uploadProgress.value,
              color: Colors.white,
            ),
          )
        : FloatingActionButton(
            onPressed: _selectPhotos,
            child: Icon(Icons.add_photo_alternate),
          ),
      ),
    );
  }

  void _selectPhotos() async {
    final assets = await AssetPicker.pickAssets(context);
    if (assets != null && assets.isNotEmpty) {
      final files = await Future.wait(
        assets.map((a) => a.file),
      );
      controller.uploadPhotos(files.whereType<File>().toList());
    }
  }

  void _openPhotoPreview(int index) {
    Get.to(() => PhotoPreviewWidget(
      photos: controller.photos,
      initialIndex: index,
    ));
  }
}
```

### 14.3 API Error Handling

```dart
Future<Map<String, dynamic>> safeApiCall(
  Future<Response> Function() apiCall,
) async {
  try {
    final response = await apiCall();
    return {
      "success": true,
      "data": response.data,
      "statusCode": response.statusCode,
    };
  } on DioException catch (e) {
    String message = "Something went wrong";

    if (e.type == DioExceptionType.connectionTimeout) {
      message = "Connection timeout";
    } else if (e.type == DioExceptionType.receiveTimeout) {
      message = "Server not responding";
    } else if (e.response != null) {
      message = e.response?.data?["message"] ?? message;
    }

    return {
      "success": false,
      "message": message,
      "statusCode": e.response?.statusCode,
    };
  } catch (e) {
    return {
      "success": false,
      "message": e.toString(),
    };
  }
}
```

### 14.4 Form Validation

```dart
class ValidationUtils {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName is required";
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  static String? validatePhone(String? value, String countryCode) {
    if (value == null || value.isEmpty) {
      return "Phone number is required";
    }
    try {
      final phoneNumber = PhoneNumber.parse("+$countryCode$value");
      if (!phoneNumber.isValid()) {
        return "Enter a valid phone number";
      }
    } catch (e) {
      return "Enter a valid phone number";
    }
    return null;
  }
}
```

---

## 15. Build & Deployment

### Android Build

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS Build

```bash
# Debug
flutter build ios --debug

# Release
flutter build ios --release

# Archive for App Store
flutter build ipa --release
```

### Environment Switching

```dart
// lib/app/core/constants/app_constant.dart
enum Environment { dev, test, prod }

class AppConstants {
  static const Environment env = Environment.dev;

  static String get baseUrl {
    switch (env) {
      case Environment.dev:
        return "https://mobapidev.bellybutton.global/api";
      case Environment.test:
        return "https://mobapitest.bellybutton.global/api";
      case Environment.prod:
        return "https://mobapi.bellybutton.global/api";
    }
  }
}
```

### Platform Requirements

| Platform | Minimum Version |
|----------|-----------------|
| Android | API 21 (Android 5.0) |
| iOS | iOS 12.0 |
| macOS | macOS 10.14 |

---

## Quick Reference

### Common Commands

```bash
# Run app
flutter run

# Run with specific device
flutter run -d <device_id>

# Build release
flutter build apk --release

# Clean build
flutter clean && flutter pub get

# Analyze code
flutter analyze

# Run tests
flutter test
```

### Project Links

- **Repository**: github.com/bellybuttonapp/Bellybutton_Frontend
- **Developer**: Aravinth Kannan
- **Email**: flutterdev.aravinth@gmail.com

---

*Documentation generated for BellyButton Flutter App v1.0.0*
