# 🏡 Real Estate Application

A modern, full-stack real estate platform that connects property buyers, sellers, and renters through an intuitive mobile and web interface. Built with Flutter and FastAPI, this application provides a seamless experience for property discovery, management, and communication.

## 📋 Table of Contents
- [About the Project](#about-the-project)
- [Key Features](#key-features)
- [Technology Stack](#technology-stack)
- [Screenshots](#screenshots)
- [Getting Started](#getting-started)
- [API Documentation](#api-documentation)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)

---

## 📱 Screenshots

### User Profile & Management
<p align="center">
  <img src="app%20screenshots/user%20profile.png" alt="User Profile" width="250"/>
  <img src="app%20screenshots/user%20properties.png" alt="User Properties" width="250"/>
  <img src="app%20screenshots/block%20user.png" alt="Block User" width="250"/>
</p>

### Property Browsing & Details
<p align="center">
  <img src="app%20screenshots/explore%20poster%20properties.png" alt="Explore Properties" width="250"/>
  <img src="app%20screenshots/filter.png" alt="Filter Properties" width="250"/>
  <img src="app%20screenshots/house%20details%20part%201.png" alt="House Details 1" width="250"/>
</p>

<p align="center">
  <img src="app%20screenshots/house%20details%20part%202.png" alt="House Details 2" width="250"/>
  <img src="app%20screenshots/houses%20with%20map%20palcemnt.png" alt="Map View" width="250"/>
  <img src="app%20screenshots/favourites.png" alt="Favorites" width="250"/>
</p>

### Property Management
<p align="center">
  <img src="app%20screenshots/house%20adding%20form.png" alt="Add Property" width="250"/>
  <img src="app%20screenshots/house%20detail%20with%20edit%20and%20delet.png" alt="Edit & Delete Property" width="250"/>
</p>

### Messaging System
<p align="center">
  <img src="app%20screenshots/messages%20inbox.png" alt="Messages Inbox" width="250"/>
  <img src="app%20screenshots/messages.png" alt="Messages" width="250"/>
  <img src="app%20screenshots/messaging.png" alt="Messaging" width="250"/>
</p>

---

## 🎯 About the Project

This real estate application is designed to simplify the property search and listing process. Whether you're looking to buy, sell, or rent a property, our platform provides all the tools you need in one place. With powerful search capabilities, real-time messaging, and secure user authentication, users can confidently navigate the real estate market.

### Why This Project?

- **User-Centric Design**: Intuitive interface designed for both tech-savvy users and beginners
- **Cross-Platform**: Works seamlessly on iOS, Android, and Web
- **Communication**: Built-in messaging system to connect buyers and sellers instantly
- **Secure & Reliable**: JWT authentication, password encryption, and secure data storage
- **Scalable Architecture**: Built with modern technologies that can grow with your needs

---

## ✨ Key Features

### Backend
- **Framework**: FastAPI (Python 3.x)
- **ORM**: SQLAlchemy
- **Database**: PostgreSQL
- **Authentication**: JWT (JSON Web Tokens)
- **Password Hashing**: bcrypt/passlib
- **Image Storage**: Cloudinary
- **Email**: SMTP
- **CORS**: FastAPI CORS Middleware

### Frontend
- **Framework**: Flutter (Dart)
- **Platforms**: iOS, Android, Web
- **State Management**: Built-in Flutter state management
- **HTTP Client**: dio/http package
- **Secure Storage**: flutter_secure_storage
- **Navigation**: Flutter Navigator 2.0
- **UI Components**: Material Design 3

### External Services
- **Cloudinary**: Image CDN and storage
- **SMTP Server**: Email delivery
- **PostgreSQL**: Relational database

---

### Prerequisites
- Python 3.8+
- PostgreSQL database
- Flutter SDK (3.0+)
- Cloudinary account
- SMTP email account

### Backend Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd realestateapp/backend
   ```

2. **Create virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate 
   On Windows: venv/Scripts/activate
   ```

3. **Install dependencies**
   ```bash
   pip install fastapi uvicorn sqlalchemy psycopg2-binary python-dotenv python-multipart pyjwt passlib cloudinary python-jose email-validator
   ```

4. **Configure environment variables**
   Create a `.env` file in the backend directory:
   ```env
   DATABASE_URL=postgresql://user:password@localhost:5432/realestate_db
   JWT_SECRET_KEY=your-secret-key-here
   JWT_ALGORITHM=HS256
   CLOUDINARY_CLOUD_NAME=your-cloud-name
   CLOUDINARY_API_KEY=your-api-key
   CLOUDINARY_API_SECRET=your-api-secret
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=587
   SMTP_USERNAME=your-email@gmail.com
   SMTP_PASSWORD=your-email-password
   ```

5. **Run database migrations**
   ```bash
   # The models will auto-create tables on first run
   ```

6. **Start the backend server**
   ```bash
   python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
   ```

   The API will be available at `http://localhost:8000`
   API documentation: `http://localhost:8000/docs`

### Frontend Setup (Flutter)

1. **Navigate to frontend directory**
   ```bash
   cd ../frontend
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   Update the API base URL in `lib/constants/config.js`:
   ```dart
   const String API_BASE_URL = 'http://localhost:8000';
   ```

4. **Run the application**
   ```bash
   # For web
   flutter run -d chrome
   
   # For mobile (with emulator running)
   flutter run
   
   # For specific platform
   flutter run -d android
   flutter run -d ios
   ```

### Database Schema

The application will automatically create the following tables:
- `users` - User accounts
- `houses` - Property listings
- `message` - User messages
- `favourites` - User favorite properties
- `blocked_users` - Blocked user relationships
- `password_reset` - Password reset tokens

---

## API Endpoints

### User Endpoints
- `POST /register_new_user` - Register a new user
- `POST /login_user` - User login
- `GET /view_profile` - View user profile
- `PUT /edit_profile` - Edit user profile
- `POST /send_message` - Send a message
- `GET /get_conversation` - Get conversation with a user
- `PUT /update_message` - Update a message
- `DELETE /delete_message` - Delete a message
- `GET /get_all_conversations` - Get all user conversations
- `GET /get_unread_message_count` - Get unread message count
- `PUT /mark_conversation_as_read` - Mark conversation as read
- `POST /block_user` - Block a user
- `DELETE /unblock_user` - Unblock a user
- `GET /check_block_status` - Check block status
- `GET /get_blocked_users` - Get list of blocked users
- `POST /request_password_reset` - Request password reset
- `POST /verify_reset_code` - Verify reset code
- `POST /reset_password` - Reset password

### House Endpoints
- `POST /add_house` - Add a new property
- `GET /fetch_houses` - Fetch all properties
- `GET /fetch_user_properties` - Fetch user's properties
- `DELETE /delete_user_property` - Delete a property
- `PUT /modify_user_property` - Modify a property
- `POST /add_to_favourites` - Add property to favorites
- `DELETE /remove_from_favourites` - Remove from favorites
- `GET /get_user_favourites` - Get user's favorite properties
- `GET /check_if_favourite` - Check if property is favorited

---

## Security Considerations

- **Authentication**: JWT-based authentication with secure token generation
- **Password Hashing**: Passwords are hashed using bcrypt
- **CORS**: Configured to allow specific origins in production
- **SQL Injection**: Protected by SQLAlchemy ORM
- **File Upload**: Validated file types and sizes for image uploads
- **Email Verification**: Password reset requires email verification
- **Token Expiration**: JWT tokens have expiration times

---

## Future Enhancements

- [ ] Real-time notifications using WebSockets
- [ ] Advanced property search filters
- [ ] Property comparison feature
- [ ] Virtual property tours
- [ ] Payment integration
- [ ] Review and rating system
- [ ] Admin dashboard
- [ ] Analytics and reporting
- [ ] Multi-language support
- [ ] Dark mode theme

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License.

---



## Acknowledgments

- FastAPI for the excellent Python web framework
- Flutter for cross-platform mobile development
- Cloudinary for image management
- PostgreSQL for reliable data storage
### 🔐 User Authentication & Account Management

- **Secure Registration**: Create your account with email verification and profile picture upload
- **JWT Authentication**: Industry-standard secure login with JSON Web Tokens
- **Profile Management**: Update your personal information, profile picture, and contact details anytime
- **Password Recovery**: Secure password reset via email with verification codes
---

## 📚 API Documentation

The API is fully documented with interactive Swagger UI. Once the backend is running, visit `http://localhost:8000/docs` to explore all endpoints.

### API Endpoints Overviewple property photos
  - Add detailed descriptions
  - Set pricing and availability
  - Specify location on map

- **Manage Your Listings**: Full control over your properties
  - Edit property details anytime
  - Update photos and descriptions
  - Change pricing
  - Delete listings when sold/rented

- **Favorites System**: Save properties you're interested in
  - Quick add/remove from favorites
  - View all your saved properties in one place
  - Never lose track of properties you like

### 💬 Real-Time Messaging System

- **Direct Communication**: Contact property owners instantly
- **Conversation Management**: 
  - View all your conversations in one inbox
  - Edit or delete your messages
  - Track unread message counts
  - Mark conversations as read
- **Privacy Controls**: Block users to prevent unwanted messages
- **Message History**: Access complete conversation history with each user

### 🗺️ Location-Based Features

- **Geolocation Support**: All properties include precise GPS coordinates
- **Map Integration**: View property locations on interactive maps
- **Location-Based Search**: Find properties in your preferred areas

### 📸 Media Management

- **Cloud Storage**: All images stored securely on Cloudinary CDN
- **Multiple Images**: Upload and display multiple property photos
- **Profile Pictures**: Personalize your account with profile photos
- **Fast Loading**: Optimized image delivery for quick page loads
---

## 📁 Project Structure

```
realestateapp/
├── backend/                  # FastAPI Backend Server
│   ├── controller/           # Business logic controllers
│   ├── database/             # Database connection setup
│   ├── models/               # SQLAlchemy database models
│   ├── routes/               # API route definitions
│   ├── schemas/              # Pydantic validation schemas
│   └── utils/                # Helper utilities (JWT, hashing, etc.)
│
└── frontend/                 # Flutter Mobile & Web App
    ├── lib/
    │   ├── components/       # Reusable UI components
    │   ├── constants/        # App configuration & theme
    │   ├── pages/            # Screen pages
    │   └── services/         # API communication services
    ├── android/              # Android build configuration
    ├── ios/                  # iOS build configuration
    └── web/                  # Web build configuration
```

---

## 🎯 Use Cases

### For Property Buyers/Renters
- Browse available properties with detailed information and photos
- Save favorite properties for later viewing
- Contact property owners directly through in-app messaging
- Filter properties by availability (sale/rent)
- Track all your inquiries in one place

### For Property Owners/Agents
---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👥 Team & Contact

For questions, suggestions, or collaboration opportunities, please contact the development team.

**Repository**: [samserli](https://github.com/MohamedChebbi123/samserli)

---

## 🙏 Acknowledgments

- **FastAPI** - For the powerful and fast Python web framework
- **Flutter** - For enabling beautiful cross-platform development
- **Cloudinary** - For reliable image hosting and CDN services
- **PostgreSQL** - For robust and scalable data storage
- All contributors and users who provide feedback to improve the platform

---

## ⭐ Star This Project

If you find this project useful, please consider giving it a star on GitHub! Your support is appreciated.

---

**Built with ❤️ using Flutter and FastAPI**bSockets
- [ ] Property comparison feature
- [ ] Virtual property tours with 360° images
- [ ] Payment gateway integration
- [ ] Review and rating system for properties
- [ ] Admin dashboard for platform management
- [ ] Analytics and insights for property owners
- [ ] Multi-language support
- [ ] Dark mode theme
- [ ] Property scheduling and viewing appointments
- [ ] Mortgage calculator
- [ ] Neighborhood information integration

---

## 🤝 Contributing* - Powerful ORM for database operations
- **JWT (JSON Web Tokens)** - Secure authentication
- **Bcrypt** - Password hashing and encryption

### Database & Storage
- **PostgreSQL** - Robust relational database
- **Cloudinary** - Cloud-based image storage and CDN

### Services
- **SMTP** - Email delivery for notifications and password resets

---

## 📐 Architecture - C4 Model

### Level 1: System Context Diagram
![System Context Diagram](samserli%20images/lvl1%20c4%20model.png)

### Level 2: Container Diagram
![Container Diagram](samserli%20images/lvl2%20c4%20model.png)

### Level 3: Component Diagram
![Component Diagram](samserli%20images/lvl3%20c4%20model.png)

### Level 4: Code Diagram
![Code Diagram](samserli%20images/lvl4%20c4%20model.png)

