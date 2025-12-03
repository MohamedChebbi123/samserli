# 🏡 Samsarli - Real Estate Mobile Application

A modern, feature-rich Flutter application for real estate property listings, messaging, and management. Built with Material Design 3 and a comprehensive design system.

## 📱 Overview

Samsarli is a full-featured real estate platform that enables users to browse properties, manage listings, communicate with property owners, and discover real estate opportunities through an interactive map interface.

## ✨ Key Features

### 🔐 Authentication & User Management
- **User Registration** - Complete onboarding with profile picture upload
- **Secure Login** - JWT-based authentication with secure token storage
- **Password Recovery** - Multi-step password reset flow with email verification
- **User Profile** - View and manage personal information
- **Edit Profile** - Update profile details, phone number, and profile picture
- **Secure Storage** - Flutter Secure Storage for sensitive data

### 🏠 Property Features
- **Property Listings** - Browse all available properties with rich details
- **Advanced Filtering** - Filter by price range, number of rooms, and property status
- **Property Details** - Comprehensive property view with image galleries, maps, and owner information
- **Your Properties** - Manage your own property listings
- **Add Property** - Create new listings with multiple images and location data
- **Edit Property** - Update existing property information and images
- **Property Status** - Distinguish between "For Rent" and "For Sale" properties
- **Interactive Maps** - Google Maps integration for property locations
- **Favorites System** - Save and manage favorite properties

### 💬 Messaging & Communication
- **Direct Messaging** - Real-time chat with property owners
- **Message Inbox** - Centralized conversation management
- **Unread Notifications** - Badge indicators for unread messages
- **User Blocking** - Block/unblock users for privacy
- **Image Sharing** - Send and receive images in conversations
- **Message Editing** - Edit sent messages
- **Message Deletion** - Delete messages with confirmation
- **Read Status Tracking** - Mark conversations as read

### 🗺️ Map & Location
- **Interactive Map View** - Browse properties on Google Maps
- **Current Location** - Automatic location detection with permission handling
- **Custom Markers** - Property markers with custom styling
- **Location-based Search** - Find properties near you
- **Add Property on Map** - Create listings by selecting location on map

### 🎨 Design & UI
- **Material Design 3** - Modern, clean interface following Material Design guidelines
- **Custom Design System** - Unified color palette, typography, and spacing
- **Responsive Layout** - Optimized for various screen sizes
- **Beautiful Animations** - Smooth transitions and loading states
- **Dark Mode Ready** - Color scheme prepared for dark theme implementation
- **Custom Theme** - Consistent branding throughout the app

## 🛠️ Technical Stack

### Dependencies
```yaml
- Flutter SDK: ^3.9.0
- http: ^1.2.0 - API communication
- image_picker: ^1.1.1 - Image selection
- permission_handler: ^11.3.1 - Permission management
- flutter_secure_storage: ^9.2.4 - Secure data storage
- google_maps_flutter: ^2.13.1 - Map integration
- geolocator: ^13.0.1 - Location services
```

## 📂 Project Structure

```
lib/
├── assets/              # Application assets (images, icons)
├── components/          # Reusable UI components
│   └── navabr.dart     # Bottom navigation bar with notification badges
├── constants/           # App-wide constants
│   ├── app_colors.dart      # Color palette
│   ├── app_spacing.dart     # Spacing system
│   └── app_text_styles.dart # Typography
├── pages/
│   ├── auth/           # Authentication screens
│   │   ├── login.dart
│   │   ├── register.dart
│   │   ├── profile.dart
│   │   ├── edit_profile.dart
│   │   ├── forgot_password.dart
│   │   ├── forgot_password_verify.dart
│   │   └── forgot_password_reset.dart
│   ├── houses/         # Property-related screens
│   │   ├── houseslist.dart      # Browse all properties
│   │   ├── housedetails.dart    # Property details view
│   │   ├── your_properties.dart # User's listings
│   │   ├── edit_property.dart   # Edit property
│   │   ├── favourites.dart      # Saved properties
│   │   ├── map.dart            # Map view & add property
│   │   └── message_user.dart   # Chat with owner
│   ├── messages/       # Messaging screens
│   │   └── messages_inbox.dart
│   └── splash_screen.dart
├── services/           # Business logic & services
│   └── notification_service.dart
└── main.dart          # Application entry point
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.9.0)
- Dart SDK
- Android Studio / Xcode (for iOS)
- A backend API running (see backend configuration)

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd samserli/frontend
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure API endpoint**
Update the API base URL in the code (currently set to `http://10.0.2.2:8000` for Android emulator)

