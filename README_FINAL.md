# SmartCart - Self-Checkout Revolution

A cutting-edge Flutter-based self-checkout application that transforms retail shopping with intelligent cart management, real-time inventory tracking, and seamless payment processing.

## 🛠️ Tech Stack

### Core Framework
- **Flutter 3.10+**: Cross-platform mobile development
- **Dart 3.0+**: Programming language with null safety

### State Management
- **Provider**: Reactive state management for complex app logic

### Backend & Database
- **Firebase Core**: App initialization and configuration
- **Cloud Firestore**: Real-time NoSQL database
- **Firebase Auth**: User authentication with Google Sign-In
- **Firebase Analytics**: User behavior tracking
- **Firebase Crashlytics**: Error reporting and monitoring
- **Firebase Messaging**: Push notifications

### Mobile Features
- **Mobile Scanner**: QR/Barcode scanning with camera
- **Shared Preferences**: Local data persistence
- **Connectivity Plus**: Network status monitoring
- **Vibration**: Haptic feedback
- **Flutter TTS**: Voice feedback for accessibility
- **URL Launcher**: Payment app integration
- **Permission Handler**: Runtime permissions
- **Package Info Plus**: App version information

### UI & UX
- **Material Design 3**: Modern Android design system
- **FL Chart**: Data visualization
- **Intl**: Internationalization support
- **Flutter Launcher Icons**: Custom app icons

### Development Tools
- **Flutter Lints**: Code quality enforcement
- **Mockito**: Unit testing mocks
- **Integration Test**: End-to-end testing

## 🚀 Setup Instructions for New Engineers

### Prerequisites
1. **Flutter SDK**: Install Flutter 3.10+ from [flutter.dev](https://flutter.dev)
2. **Android Studio**: With Android SDK 33+
3. **VS Code**: With Flutter and Dart extensions
4. **Git**: Version control (optional, as per team workflow)

### Environment Setup

1. **Clone the Repository** (if using Git):
   ```bash
   git clone <repository-url>
   cd SmartCart
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**:
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Enable Authentication, Firestore, Analytics, Crashlytics, and Messaging
   - Download `google-services.json` and place in `android/app/src/main/`
   - Update `firebase_options.dart` with your project configuration

4. **Android Configuration**:
   - Open `android/app/build.gradle`
   - Update `applicationId` to your package name
   - Configure signing config for release builds

5. **Generate App Icons**:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

### Development Workflow

1. **Run Analysis**:
   ```bash
   flutter analyze
   ```

2. **Run Tests**:
   ```bash
   flutter test
   ```

3. **Run Integration Tests**:
   ```bash
   flutter test integration_test/
   ```

4. **Build Debug APK**:
   ```bash
   flutter build apk --debug
   ```

5. **Build Release APK** (Production):
   ```bash
   # Run the gatekeeper script first
   .\publish_check.ps1

   # Or manually
   flutter build apk --release --split-per-abi
   ```

### Key Architecture Notes

- **Precision Money Handling**: All prices stored in paise/cents (integers) to prevent floating-point errors
- **Stock Validation**: Prevents negative inventory through transaction-based updates
- **State Management**: Provider pattern with ChangeNotifier for reactive UI
- **Error Handling**: Comprehensive try-catch blocks with user-friendly messages
- **Security**: SHA-1 fingerprint verification for Google Sign-In

### Testing Strategy

- **Unit Tests**: Business logic validation in `test/`
- **Widget Tests**: UI component verification
- **Integration Tests**: Full user flow testing
- **Golden Tests**: Visual regression prevention

### Deployment

1. **Pre-deployment Checklist**:
   - Run `./publish_check.ps1` (Windows) or equivalent script
   - Verify all tests pass
   - Check Firebase configuration
   - Validate Android manifest permissions

2. **Google Play Store**:
   - Generate signed APK/AAB
   - Upload to Play Console
   - Configure store listing with screenshots
   - Set up internal/closed testing tracks

3. **Post-deployment**:
   - Monitor Crashlytics for issues
   - Track Analytics for user engagement
   - Update CHANGELOG.md for future releases

## 📞 Support

For technical issues or questions:
- Check the CHANGELOG.md for recent updates
- Review Firebase console for backend issues
- Run diagnostic tests in the app settings

## 📄 License

This project is proprietary software. All rights reserved.