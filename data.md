# Real Estate Application - Feature Documentation

## 🏗️ Application Overview
A full-stack real estate platform built with **FastAPI (Backend)** and **Flutter (Frontend)** that enables users to browse, list, and manage property listings with integrated messaging and favorites functionality.

---

## 📱 **AUTHENTICATION & USER MANAGEMENT**

### 1. User Registration
- **Backend Route**: `POST /register_new_user`
- **Features**:
  - Multi-part form data upload
  - User profile picture upload to Cloudinary
  - Password hashing with bcrypt
  - Email and phone number uniqueness validation
  - JWT token generation upon successful registration
- **Frontend**: `register.dart`
  - Form validation
  - Image picker for profile picture
  - Secure storage of JWT token

### 2. User Login
- **Backend Route**: `POST /login_user`
- **Features**:
  - Email/password authentication
  - Password verification
  - JWT token generation
  - Secure token storage
- **Frontend**: `login.dart`
  - Login form with validation
  - Error handling and feedback
  - Auto-redirect after successful login

### 3. Password Recovery System
- **Backend Routes**: 
  - `POST /request_password_reset`
  - `POST /verify_reset_code`
  - `POST /reset_password`
- **Features**:
  - Email-based verification code system
  - 15-minute expiration on reset codes
  - Secure code generation (6 digits)
  - Email sending via SMTP
  - Password hashing on reset
- **Frontend**:
  - `forgot_password.dart` - Email submission
  - `forgot_password_verify.dart` - 4-digit code verification UI
  - `forgot_password_reset.dart` - New password entry

### 4. User Profile Management
- **Backend Routes**:
  - `GET /get_profile` - View profile
  - `PUT /edit_profile` - Update profile
- **Features**:
  - JWT-based profile retrieval
  - Profile picture update with Cloudinary
  - Selective field updates (first name, last name, phone number)
  - Profile data validation
- **Frontend**:
  - `profile.dart` - Enhanced profile display with gradient design
  - `edit_profile.dart` - Profile editing with image picker
  - Real-time profile updates

---

## 🏠 **PROPERTY MANAGEMENT**

### 5. Property Listing Creation
- **Backend Route**: `POST /add_house`
- **Features**:
  - Multiple image uploads (up to 10 images)
  - Image upload to Cloudinary with folder organization
  - Geolocation storage (latitude/longitude)
  - Property details: name, description, price, rooms, status
  - JWT authentication required
  - Automatic owner association
- **Frontend**: Property creation form (integrated in app)
  - Image picker with multiple selection
  - Location picker/manual entry
  - Form validation

### 6. Browse Properties
- **Backend Route**: `GET /fetch_houses`
- **Features**:
  - Retrieve all available properties
  - Owner information included
  - Image URLs returned
  - Authentication required
- **Frontend**: `houseslist.dart`
  - Grid/List view of properties
  - Filter by price range
  - Filter by number of rooms
  - Filter by status (For Sale/For Rent)
  - Property cards with image carousel
  - Quick favorite toggle
  - Search functionality

### 7. User's Property Portfolio
- **Backend Route**: `GET /fetch_user_properties`
- **Features**:
  - Retrieve properties owned by authenticated user
  - Owner verification via JWT
- **Frontend**: `your_properties.dart`
  - Display user's listed properties
  - Edit/Delete options
  - Property status management

### 8. Property Details View
- **Backend**: Data provided via fetch_houses endpoint
- **Features**:
  - Full property information display
  - Image gallery with swipe
  - Google Maps integration
  - Owner contact information
  - Direct messaging to owner
  - Favorite toggle
- **Frontend**: `housedetails.dart`
  - Image carousel
  - Interactive map with property location
  - Contact owner button
  - Share property option
  - Add to favorites

### 9. Edit Property
- **Backend Route**: `PUT /modify_property`
- **Features**:
  - Update property information
  - Add new images (preserved old images)
  - Selective field updates
  - Owner verification
  - Image upload to Cloudinary
