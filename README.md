# Kigali Directory 

Hello, Welcome to the Kigali Directory - your personal guide to find amazing places around Kigali, Rwanda. This Flutter app helps you find, share, and manage information about local spots.

###  Core Features
- ** Interactive Maps**: See exactly where places are located with Google Maps integration
- ** Secure Sign-up**: Create an account with email verification to keep things safe
- ** Share Your Spots**: Add new places you've discovered to help others find them
- ** Update Your Listings**: Made a mistake? No problem! Edit your listings anytime
- ** Remove Listings**: Clean up your contributions when needed
- ** Rate & Review**: Share your experiences with 5-star ratings and written reviews
- ** Save Favorites**: Bookmark places you love for quick access later

###  User Experience
- ** Smart Search**: Find places by name, address, or browse by category
- ** Beautiful Dark Theme**: Easy on the eyes, perfect for night browsing
- ** Live Updates**: See new places and reviews appear in real-time
- ** Organized Categories**: Everything neatly sorted for easy browsing

## Tech

### Frontend
- **Flutter 3.0+** - Cross-platform mobile framework
- **Provider** - State management
- **Google Maps Flutter** - Interactive mapping
- **Geolocator** - Location services

### Backend
- **Firebase Authentication** - User authentication
- **Cloud Firestore** - Real-time database
- **Firebase Core** - Firebase SDK integration

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^4.5.0
  firebase_auth: ^6.2.0
  cloud_firestore: ^6.1.3
  
  # State Management
  provider: ^6.1.2
  
  # Maps & Navigation
  google_maps_flutter: ^2.9.0
  url_launcher: ^6.3.1
  
  # Location
  geolocator: ^14.0.2
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Firebase account
- Google Maps API key

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd individual_assignment2
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication (Email/Password)
   - Set up Cloud Firestore
   - Add your Android/iOS app to Firebase
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place config files in the appropriate directories

4. **Firebase Indexes**
   - Deploy Firestore indexes for optimal query performance:
   ```bash
   firebase deploy --only firestore:indexes
   ```
   - Or manually create the required index in Firebase Console:
     - Collection: `listings`
     - Fields: `createdBy` (Ascending) + `timestamp` (Descending)

5. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── theme.dart                # App theme and colors
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
│   ├── listing_model.dart
│   ├── review_model.dart
│   └── user_model.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   └── listings_provider.dart
├── services/                 # Business logic
│   ├── auth_service.dart
│   └── firestore_service.dart
├── screens/                  # UI screens
│   ├── auth/                 # Authentication screens
│   ├── directory/            # Directory browsing
│   ├── my_listings/          # User's listings management
│   ├── map/                  # Map view
│   └── settings/             # App settings
└── widgets/                  # Reusable components
    └── shared_widgets.dart
```

##  Configuration

### Firebase Configuration
1. Update `firebase_options.dart` with your Firebase project settings
2. Ensure proper Firebase rules are set for security

### Google Maps Integration
1. Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Add the API key to your platform-specific configuration:
   - Android: `android/app/src/main/AndroidManifest.xml`
   - iOS: `ios/Runner/AppDelegate.swift`

###  Categories You'll Find
- ** Café** - Your morning coffee fix
- ** Hospital** - Healthcare facilities  
- ** Pharmacy** - Medical supplies and prescriptions
- ** Police Station** - Safety and security services
- ** Library** - Quiet study and reading spaces
- ** Restaurant** - Local dining spots
- ** Park** - Green spaces for relaxation
- ** Utility Office** - Essential city services

###  In case it's not working
- **Clean slate**: Try `flutter clean` then `flutter pub get`
- **Flutter version**: Make sure you're using Flutter 3.0 or newer
- **Dependencies**: All packages should play nicely together
