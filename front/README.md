# RealEstate React Native App

A full-featured real estate mobile application built with React Native and Expo, converted from Flutter.

## Features

### 🔐 Authentication
- User registration with profile picture
- Login/Logout
- Forgot password with email verification
- Secure token storage with Expo SecureStore

### 🏠 Property Management
- Browse properties with advanced filtering
- Filter by price range, number of rooms, and status (rent/sale)
- View detailed property information with image carousel
- Add properties to favourites
- Add new properties with location via map
- Upload multiple images for properties
- View properties on interactive map

### 💬 Messaging
- Real-time messaging between users
- Conversation inbox with unread count badges
- Message property owners directly from listings

### 👤 Profile
- View and edit profile information
- View your listed properties
- Access favourites list
- Change password

### 🗺️ Interactive Map
- View all properties on map
- Add new properties by tapping map location
- Get current location
- View property details from map markers

## Tech Stack

- **React Native** with **Expo**
- **React Navigation** for navigation (Stack & Bottom Tabs)
- **Axios** for API calls
- **Expo Location** for geolocation
- **Expo Image Picker** for selecting images
- **React Native Maps** for map integration
- **Expo SecureStore** for secure token storage

## Project Structure

```
front/
├── src/
│   ├── components/          # Reusable components
│   │   └── PropertyCard.js
│   ├── constants/           # Theme and config
│   │   ├── theme.js
│   │   └── config.js
│   ├── navigation/          # Navigation setup
│   │   └── AppNavigator.js
│   ├── screens/            # Screen components
│   │   ├── auth/
│   │   │   ├── LoginScreen.js
│   │   │   ├── RegisterScreen.js
│   │   │   ├── ForgotPasswordScreen.js
│   │   │   └── ProfileScreen.js
│   │   ├── houses/
│   │   │   ├── HousesListScreen.js
│   │   │   ├── HouseDetailsScreen.js
│   │   │   ├── FavouritesScreen.js
│   │   │   └── MapScreen.js
│   │   ├── messages/
│   │   │   └── MessageUserScreen.js
│   │   └── SplashScreen.js
│   └── services/           # API and utility services
│       ├── apiService.js
│       ├── storageService.js
│       └── notificationService.js
├── assets/                 # Images and assets
├── App.js                 # Root component
└── package.json

```

## Installation

1. **Install dependencies:**
```bash
cd front
npm install
```

2. **Configure API endpoint:**
Edit `src/constants/config.js` and update the `API_BASE_URL`:
- For Android Emulator: `http://10.0.2.2:8000`
- For iOS Simulator: `http://localhost:8000`
- For Physical Device: Use your computer's IP address

3. **Start the development server:**
```bash
npm start
```

4. **Run on device/simulator:**
- Press `a` for Android
- Press `i` for iOS
- Scan QR code with Expo Go app for physical device

## Backend Configuration

Make sure your backend server is running on port 8000. The app expects the following API endpoints:

### Authentication
- POST `/login_user`
- POST `/register_new_user`
- POST `/forgot_password`
- POST `/verify_reset_code`
- POST `/reset_password`

### User
- GET `/get_user`
- PUT `/update_profile`

### Houses
- GET `/fetch_houses`
- POST `/add_house`
- GET `/get_user_houses`

### Favourites
- POST `/add_to_favourites/:id`
- DELETE `/remove_from_favourites/:id`
- GET `/get_favourites`

### Messages
- GET `/get_conversations`
- GET `/get_messages/:userId`
- POST `/send_message`
- GET `/get_unread_message_count`
- PUT `/mark_conversation_as_read/:userId`

## Design System

The app uses a consistent design system with:
- **Primary Color:** #2E7FD8
- **Secondary Color:** #00A699
- **Background:** #F7F7F7
- **Consistent spacing, typography, and shadows**

See `src/constants/theme.js` for full theme configuration.

## Key Features Implementation

### Secure Storage
All authentication tokens are stored securely using Expo SecureStore.

### Image Handling
Multiple image upload support for properties using Expo Image Picker.

### Location Services
Integration with device GPS and interactive maps using React Native Maps.

### Real-time Messaging
Messaging system with unread count badges and conversation management.

### Advanced Filtering
Properties can be filtered by:
- Status (Rent/Sale)
- Price range
- Number of rooms

## Building for Production

### Android
```bash
expo build:android
```

### iOS
```bash
expo build:ios
```

## Notes

- The Flutter version remains untouched in the `frontend` folder
- All React Native code is in the `front` folder
- Make sure to grant location and camera roll permissions on device
- For Google Maps on Android, you'll need to add an API key in `app.json`

## Environment Variables

For production, consider using environment variables for:
- API base URL
- Google Maps API key
- Any other sensitive configuration

## Troubleshooting

### Android Emulator Connection Issues
If you can't connect to the backend from Android emulator, make sure:
1. Backend is running on `0.0.0.0:8000` not `localhost:8000`
2. Use `10.0.2.2:8000` in the config

### iOS Simulator Connection Issues
Use `localhost:8000` or your computer's IP address

### Permission Issues
Make sure to grant all required permissions:
- Location (for map features)
- Camera Roll (for image uploads)

## License

This project is part of a real estate application system.