- **Frontend**: `edit_property.dart`
  - Pre-filled form with current data
  - Image picker for new images
  - Update validation

### 10. Delete Property
- **Backend Route**: `DELETE /delete_property/{house_id}`
- **Features**:
  - Owner verification
  - Cascading deletion (removes favorites)
  - JWT authentication required
- **Frontend**: Integrated in `your_properties.dart`
  - Confirmation dialog
  - Success feedback

---

## ⭐ **FAVORITES SYSTEM**

### 11. Add to Favorites
- **Backend Route**: `POST /add_to_favourites/{house_id}`
- **Features**:
  - Add property to user's favorites
  - Duplicate prevention
  - User authentication required
  - Foreign key relationships maintained
- **Frontend**: Favorite button in property cards and details
  - Toggle favorite status
  - Visual feedback (filled/unfilled heart)

### 12. Remove from Favorites
- **Backend Route**: `DELETE /remove_from_favourites/{house_id}`
- **Features**:
  - Remove property from favorites
  - User authentication
  - Cascade deletion handling
- **Frontend**: Toggle off from favorite button

### 13. View Favorites
- **Backend Route**: `GET /get_favourites`
- **Features**:
  - Retrieve all user's favorited properties
  - Full property details included
  - Owner information provided
- **Frontend**: `favourites.dart`
  - Dedicated favorites page
  - Grid layout
  - Quick unfavorite option
  - Navigate to property details

### 14. Check Favorite Status
- **Backend Route**: `GET /check_favourite/{house_id}`
- **Features**:
  - Check if property is favorited by user
  - Returns boolean status
  - Used for UI state management
- **Frontend**: Updates favorite button state

---

## 💬 **MESSAGING SYSTEM**

### 15. Send Message
- **Backend Route**: `POST /send_message`
- **Features**:
  - Text message sending
  - **Image attachment support** (uploaded to Cloudinary)
  - Sender/receiver validation
  - Message timestamp
  - JWT authentication
- **Frontend**: `message_user.dart`
  - Real-time chat interface
  - Image picker for attachments
  - Image preview before sending
  - Message bubbles (sent/received)
  - Full-screen image viewer

### 16. Get Conversation
- **Backend Route**: `GET /get_conversation/{other_user_id}`
- **Features**:
  - Retrieve all messages between two users
  - Ordered by timestamp
  - Sender/receiver information included
  - Image URLs included
- **Frontend**: `message_user.dart`
  - Chat history display
  - Auto-scroll to latest message
  - Message grouping by sender

### 17. Update Message
- **Backend Route**: `PUT /update_message/{message_id}`
- **Features**:
  - Edit message content
  - Sender verification
  - JWT authentication
- **Frontend**: Long-press to edit (if implemented)

### 18. Delete Message
- **Backend Route**: `DELETE /delete_message/{message_id}`
- **Features**:
  - Delete message by ID
  - Sender verification
  - JWT authentication
- **Frontend**: Long-press to delete (if implemented)

### 19. Conversations Inbox
- **Backend Route**: `GET /get_all_conversations`
- **Features**:
  - List all conversations for authenticated user
  - Last message preview
  - Unread message count per conversation
  - Conversation partner details
  - Timestamp of last message
- **Frontend**: `messages_inbox.dart`
  - Conversation list
  - Unread badges
  - Swipe to delete (if implemented)
  - Last message preview
  - User avatars

### 20. Unread Message Count
- **Backend Route**: `GET /get_unread_message_count`
- **Features**:
  - Total unread messages across all conversations
  - Real-time count
  - Used for notification badges
- **Frontend**: `notification_service.dart`
  - Badge on messages tab
  - Periodic polling

### 21. Mark Conversation as Read
- **Backend Route**: `POST /mark_conversation_as_read/{other_user_id}`
- **Features**:
  - Mark all messages from specific user as read
  - Updates unread count
  - JWT authentication
