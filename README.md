# SmartCart

SmartCart is a Flutter-based self-checkout platform for grocery retailers. The mobile app handles scanning, carting, and payments; the web admin dashboard manages inventory, orders, users, and analytics. Backend is powered by Firebase.

## Highlights
- Mobile app: barcode scanning, stock-aware cart, voice/haptics, dark UI
- Admin web: product/order/user management, notifications, analytics
- Backend: Firebase Auth, Firestore, Messaging, Analytics, Crashlytics
- Quality gates: test suite (76 tests), Flutter analyze, `publish_check.ps1` gatekeeper, CI on GitHub Actions

## Tech Stack
- Flutter 3.38.6 (Dart 3.x), Material 3, Provider
- Firebase: Auth, Firestore, Messaging, Analytics, Crashlytics
- Tooling: GitHub Actions (Flutter), `publish_check.ps1`

## Quick Start
1) Prereqs: Flutter 3.38.6+, Android SDK 33+, Firebase CLI (optional)
2) Install:
```bash
git clone https://github.com/yourusername/SmartCart.git
cd SmartCart
flutter pub get
```
3) Firebase:
- Add `android/app/google-services.json`
- Ensure `lib/firebase_options.dart` matches your project (FlutterFire CLI)
4) Run:
```bash
flutter analyze
flutter test
flutter run
```

## Testing
- Suite: 76 unit/integration tests (see `test/`)
- Commands:
```bash
flutter test
flutter test test/models_test.dart
flutter test integration_test/
```

## Release Gatekeeper
Run before shipping:
```powershell
./publish_check.ps1
```
What it does: env/file checks, per-file tests + full suite, analyze, optional widget/coverage, security scan, release APKs (split per ABI) with SHA256 and `build_info.json`.

## CI/CD
- GitHub Actions: Flutter setup (subosito/flutter-action), `flutter pub get`, `flutter analyze`, `flutter test`
- Daily scheduled run at 03:00 UTC (manual dispatch available)

## Build & Ship
- Debug: `flutter build apk --debug`
- Release: `flutter build apk --release --split-per-abi`
- Scripted: `./publish_check.ps1` → upload APKs from `releases/PROD_BUILD_*`

## Security & Access
- Auth: Google Sign-In required
- Admin whitelist: admin1@example.com, admin2@example.com
- Firestore: user data isolated under `/users/{userId}/`; role-based writes

## Troubleshooting
- No tests run: `flutter test --verbose` and check `publish_check.ps1` output
- Firebase issues: confirm `google-services.json` path and `firebase_options.dart`
- CI issues: ensure workflow uses Flutter commands (not Dart)

## License
Proprietary. All rights reserved.
- **Accessibility**: Inclusive design for all users
- **Economic Impact**: Supports local businesses with technology

## Additional Information

### Security Features
- **Google OAuth**: Secure authentication for users and admins
- **Email Whitelisting**: Admin access restricted to authorized emails only
  - Hardcoded admin emails: `admin1@example.com`, `admin2@example.com`
  - Admin verification via Firebase Authentication token
  - Unauthorized accounts automatically signed out
- **Firestore Security Rules**: Comprehensive data access protection
  - User data isolation under `/users/{userId}/`
  - userId validation on all write operations
  - Read permissions based on ownership and admin status
  - Query-level security enforced
- **Real-time Encryption**: Secure data transmission via Firebase
- **Authentication Requirements**: All app features require sign-in
- **Password-less Authentication**: Google Sign-In for enhanced security
- **Role-Based Access Control**: Distinct permissions for users vs admins
- **Data Privacy**: Users cannot access other users' personal information

### Admin Configuration

**To Add New Admin Users:**
1. Open `firestore.rules` file
2. Locate the `isAdmin()` function
3. Add new admin email to the list:
   ```javascript
   function isAdmin() {
     return isSignedIn() && 
       (request.auth.token.email == 'admin1@example.com' || 
        request.auth.token.email == 'admin2@example.com' ||
        request.auth.token.email == 'newemail@example.com');
   }
   ```