4. **Run the app**
```bash
flutter run
```

### Platform-Specific Setup

#### Android
- Minimum SDK: Check `android/app/build.gradle`
- Add Google Maps API key in `android/app/src/main/AndroidManifest.xml`

#### iOS
- Update `ios/Runner/Info.plist` with required permissions
- Add Google Maps API key in `ios/Runner/AppDelegate.swift`

## 🎨 Design System

The app follows a comprehensive design system documented in `DESIGN_SYSTEM.md`:

### Color Palette
- **Primary**: `#2E7FD8` - Main brand color
- **Secondary**: `#00A699` - Accent color
- **Background**: `#F7F7F7` - App background
- **Success/Warning/Error** - Semantic colors for status indicators

### Typography
- Consistent font sizes and weights
- Proper text hierarchy
- Accessible contrast ratios

### Spacing
- Systematic spacing scale (4px, 8px, 16px, 24px, 32px, 48px)
- Consistent padding and margins

## 🔑 Key Screens

### Authentication Flow
1. **Splash Screen** - Animated intro with brand logo
2. **Login** - Email/password authentication
3. **Register** - New user onboarding with profile picture
4. **Forgot Password** - Email verification and password reset

### Main Application
1. **Properties List** - Browse and filter properties
2. **Property Details** - Full property information with image gallery
3. **Map View** - Interactive property discovery
4. **Messages** - Communication hub
5. **Profile** - User account management
6. **Your Properties** - Listing management
7. **Favorites** - Saved properties

## 📡 API Integration

The app communicates with a FastAPI backend. All API calls include:
- JWT Bearer token authentication
- JSON/Multipart form data support
- Error handling and user feedback
- Secure token storage

## 🔒 Security Features

- Secure token storage using `flutter_secure_storage`
- JWT-based authentication
- Password reset with email verification
- User blocking functionality
- Permission-based access (location, camera, gallery)

## 🎯 Features Breakdown

### Property Management
- ✅ Browse properties with filtering
- ✅ View detailed property information
- ✅ Add new properties with images
- ✅ Edit existing properties
- ✅ Delete properties
- ✅ Mark properties as favorites
- ✅ Filter by price, rooms, status

### Messaging System
- ✅ Direct user-to-user messaging
- ✅ Image sharing in messages
- ✅ Message editing and deletion
- ✅ Unread message indicators
- ✅ Block/unblock users
- ✅ Conversation management

### Map Integration
- ✅ View properties on map
- ✅ Custom property markers
- ✅ Current location tracking
- ✅ Add property by map location
- ✅ Permission handling

## 🧪 Development

### Code Organization
- **Separation of Concerns** - Clear separation between UI, logic, and data
- **Reusable Components** - Custom widgets and components
- **Constants Management** - Centralized theme and styling
- **Service Pattern** - Business logic in dedicated services

### Best Practices
- Material Design 3 guidelines
- Flutter best practices
- Responsive design principles
- Error handling and user feedback
- Loading states and animations

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ⚠️ Web (requires configuration)
- ⚠️ Windows (requires configuration)
- ⚠️ macOS (requires configuration)
- ⚠️ Linux (requires configuration)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is licensed under the terms specified in the repository.

## 🆘 Support

For issues, questions, or contributions, please refer to the project's issue tracker.

---

**Built with ❤️ using Flutter**