- **Frontend**: Auto-triggered when opening conversation

---

## 🚫 **USER BLOCKING SYSTEM**

### 22. Block User
- **Backend Route**: `POST /block_user/{user_id_to_block}`
- **Features**:
  - Block specific user
  - Prevents messaging
  - Hides properties from blocked user
  - JWT authentication
- **Frontend**: Block option in user profile/messages

### 23. Unblock User
- **Backend Route**: `DELETE /unblock_user/{user_id_to_unblock}`
- **Features**:
  - Unblock previously blocked user
  - Restores messaging capability
  - JWT authentication
- **Frontend**: Unblock option in blocked users list

### 24. Check Block Status
- **Backend Route**: `GET /check_block_status/{other_user_id}`
- **Features**:
  - Check if user is blocked or has blocked you
  - Returns bidirectional block status
  - Used for UI conditional rendering
- **Frontend**: Controls message/contact options

### 25. Get Blocked Users List
- **Backend Route**: `GET /get_blocked_users`
- **Features**:
  - Retrieve all blocked users
  - User details included
  - JWT authentication
- **Frontend**: Blocked users management page

---

## 🗺️ **LOCATION & MAP FEATURES**

### 26. Interactive Map View
- **Features**:
  - Google Maps integration
  - Property markers on map
  - Cluster markers for nearby properties
  - Tap marker to view property details
  - Current location tracking
  - Distance calculation
- **Frontend**: `map.dart`
  - Google Maps Flutter widget
  - Custom property markers
  - Info windows
  - Zoom controls

---

## 🔔 **NOTIFICATION SYSTEM**

### 27. Real-time Notifications
- **Features**:
  - Unread message count tracking
  - Periodic polling (every 30 seconds)
  - Badge display on navigation bar
  - Audio/visual notifications (if implemented)
- **Frontend**: `notification_service.dart`
  - Background polling service
  - State management
  - Badge counter updates

---

## 🎨 **UI/UX FEATURES**

### 28. Navigation System
- **Features**:
  - Bottom navigation bar
  - 7 navigation items:
    1. Home (Properties list)
    2. Map view
    3. Favorites
    4. Messages (with unread badge)
    5. Your Properties
    6. Add Property
    7. Profile
  - Active state highlighting
  - Smooth transitions
- **Frontend**: `navabr.dart`

### 29. Splash Screen
- **Features**:
  - App logo display
  - Loading animation
  - JWT token validation
  - Auto-navigation to login/home
- **Frontend**: `splash_screen.dart`

### 30. Design System
- **Features**:
  - Consistent color palette (primary blue theme)
  - Typography standards
  - Spacing system
  - Shadow elevations
  - Button styles
  - Border radius standards
- **Frontend**:
  - `app_colors.dart` - Color constants
  - `app_text_styles.dart` - Typography
  - `app_spacing.dart` - Spacing/sizing

---

## 🔐 **SECURITY FEATURES**

### 31. JWT Authentication
- **Features**:
  - Token-based authentication
  - 7-day token expiration
  - Secure token storage (Flutter Secure Storage)
  - Token verification on protected routes
- **Implementation**:
  - Backend: `jwt_handler.py`
  - Frontend: Token stored and sent in headers

### 32. Password Security
- **Features**:
  - Bcrypt password hashing
  - Salt generation
  - Password verification
  - Secure password reset
- **Implementation**: `hasher.py`

### 33. Data Validation
- **Features**:
  - Email format validation
  - Phone number uniqueness
  - Required field validation
  - Image file type validation
  - SQL injection prevention (SQLAlchemy ORM)

---

## 📤 **FILE UPLOAD & CLOUD STORAGE**

### 34. Cloudinary Integration
- **Features**:
  - Profile picture uploads
  - Property image uploads (multiple)
  - Message image attachments
  - Folder organization:
    - `profile_pictures/`
    - `house_images/`
    - `message_images/`
  - Automatic optimization
  - Secure URLs