4. Deploy updated rules: `firebase deploy --only firestore:rules`
5. Update `web/admin.html` whitelist (around line 865):
   ```javascript
   const ALLOWED_EMAILS = [
     'admin1@example.com', 
     'admin2@example.com',
     'newemail@example.com'
   ];
   ```
6. Deploy web: `firebase deploy --only hosting`

**Admin Panel Access:**
- URL: https://your-project.web.app
- Sign in with whitelisted Google account
- Non-admin accounts show "Access Denied" message
- Real-time data synchronization without page refresh

**Admin Panel Tabs:**
1. **Dashboard** - Overview statistics (revenue, orders, users, alerts)
2. **Products** - Complete product catalog management (CRUD operations)
3. **Orders** - View and manage all customer orders
4. **Users** - User database and account management
5. **Notify** - Send broadcast notifications to all users
6. **Feedbacks** - Review customer feedback and ratings
7. **Bug Reports** - Track and manage reported issues
8. **Analytics** - Business intelligence and performance metrics

### Performance Optimizations
- **Lazy Loading**: Products loaded in pages
- **Caching**: Local data storage for offline access
- **Image Optimization**: Efficient emoji-based product display
- **Background Processing**: Non-blocking operations

### Future Enhancements
- **AI Recommendations**: Personalized product suggestions
- **AR Features**: Augmented reality product visualization
- **IoT Integration**: Smart shelf integration
- **Multi-language Support**: International expansion
- **Loyalty Program**: Rewards and points system
- **And Many More

### Support and Contact
- **GitHub Repository**: https://github.com/shrs425p/SmartCart
- **Issues & Bug Reports**: https://github.com/shrs425p/SmartCart/issues
- **Discussions**: https://github.com/shrs425p/SmartCart/discussions
- **Email**: en24309314@git.india.edu.in
- **Institution**: Gharda Institute of Technology

*Note: For Firebase configuration and deployment setup, refer to the example files in the repository.*

### ⚠️ License

**© 2026 Shreyas Sanjay Pawar. All Rights Reserved.**

This software, **"SmartCart425,"** is the proprietary intellectual property of 
Shreyas Sanjay Pawar. Unauthorized copying, distribution, modification, or 
commercial use is strictly prohibited.

**This project is developed for educational purposes at Gharda Institute of Technology.**

**For licensing inquiries or permission requests, contact:**
- **Email**: your-email@example.com
- **Institution**: Gharda Institute of Technology
- **Student ID**: en24309314@git.india.edu.in

**Note**: This is a proprietary license, not an open-source license like MIT, Apache, or GPL.

---

## 🚀 Recent Additions & Improvements (2026)

### ✨ UI/UX Polish
- **Staggered Animations**: Smooth, sequential entrance animations for lists and grids across the app (Store, Cart, Order History, Analytics, etc.)
- **Global Page Transitions**: Native-feeling navigation transitions (Zoom for Android, Cupertino for iOS)
- **Skeleton Loading (Shimmer)**: Modern shimmer placeholders for product grids while loading
- **Haptic Feedback**: Subtle vibration feedback for key actions (requires Android permission)

### 🗣️ Smart Features
- **Voice Search**: Tap the microphone in the Store search bar to filter products by speaking (uses on-device speech recognition)

### 🛡️ Quality & Testing
- **Expanded Unit Tests**: New tests for data models and business logic (see `test/models_test.dart`)
- **Automated Publish Script**: `publish_check.ps1` now checks for critical test files, runs all tests, and organizes APKs with checksums for release

### 🛠️ Bug Fixes & Refactors
- **Order History**: Fixed text visibility for dark/light mode, removed hardcoded SHA keys from Diagnostics
- **Notifications**: New notifications screen with animated list
- **Profile**: Cleaned up unused code and improved maintainability

---
