# React Native Real Estate App - Setup Guide

## Prerequisites

- Node.js (v16 or higher)
- npm or yarn
- Expo CLI (`npm install -g expo-cli`)
- Android Studio (for Android development) or Xcode (for iOS development)
- A running backend server on port 8000

## Step-by-Step Setup

### 1. Install Dependencies

Navigate to the `front` folder and install all dependencies:

```bash
cd front
npm install
```

This will install:
- React Navigation (navigation library)
- Axios (HTTP client)
- Expo packages (SecureStore, Location, ImagePicker, Maps)
- All other required dependencies

### 2. Configure Backend URL

Open `src/constants/config.js` and update the `API_BASE_URL`:

**For Android Emulator:**
```javascript
export const API_BASE_URL = 'http://10.0.2.2:8000';
```

**For iOS Simulator:**
```javascript
export const API_BASE_URL = 'http://localhost:8000';
```

**For Physical Device:**
Find your computer's IP address and use:
```javascript
export const API_BASE_URL = 'http://YOUR_IP_ADDRESS:8000';
```

To find your IP:
- Windows: `ipconfig` in Command Prompt
- Mac/Linux: `ifconfig` in Terminal

### 3. Configure Google Maps (Android Only)

To use Google Maps on Android:

1. Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Enable "Maps SDK for Android"
3. Open `app.json` and replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual API key

```json
"android": {
  "config": {
    "googleMaps": {
      "apiKey": "YOUR_ACTUAL_KEY_HERE"
    }
  }
}
```

### 4. Start Backend Server

Make sure your backend server is running:

```bash
cd backend
python main.py
```

The backend should be accessible at `http://0.0.0.0:8000`

### 5. Start the React Native App

In the `front` folder:

```bash
npm start
```

This will start the Expo development server.

### 6. Run on Device/Emulator

**Option A: Android Emulator**
- Press `a` in the terminal
- Or run: `npm run android`

**Option B: iOS Simulator (Mac only)**
- Press `i` in the terminal
- Or run: `npm run ios`

**Option C: Physical Device**
1. Install "Expo Go" app from App Store/Play Store
2. Scan the QR code shown in the terminal
3. Make sure your device is on the same WiFi network as your computer

## Project Structure Overview

```
front/
├── src/
│   ├── components/          # Reusable UI components
│   ├── constants/           # Theme colors, config
│   ├── navigation/          # Navigation configuration
│   ├── screens/            # All app screens
│   │   ├── auth/           # Login, Register, Profile
│   │   ├── houses/         # Property listings, details, map
│   │   └── messages/       # Messaging
│   └── services/           # API calls, storage, notifications
├── assets/                 # Images and icons
├── App.js                 # Root component
├── app.json               # Expo configuration
└── package.json           # Dependencies

```

## Features Converted from Flutter

✅ **Authentication**
- Login/Register with profile picture upload
- Forgot password with email verification
- Secure token storage

✅ **Property Browsing**
- List all properties with filters
- Filter by price, rooms, status (rent/sale)
- View property details with image carousel
- Add/remove favourites

✅ **Map Integration**
- View properties on interactive map
- Add new properties by tapping map
- Current location detection

✅ **Messaging**
- Real-time messaging between users
- Unread message count badges
- Message property owners

✅ **Profile Management**
- View/edit profile
- View your properties
- View favourites

## Common Issues & Solutions

### Issue: Can't connect to backend from Android Emulator
**Solution:** Use `http://10.0.2.2:8000` instead of `localhost:8000`

### Issue: Location permissions not working
**Solution:** 
- Make sure permissions are configured in `app.json`
- On physical device, grant permissions when prompted
- On Android, check Settings > Apps > RealEstate > Permissions

### Issue: Images not uploading
**Solution:**
- Check camera roll permissions
- Verify backend accepts `multipart/form-data`
- Check file size limits

### Issue: Maps not showing on Android
**Solution:**
- Add Google Maps API key in `app.json`
- Rebuild the app: `expo prebuild --clean`

### Issue: "Module not found" errors
**Solution:**
```bash
rm -rf node_modules
npm install
expo start --clear
```

## Development Tips

### Hot Reload
The app supports hot reload. Save any file and changes will appear instantly.

### Debugging
- Shake your device to open Developer Menu
- Press `j` in terminal to open debugger
- Use `console.log()` for debugging

### Testing on Physical Device
1. Connect to same WiFi as your computer
2. Update API_BASE_URL to use your computer's IP
3. Make sure backend allows connections from network (not just localhost)

### Backend CORS Configuration
Make sure your backend allows requests from mobile app:
```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## Building for Production

### Android APK
```bash
expo build:android
```

### iOS IPA
```bash
expo build:ios
```

### EAS Build (Recommended)
```bash
npm install -g eas-cli
eas build --platform android
eas build --platform ios
```

## Next Steps

1. Replace placeholder images in `assets/` folder
2. Add your actual app logo
3. Test all features thoroughly
4. Configure push notifications (optional)
5. Set up analytics (optional)
6. Build production version

## Support

If you encounter any issues:
1. Check the console logs
2. Verify backend is running and accessible
3. Check all permissions are granted
4. Review the README.md for detailed feature documentation

## Notes

- The original Flutter code is untouched in the `frontend` folder
- This React Native version has feature parity with Flutter version
- All API endpoints match the backend exactly
- Design system matches Flutter version for consistency