- **Implementation**: `cloudinary_handler.py`

---

## 📧 **EMAIL SYSTEM**

### 35. Email Notifications
- **Features**:
  - Password reset emails
  - Verification code delivery
  - SMTP configuration
  - HTML email templates (if configured)
- **Implementation**: `emailsender.py`

---

## 📊 **DATABASE MODELS**

### Models Overview:
1. **Users** - User account information
2. **Houses** - Property listings
3. **Message** - Chat messages with image support
4. **Favourites** - User's favorite properties
5. **BlockedUsers** - User blocking relationships
6. **PasswordReset** - Password reset tokens and codes

### Relationships:
- Users → Houses (One-to-Many)
- Users → Messages (One-to-Many, bidirectional)
- Users → Favourites (One-to-Many)
- Houses → Favourites (One-to-Many)
- Users → BlockedUsers (Many-to-Many)

---

## 🔧 **TECHNICAL STACK**

### Backend:
- **Framework**: FastAPI
- **Database**: PostgreSQL/MySQL (via SQLAlchemy)
- **ORM**: SQLAlchemy
- **Authentication**: JWT (PyJWT)
- **Password Hashing**: Bcrypt
- **File Storage**: Cloudinary
- **Email**: SMTP
- **CORS**: Enabled for cross-origin requests

### Frontend:
- **Framework**: Flutter/Dart
- **State Management**: StatefulWidget
- **HTTP Client**: http package
- **Secure Storage**: flutter_secure_storage
- **Image Picker**: image_picker
- **Maps**: google_maps_flutter
- **Location**: geolocator

---

## 📝 **API ENDPOINTS SUMMARY**

### Authentication (8 endpoints):
- POST /register_new_user
- POST /login_user
- GET /get_profile
- PUT /edit_profile
- POST /request_password_reset
- POST /verify_reset_code
- POST /reset_password

### Properties (6 endpoints):
- POST /add_house
- GET /fetch_houses
- GET /fetch_user_properties
- PUT /modify_property
- DELETE /delete_property/{house_id}

### Favorites (4 endpoints):
- POST /add_to_favourites/{house_id}
- DELETE /remove_from_favourites/{house_id}
- GET /get_favourites
- GET /check_favourite/{house_id}

### Messaging (6 endpoints):
- POST /send_message
- GET /get_conversation/{other_user_id}
- PUT /update_message/{message_id}
- DELETE /delete_message/{message_id}
- GET /get_all_conversations
- GET /get_unread_message_count
- POST /mark_conversation_as_read/{other_user_id}

### Blocking (4 endpoints):
- POST /block_user/{user_id_to_block}
- DELETE /unblock_user/{user_id_to_unblock}
- GET /check_block_status/{other_user_id}
- GET /get_blocked_users

**Total: 35+ Features | 28 API Endpoints**

---

## 🚀 **KEY HIGHLIGHTS**

✅ **Complete Authentication System** with password recovery
✅ **Real Estate Marketplace** with advanced filtering
✅ **Real-time Messaging** with image attachments
✅ **Favorites Management** with instant toggle
✅ **User Blocking** for safety
✅ **Interactive Maps** with property markers
✅ **Cloud Storage** for images via Cloudinary
✅ **Responsive UI** with modern design
✅ **Secure** JWT authentication
✅ **Email Notifications** for password reset
✅ **Multi-image Upload** for properties
✅ **Profile Management** with picture updates
✅ **Unread Message Tracking**
✅ **Property Portfolio Management**
✅ **Advanced Search & Filters**

---

## 🎯 **USE CASES**

1. **Property Seekers**: Browse, filter, favorite, and contact property owners
2. **Property Owners**: List properties, manage listings, respond to inquiries
3. **Real Estate Agents**: Manage multiple listings, communicate with clients
4. **General Users**: Secure authentication, profile management, messaging

---

*Last Updated: December 3, 2025*
