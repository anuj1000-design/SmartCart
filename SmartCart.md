# SmartCart425 - Complete Technical Documentation

> **SmartCart** is a production-ready, enterprise-grade Flutter-powered self-checkout platform designed for modern grocery retailers. It combines a feature-rich mobile application with a sophisticated web administration dashboard, all backed by Firebase's robust cloud infrastructure.

---

## 📋 Table of Contents

1. [Executive Summary](#executive-summary)
2. [System Architecture](#system-architecture)
3. [Mobile Application - Deep Dive](#mobile-application-deep-dive)
4. [Web Admin Dashboard - Complete Guide](#web-admin-dashboard-complete-guide)
5. [Firebase Backend Infrastructure](#firebase-backend-infrastructure)
6. [State Management & Data Flow](#state-management-and-data-flow)
7. [Authentication & Authorization](#authentication-and-authorization)
8. [Database Schema & Collections](#database-schema-and-collections)
9. [API Integration & Services](#api-integration-and-services)
10. [UI/UX Design System](#ui-ux-design-system)
11. [Features & Functionality](#features-and-functionality)
12. [Testing Strategy](#testing-strategy)
13. [Build & Deployment](#build-and-deployment)
14. [Security & Compliance](#security-and-compliance)
15. [Performance Optimization](#performance-optimization)
16. [Troubleshooting Guide](#troubleshooting-guide)
17. [Development Workflow](#development-workflow)
18. [Code Structure & Organization](#code-structure-and-organization)
19. [Dependencies & Packages](#dependencies-and-packages)
20. [Future Roadmap](#future-roadmap)

---

## Executive Summary

### What's Inside

**Mobile Application (Flutter)**
- ✅ Real-time barcode scanning with mobile_scanner
- ✅ Intelligent stock-aware shopping cart
- ✅ Voice feedback via Text-to-Speech (TTS)
- ✅ Dark/Light theme with Material 3 design
- ✅ Multi-method checkout (UPI, Cash on Delivery)
- ✅ Haptic feedback for enhanced UX
- ✅ Offline capability with local caching
- ✅ Budget tracking and spending analytics
- ✅ Order history with reorder functionality
- ✅ Real-time push notifications
- ✅ Voice search capabilities
- ✅ Shake-to-report bug feature
- ✅ Product favorites and wishlists
- ✅ Advanced search and filtering
- ✅ Express checkout flow
- ✅ QR code exit verification
- ✅ Comprehensive profile management

**Admin Dashboard (Web)**
- ✅ Complete product catalog management (CRUD)
- ✅ Real-time order monitoring and processing
- ✅ User database and account management
- ✅ Broadcast notification system
- ✅ Customer feedback and ratings review
- ✅ Bug report tracking and management
- ✅ Business intelligence and analytics
- ✅ Inventory management with stock alerts
- ✅ Export capabilities (CSV, Print)
- ✅ Live dashboard with key metrics
- ✅ Search and filter functionality
- ✅ Modern glassmorphic UI design
- ✅ Responsive layout for all devices

**Firebase Backend**
- ✅ Firebase Authentication (Google Sign-In, Email/Password)
- ✅ Cloud Firestore (NoSQL database)
- ✅ Firebase Cloud Messaging (Push notifications)
- ✅ Firebase Analytics (User behavior tracking)
- ✅ Firebase Crashlytics (Error monitoring)
- ✅ Firebase Hosting (Web dashboard hosting)
- ✅ Firestore Security Rules (Role-based access control)

**Quality Assurance**
- ✅ 76 comprehensive unit and integration tests
- ✅ Flutter analyze for code quality
- ✅ publish_check.ps1 gatekeeper script
- ✅ GitHub Actions CI/CD pipeline
- ✅ Automated security scanning
- ✅ Coverage reporting

### Technology Stack

**Frontend**
- **Framework**: Flutter 3.38.6 (Dart 3.x)
- **Design System**: Material Design 3
- **State Management**: Provider pattern
- **Navigation**: Material/Cupertino page routes
- **Animations**: Staggered animations, shimmer effects
- **UI Components**: Custom widgets, glassmorphism

**Backend**
- **Authentication**: Firebase Auth with Google OAuth 2.0
- **Database**: Cloud Firestore (NoSQL)
- **Storage**: Firebase Cloud Storage
- **Functions**: Cloud Functions (optional)
- **Hosting**: Firebase Hosting for web dashboard

**Development Tools**
- **Version Control**: Git & GitHub
- **CI/CD**: GitHub Actions
- **Testing**: flutter_test, integration_test, mockito
- **Linting**: flutter_lints 6.0.0
- **Build Tools**: PowerShell scripts, Gradle

**Third-Party Services**
- **Barcode Scanning**: mobile_scanner 7.1.4
- **Push Notifications**: firebase_messaging 16.1.0
- **Analytics**: firebase_analytics 12.1.0
- **Crash Reporting**: firebase_crashlytics 5.0.6
- **Text-to-Speech**: flutter_tts 4.0.2
- **Speech Recognition**: speech_to_text 7.0.0
- **Charts**: fl_chart 1.1.1
- **QR Generation**: qr_flutter 4.1.0
- **PDF Generation**: pdf 3.11.1
- **File Operations**: path_provider 2.1.2, file_picker 10.3.8
- **Sharing**: share_plus 7.1.0
- **Device Info**: device_info_plus, package_info_plus
- **Sensors**: sensors_plus 7.0.0 (shake detection)
- **Vibration**: vibration 3.1.5
- **URL Launcher**: url_launcher 6.2.0
- **Local Storage**: shared_preferences 2.2.2
- **UUID Generation**: uuid 4.4.0

---

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                              │
├─────────────────────────────────┬───────────────────────────────┤
│   Flutter Mobile App            │   Web Admin Dashboard         │
│   (Android/iOS/Web)             │   (Modern Browsers)           │
│                                 │                               │
│   - UI Components               │   - Glassmorphic UI           │
│   - State Management (Provider) │   - Real-time Updates         │
│   - Local Caching               │   - Chart.js Analytics        │
│   - Offline Support             │   - Responsive Design         │
└─────────────────────────────────┴───────────────────────────────┘
                            │
                            ├─────────────────────────────┐
                            │                             │
                            ▼                             ▼
┌────────────────────────────────────┐   ┌────────────────────────┐
│    FIREBASE SERVICES LAYER         │   │   GOOGLE SERVICES      │
├────────────────────────────────────┤   ├────────────────────────┤
│ ✓ Firebase Authentication         │   │ ✓ Google Sign-In       │
│ ✓ Cloud Firestore Database        │   │ ✓ Google Play Services │
│ ✓ Firebase Cloud Messaging        │   │ ✓ OAuth 2.0            │
│ ✓ Firebase Analytics              │   └────────────────────────┘
│ ✓ Firebase Crashlytics            │
│ ✓ Firebase Hosting                │
│ ✓ Cloud Storage                   │
└────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                        DATA LAYER                                │
├─────────────────────────────────────────────────────────────────┤
│   Firestore Collections:                                         │
│   • /products       - Product catalog                            │
│   • /orders         - Order transactions                         │
│   • /receipts       - Receipt records                            │
│   • /users/{uid}    - User profiles & preferences                │
│   • /feedbacks      - Customer feedback                          │
│   • /bug_reports    - Bug reports                                │
│   • /analytics      - Analytics events                           │
│   • /budgets        - User budget settings                       │
└─────────────────────────────────────────────────────────────────┘
```

### Application Layer Architecture

**Mobile App Structure**
```
lib/
├── main.dart                 # App entry point, Firebase initialization
├── firebase_options.dart     # Firebase configuration
│
├── models/
│   └── models.dart          # Data models (Product, User, Order, etc.)
│
├── providers/
│   └── app_state_provider.dart  # Central state management
│
├── screens/                 # UI screens (29 screens)
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── home_screen.dart
│   ├── store_screen.dart
│   ├── cart_screen.dart
│   ├── profile_screen.dart
│   ├── order_history_screen.dart
│   ├── payment_methods_screen.dart
│   ├── analytics_dashboard_screen.dart
│   ├── barcode_scanner_screen.dart
│   ├── notifications_screen.dart
│   ├── settings_screen.dart
│   ├── feedback_screen.dart
│   ├── report_bug_screen.dart
│   ├── diagnostics_screen.dart
│   └── ... (14+ more screens)
│
├── services/                # Business logic & API services
│   ├── auth_service.dart
│   ├── payment_service.dart
│   ├── notification_service.dart
│   ├── analytics_service.dart
│   ├── inventory_service.dart
│   ├── budget_service.dart
│   ├── favorites_service.dart
│   ├── feedback_service.dart
│   ├── pdf_service.dart
│   ├── price_alert_service.dart
│   └── unique_id_service.dart
│
├── widgets/                 # Reusable UI components
│   ├── auth_guard.dart
│   ├── suspension_guard.dart
│   ├── product_tile.dart
│   ├── product_detail_sheet.dart
│   ├── emoji_display.dart
│   ├── shimmer_loading.dart
│   ├── staggered_animation.dart
│   ├── stock_status_widget.dart
│   ├── stock_notification_widget.dart
│   └── ui_components.dart
│
├── theme/
│   └── app_theme.dart       # Material 3 theme definitions
│
└── utils/                   # Helper utilities
    ├── feedback_helper.dart
    ├── firestore_error_handler.dart
    ├── performance_monitor.dart
    └── shake_detector.dart
```

### Data Flow Architecture

**User Action → State Update Flow**
```
1. User interacts with UI
   └─> Widget calls Provider method
       └─> Provider updates internal state
           └─> Provider calls Firebase service
               └─> Firebase updates cloud data
                   └─> Stream/Snapshot emits new data
                       └─> Provider notifies listeners
                           └─> Widget rebuilds with new data
```

**Authentication Flow**
```
User taps "Sign in with Google"
    └─> AuthService.signInWithGoogle()
        └─> GoogleSignIn.signIn()
            └─> User selects Google account
                └─> Firebase.signInWithCredential()
                    └─> AuthService creates/updates Firestore user profile
                        └─> StreamBuilder detects auth state change
                            └─> App navigates to HomeScreen
```

**Shopping Cart Flow**
```
User scans barcode
    └─> BarcodeScannerScreen detects code
        └─> AppStateProvider.searchProductByBarcode()
            └─> Product found in _products list
                └─> User taps "Add to Cart"
                    └─> AppStateProvider.addToCart(product)
                        └─> Validates stock availability
                            └─> Updates _cart list
                                └─> Plays TTS feedback
                                    └─> Triggers haptic vibration
                                        └─> notifyListeners()
                                            └─> Cart icon updates badge count
```

---

## Mobile Application - Deep Dive

### Core Features Breakdown

#### 1. **Authentication System**

**Location**: `lib/screens/login_screen.dart`, `lib/services/auth_service.dart`

**Capabilities**:
- Google Sign-In with OAuth 2.0
- Email/Password authentication
- User profile creation in Firestore
- Password reset via email
- Session persistence
- Automatic role detection (customer/admin)
- Account suspension checking

**Authentication Flow Details**:
```dart
// Google Sign-In Process
1. User taps "Sign in with Google" button
2. AuthService.signInWithGoogle() invoked
3. Attempts native GoogleSignIn first (Play Services)
4. Falls back to provider-based flow if native fails
5. Gets GoogleSignInAuthentication tokens
6. Creates Firebase credential
7. Signs in to Firebase with credential
8. Creates/updates user profile in /users/{uid}
9. Sets default values: role, avatarEmoji, timestamps
10. Returns UserCredential
11. StreamBuilder detects auth state change
12. Navigates to RoleBasedHome widget
```

**User Profile Structure** (Firestore `/users/{uid}`):
```javascript
{
  uid: "firebase_user_id",
  email: "user@example.com",
  name: "John Doe",
  displayName: "John Doe",
  phone: "+1234567890",
  photoURL: "https://google-profile-url",
  avatarEmoji: "👤",
  role: "customer",  // or "admin"
  isSuspended: false,
  createdAt: Timestamp,
  updatedAt: Timestamp,
  lastLoginTime: Timestamp,
  membershipTier: "User"
}
```

**Security Features**:
- SHA-1 and SHA-256 fingerprints required in Firebase Console
- Admin whitelist enforcement (`admin1@example.com`, `admin2@example.com`)
- Automatic signout for unauthorized admin access
- Session timeout handling
- Secure token storage

---

#### 2. **Barcode Scanner**

**Location**: `lib/screens/barcode_scanner_screen.dart`

**Technology**: mobile_scanner ^7.1.4

**Features**:
- Real-time barcode detection
- Support for multiple formats (EAN-13, UPI QR, etc.)
- Torch/flashlight toggle
- Camera permission handling
- Continuous scanning or single-scan modes
- Visual feedback on successful scan
- Audio/haptic feedback
- Automatic product lookup

**Scanner Implementation**:
```dart
MobileScanner(
  controller: controller,
  onDetect: (BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        // Search product by barcode
        final product = appState.searchProductByBarcode(barcode.rawValue!);
        if (product != null) {
          // Show product details
          // Add to cart
          // Play TTS feedback
        }
      }
    }
  },
)
```

**Barcode Types Supported**:
- EAN-8, EAN-13 (Product barcodes)
- UPC-A, UPC-E
- Code-39, Code-93, Code-128
- QR Code (for exit verification)
- ITF (Interleaved 2 of 5)
- Codabar
- Data Matrix

---

#### 3. **Shopping Cart System**

**Location**: `lib/screens/cart_screen.dart`, `lib/providers/app_state_provider.dart`

**Cart Features**:
- Add/remove products
- Quantity adjustment with stock validation
- Real-time price calculation
- Stock availability checks
- Item removal with confirmation
- Clear cart functionality
- Persistent cart (survives app restarts)
- Out-of-stock warnings
- Low-stock alerts

**Cart Data Structure**:
```dart
class CartItem {
  final Product product;
  int quantity;
  
  CartItem({required this.product, this.quantity = 1});
  
  int get total => product.price * quantity;
}

// In AppStateProvider
List<CartItem> _cart = [];
int get cartItemCount => _cart.fold(0, (sum, item) => sum + item.quantity);
int get cartTotal => _cart.fold(0, (sum, item) => sum + item.total);
```

**Stock Validation Logic**:
```dart
void addToCart(Product product) {
  // Check if product is already in cart
  final existingIndex = _cart.indexWhere((item) => item.product.id == product.id);
  
  if (existingIndex >= 0) {
    // Increment quantity if stock allows
    final currentQty = _cart[existingIndex].quantity;
    if (currentQty < product.stockQuantity) {
      _cart[existingIndex].quantity++;
      FeedbackHelper.success('Added to cart');
    } else {
      FeedbackHelper.warning('Out of stock');
    }
  } else {
    // Add new item
    if (product.stockQuantity > 0) {
      _cart.add(CartItem(product: product, quantity: 1));
      FeedbackHelper.success('Added to cart');
    } else {
      FeedbackHelper.error('Out of stock');
    }
  }
  
  notifyListeners();
  AnalyticsService().logAddToCart(product);
}
```

---

#### 4. **Payment Processing**

**Location**: `lib/screens/payment_selection_screen.dart`, `lib/services/payment_service.dart`

**Payment Methods**:
1. **UPI (Unified Payments Interface)**
   - Google Pay
   - PhonePe
   - Paytm
   - Amazon Pay
   - Any UPI app

2. **Cash on Delivery**
   - Pay at counter
   - Generate exit QR code
   - Counter verification

**UPI Payment Flow**:
```dart
// 1. Generate UPI deep link
String upiLink = PaymentService.generateUpiLink(
  upiId: 'merchant@upi',
  payeeName: 'SmartCart425',
  amount: cartTotal / 100.0, // Convert paise to rupees
  transactionRef: orderId,
  description: 'SmartCart Order #$orderId',
);

// 2. Launch payment app
await PaymentService.launchPaymentApp(
  app: selectedPaymentApp,
  upiLink: upiLink,
);

// 3. Create order in Firestore
String orderId = await appState.createOrder(
  cartItems: appState.cart,
  total: appState.cartTotal,
  paymentMethod: 'UPI',
  paymentStatus: 'Pending Payment',
);

// 4. Navigate to success screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => PaymentSuccessScreen(orderId: orderId)),
);
```

**UPI Deep Link Format**:
```
upi://pay?pa=merchant@upi&pn=SmartCart425&am=150.00&cu=INR&tr=ORDER123&tn=SmartCart+Order
```

**Parameters**:
| Parameter | Description | Required |
|-----------|-------------|----------|
| `pa` | Payee Address (UPI ID) | Yes |
| `pn` | Payee Name | Yes |
| `am` | Amount in rupees | Yes |
| `cu` | Currency (INR) | Yes |
| `tr` | Transaction Reference | Yes |
| `tn` | Transaction Note | No |

**Cash on Delivery Flow**:
```
1. User selects "Pay at Counter"
2. Order is created with status "Pending Payment"
3. Generate unique exit code (6-digit)
4. Create QR code containing exit code + order ID
5. Show QR code on screen
6. User shows QR at counter
7. Counter staff scans QR
8. Counter staff verifies items and collects cash
9. Counter marks order as "Paid"
10. User exits with purchased items
```

---

#### 5. **Product Management & Store**

**Location**: `lib/screens/store_screen.dart`

**Features**:
- Grid/List view toggle
- Category filtering (All, Groceries, Dairy, Snacks, Beverages, etc.)
- Voice search with speech recognition
- Text search with real-time filtering
- Product details bottom sheet
- Add to favorites
- Stock status indicators
- Price display in rupees
- Emoji-based product images
- Shimmer loading placeholders
- Infinite scroll pagination (20 products per page)
- Pull-to-refresh
- Staggered grid animations

**Product Model** (`lib/models/models.dart`):
```dart
class Product {
  final String id;
  final String name;
  final String category;
  final String brand;
  final String description;
  final int price;              // Stored in paise (1 rupee = 100 paise)
  final Color color;
  final String imageEmoji;
  final String? barcode;
  final List<DietaryBadge> dietaryBadges;
  final int stockQuantity;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.description,
    required this.price,
    required this.color,
    required this.imageEmoji,
    this.isFavorite = false,
    this.barcode,
    this.dietaryBadges = const [],
    this.stockQuantity = 0,
  });
  
  // Convert price from paise to rupees for display
  double get priceInRupees => price / 100.0;
  
  // Stock status
  bool get inStock => stockQuantity > 0;
  bool get lowStock => stockQuantity > 0 && stockQuantity <= 10;
  bool get outOfStock => stockQuantity <= 0;
}
```

**Firestore Product Document Structure**:
```javascript
/products/{productId}
{
  id: "prod_123",
  name: "Amul Fresh Milk",
  category: "dairy",
  brand: "Amul",
  description: "Fresh full cream milk 1L",
  price: 6500,  // 65.00 rupees in paise
  imageEmoji: "🥛",
  barcode: "8901234567890",
  stockQuantity: 150,
  dietaryBadges: ["organic"],
  createdAt: Timestamp,
  updatedAt: Timestamp,
  purchaseCount: 1250,  // Times purchased (for analytics)
}
```

**Product Search Implementation**:
```dart
// Text Search
List<Product> searchProducts(String query) {
  if (query.isEmpty) return _products;
  
  final lowerQuery = query.toLowerCase();
  return _products.where((product) {
    return product.name.toLowerCase().contains(lowerQuery) ||
           product.category.toLowerCase().contains(lowerQuery) ||
           product.brand.toLowerCase().contains(lowerQuery) ||
           product.description.toLowerCase().contains(lowerQuery);
  }).toList();
}

// Barcode Search
Product? searchProductByBarcode(String barcode) {
  try {
    return _products.firstWhere((p) => p.barcode == barcode);
  } catch (e) {
    return null;
  }
}

// Voice Search
Future<void> startVoiceSearch() async {
  bool available = await _speechToText.initialize();
  if (available) {
    _speechToText.listen(
      onResult: (result) {
        String query = result.recognizedWords;
        setSearchQuery(query);
        // Filter products based on voice input
      },
    );
  }
}
```

**Pagination Implementation**:
```dart
// Load initial batch (20 products)
Future<void> loadProductsFromFirestore() async {
  final query = FirebaseFirestore.instance
      .collection('products')
      .orderBy('name')
      .limit(20);
  
  final snapshot = await query.get();
  _products = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
  _lastProductDoc = snapshot.docs.last;
  _hasMoreProducts = snapshot.docs.length == 20;
  notifyListeners();
}

// Load next batch
Future<void> loadMoreProducts() async {
  if (!_hasMoreProducts || _isLoadingMoreProducts) return;
  
  _isLoadingMoreProducts = true;
  
  final query = FirebaseFirestore.instance
      .collection('products')
      .orderBy('name')
      .startAfterDocument(_lastProductDoc!)
      .limit(20);
  
  final snapshot = await query.get();
  final newProducts = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
  
  _products.addAll(newProducts);
  _lastProductDoc = snapshot.docs.last;
  _hasMoreProducts = snapshot.docs.length == 20;
  _isLoadingMoreProducts = false;
  
  notifyListeners();
}
```

---

#### 6. **Order Management**

**Location**: `lib/screens/order_history_screen.dart`

**Features**:
- View all past orders
- Order details with itemized list
- Receipt generation and download (PDF)
- Share receipt via multiple channels
- Reorder functionality with stock validation
- Filter by date/status
- Track payment status
- Exit code display for COD orders
- Expandable order cards

**Order Model**:
```dart
class Order {
  final String id;
  final DateTime date;
  final List<CartItem> items;
  final int total;              // In paise
  final String status;
  final String paymentMethod;   // 'UPI' or 'COD'
  final String paymentStatus;   // 'Paid', 'Pending Payment', 'Failed'
  final String? exitCode;       // For COD orders
  final String userId;
  
  Order({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.status,
    this.paymentMethod = 'UPI',
    this.paymentStatus = 'Pending Payment',
    this.exitCode,
    required this.userId,
  });
  
  double get totalInRupees => total / 100.0;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}
```

**Firestore Order Structure**:
```javascript
/orders/{orderId}
{
  id: "ORDER_20260208_123456",
  userId: "firebase_user_uid",
  items: [
    {
      productId: "prod_123",
      productName: "Amul Fresh Milk",
      productEmoji: "🥛",
      quantity: 2,
      price: 6500,  // Price per unit in paise
      total: 13000  // quantity * price
    }
  ],
  subtotal: 13000,  // Sum of all items
  tax: 0,
  discount: 0,
  total: 13000,
  paymentMethod: "UPI",
  paymentStatus: "Paid",
  status: "completed",
  exitCode: null,  // Only for COD
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

**Reorder Functionality**:
```dart
Future<void> reorderFromHistory(Order order) async {
  int addedCount = 0;
  int skippedCount = 0;
  
  for (final item in order.items) {
    // Find product by ID
    final product = _products.firstWhere(
      (p) => p.id == item.product.id,
      orElse: () => null,
    );
    
    if (product != null) {
      // Check current stock
      if (product.stockQuantity > 0) {
        // Check if already in cart
        final existingIndex = _cart.indexWhere((ci) => ci.product.id == product.id);
        
        if (existingIndex >= 0) {
          // Calculate how many more we can add
          final currentCartQty = _cart[existingIndex].quantity;
          final maxCanAdd = product.stockQuantity - currentCartQty;
          final toAdd = min(item.quantity, maxCanAdd);
          
          if (toAdd > 0) {
            _cart[existingIndex].quantity += toAdd;
            addedCount += toAdd;
          }
        } else {
          // Add new item to cart
          final qtyToAdd = min(item.quantity, product.stockQuantity);
          _cart.add(CartItem(product: product, quantity: qtyToAdd));
          addedCount += qtyToAdd;
        }
      } else {
        skippedCount += item.quantity;
      }
    } else {
      skippedCount += item.quantity;
    }
  }
  
  notifyListeners();
  
  // Show feedback
  if (addedCount > 0 && skippedCount == 0) {
    FeedbackHelper.success('All items added to cart');
  } else if (addedCount > 0 && skippedCount > 0) {
    FeedbackHelper.warning('$addedCount items added, $skippedCount unavailable');
  } else {
    FeedbackHelper.error('No items available to reorder');
  }
}
```

**Receipt Generation** (`lib/services/pdf_service.dart`):
```dart
Future<File> generateReceipt(Order order) async {
  final pdf = pw.Document();
  
  pdf.addPage(
    pw.Page(
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Text('SmartCart425', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.Text('Receipt', style: pw.TextStyle(fontSize: 18)),
            pw.Divider(),
            
            // Order Info
            pw.Text('Order ID: ${order.id}'),
            pw.Text('Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(order.date)}'),
            pw.Text('Payment: ${order.paymentMethod}'),
            pw.SizedBox(height: 20),
            
            // Items Table
            pw.Table.fromTextArray(
              headers: ['Item', 'Qty', 'Price', 'Total'],
              data: order.items.map((item) => [
                item.product.name,
                item.quantity.toString(),
                '₹${(item.product.price / 100).toStringAsFixed(2)}',
                '₹${(item.total / 100).toStringAsFixed(2)}',
              ]).toList(),
            ),
            
            pw.Divider(),
            
            // Total
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text('Total: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('₹${(order.total / 100).toStringAsFixed(2)}', 
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            
            pw.SizedBox(height: 20),
            pw.Text('Thank you for shopping with SmartCart!', style: TextStyle(fontSize: 12)),
          ],
        );
      },
    ),
  );
  
  // Save to file
  final output = await getTemporaryDirectory();
  final file = File('${output.path}/receipt_${order.id}.pdf');
  await file.writeAsBytes(await pdf.save());
  
  return file;
}
```

---

#### 7. **Analytics Dashboard**

**Location**: `lib/screens/analytics_dashboard_screen.dart`, `lib/screens/spending_analytics_screen.dart`

**Analytics Features**:
- Total spending tracking
- Monthly/yearly trends
- Category-wise breakdown
- Most purchased products
- Order frequency analysis
- Budget comparison
- Visual charts (Bar, Line, Pie)
- Export analytics data
- Spending insights and recommendations

**Analytics Data Structure**:
```dart
// Tracked Events
- App Open
- Product View
- Add to Cart
- Remove from Cart
- Search (query)
- Barcode Scan
- Order Placed
- Payment Completed
- Category Selected
- Voice Search Used
```

**Analytics Service** (`lib/services/analytics_service.dart`):
```dart
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  // Log custom events
  Future<void> logEvent(String name, Map<String, dynamic>? parameters) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }
  
  // Product view
  Future<void> logProductView(Product product) async {
    await _analytics.logViewItem(
      currency: 'INR',
      value: product.price / 100.0,
      items: [
        AnalyticsEventItem(
          itemId: product.id,
          itemName: product.name,
          itemCategory: product.category,
          price: product.price / 100.0,
        ),
      ],
    );
  }
  
  // Add to cart
  Future<void> logAddToCart(Product product, int quantity) async {
    await _analytics.logAddToCart(
      currency: 'INR',
      value: (product.price * quantity) / 100.0,
      items: [
        AnalyticsEventItem(
          itemId: product.id,
          itemName: product.name,
          itemCategory: product.category,
          price: product.price / 100.0,
          quantity: quantity,
        ),
      ],
    );
  }
  
  // Purchase
  Future<void> logPurchase(Order order) async {
    await _analytics.logPurchase(
      currency: 'INR',
      value: order.total / 100.0,
      transactionId: order.id,
      items: order.items.map((item) => AnalyticsEventItem(
        itemId: item.product.id,
        itemName: item.product.name,
        itemCategory: item.product.category,
        price: item.product.price / 100.0,
        quantity: item.quantity,
      )).toList(),
    );
  }
  
  // Search
  Future<void> logSearch(String query) async {
    await _analytics.logSearch(searchTerm: query);
  }
  
  // Set user properties
  Future<void> setUserRole(String role) async {
    await _analytics.setUserProperty(name: 'user_role', value: role);
  }
}
```

**Spending Analytics UI**:
```dart
// Monthly Spending Chart
BarChart(
  BarChartData(
    barGroups: monthlyData.map((data) => 
      BarChartGroupData(
        x: data.month,
        barRods: [
          BarChartRodData(
            toY: data.spending,
            color: AppTheme.primary,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    ).toList(),
  ),
)

// Category Breakdown Pie Chart
PieChart(
  PieChartData(
    sections: categoryData.map((data) =>
      PieChartSectionData(
        value: data.percentage,
        title: '${data.percentage.toStringAsFixed(1)}%',
        color: data.color,
        radius: 100,
      ),
    ).toList(),
  ),
)
```

---

#### 8. **Budget Management**

**Location**: `lib/screens/budget_settings_screen.dart`, `lib/services/budget_service.dart`

**Features**:
- Set monthly/weekly budgets
- Real-time spending tracking
- Budget alerts and warnings
- Category-wise budget limits
- Automatic reset on cycle completion
- Visual progress indicators
- Spending recommendations

**Budget Model**:
```dart
class Budget {
  final String id;
  final String userId;
  final int amount;           // In paise
  final String period;        // 'weekly' or 'monthly'
  final DateTime startDate;
  final DateTime endDate;
  int currentSpent;           // In paise
  
  Budget({
    required this.id,
    required this.userId,
    required this.amount,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.currentSpent = 0,
  });
  
  double get progress => (currentSpent / amount).clamp(0.0, 1.0);
  int get remaining => max(0, amount - currentSpent);
  bool get isExceeded => currentSpent > amount;
  bool get isNearLimit => progress >= 0.8;
}
```

**Budget Tracking**:
```dart
Future<void> checkBudgetBeforeCheckout() async {
  final budget = await BudgetService().getCurrentBudget();
  
  if (budget != null) {
    final projectedSpent = budget.currentSpent + cartTotal;
    
    if (projectedSpent > budget.amount) {
      // Show warning dialog
      bool proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Budget Exceeded'),
          content: Text(
            'This purchase will exceed your ${budget.period} budget by '
            '₹${((projectedSpent - budget.amount) / 100).toStringAsFixed(2)}. '
            'Do you want to proceed?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Proceed Anyway'),
            ),
          ],
        ),
      ) ?? false;
      
      if (!proceed) return;
    }
  }
  
  // Continue with checkout
  proceedToPayment();
}
```

---

#### 9. **Notifications System**

**Location**: `lib/screens/notifications_screen.dart`, `lib/services/notification_service.dart`

**Notification Types**:
1. **Order Updates** - Order placed, payment confirmed, ready for pickup
2. **Stock Alerts** - Items back in stock, low stock warnings
3. **Price Alerts** - Price drops on favorites
4. **Promotional** - Sales, offers, new products
5. **System** - App updates, maintenance notices
6. **Budget** - Budget limit warnings
7. **Admin** - Broadcast messages from admin panel

**Notification Model**:
```dart
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final bool read;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  
  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.read = false,
    required this.timestamp,
    this.data,
  });
}
```

**Firebase Cloud Messaging Setup**:
```dart
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get FCM token
      String? token = await _messaging.getToken();
      await _saveTokenToFirestore(token);
      
      // Listen to token refresh
      _messaging.onTokenRefresh.listen(_saveTokenToFirestore);
      
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showLocalNotification(message);
      });
      
      // Handle notification taps
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationTap(message);
      });
    }
  }
  
  Future<void> _saveTokenToFirestore(String? token) async {
    if (token != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'fcm_token': token});
      }
    }
  }
  
  void _showLocalNotification(RemoteMessage message) {
    FlutterLocalNotificationsPlugin().show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'smartcart_channel',
          'SmartCart Notifications',
          channelDescription: 'Notifications from SmartCart',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
```

**Send Notification from Admin** (Web Dashboard):
```javascript
// Admin dashboard sends to all users
async function sendNotificationToAll(title, message) {
  const usersSnapshot = await db.collection('users').get();
  const tokens = [];
  
  usersSnapshot.forEach(doc => {
    const fcmToken = doc.data().fcm_token;
    if (fcmToken) tokens.push(fcmToken);
  });
  
  // Send via Cloud Function or Admin SDK
  const payload = {
    notification: {
      title: title,
      body: message,
    },
    tokens: tokens,
  };
  
  // Call Cloud Function
  await fetch('https://your-cloud-function-url/sendBulkNotification', {
    method: 'POST',
    body: JSON.stringify(payload),
  });
}
```

---

#### 10. **Profile Management**

**Location**: `lib/screens/profile_screen.dart`, `lib/screens/edit_profile_screen.dart`

**Profile Features**:
- View/edit name, phone, email
- Avatar emoji selection
- Google profile picture display
- Membership tier badge
- Account statistics (total orders, total spent)
- Favorites list
- Payment methods management
- Saved addresses
- App settings access
- Sign out functionality

**Profile Screen Sections**:
1. **Header** - Avatar, name, email, membership tier
2. **Quick Stats** - Orders count, total spent, favorites
3. **Account** - Edit profile, addresses, payment methods
4. **Preferences** - Settings, notifications, theme
5. **Support** - Help, feedback, report bug
6. **Legal** - Privacy policy, terms of service
7. **Actions** - Sign out, delete account

**Edit Profile**:
```dart
Future<void> updateProfile({
  required String name,
  required String phone,
  required String avatarEmoji,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
      'name': name,
      'displayName': name,
      'phone': phone,
      'avatarEmoji': avatarEmoji,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    // Update local state
    _profile.name = name;
    _profile.phone = phone;
    _profile.avatarEmoji = avatarEmoji;
    
    notifyListeners();
    FeedbackHelper.success('Profile updated successfully');
  } catch (e) {
    FeedbackHelper.error('Failed to update profile');
  }
}
```

---

#### 11. **Favorites System**

**Location**: `lib/services/favorites_service.dart`

**Features**:
- Add/remove products from favorites
- View all favorite products
- Price drop notifications for favorites
- Quick add to cart from favorites
- Sync across devices

**Implementation**:
```dart
class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Add to favorites
  Future<void> addFavorite(String userId, String productId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(productId)
        .set({
      'productId': productId,
      'addedAt': FieldValue.serverTimestamp(),
    });
    
    // Update product
    await _firestore
        .collection('products')
        .doc(productId)
        .update({
      'isFavorite': true,
    });
  }
  
  // Remove from favorites
  Future<void> removeFavorite(String userId, String productId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(productId)
        .delete();
    
    await _firestore
        .collection('products')
        .doc(productId)
        .update({
      'isFavorite': false,
    });
  }
  
  // Get all favorites
  Stream<List<Product>> getFavorites(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Product> favorites = [];
      
      for (var doc in snapshot.docs) {
        final productId = doc['productId'];
        final productDoc = await _firestore
            .collection('products')
            .doc(productId)
            .get();
        
        if (productDoc.exists) {
          favorites.add(Product.fromFirestore(productDoc));
        }
      }
      
      return favorites;
    });
  }
}
```

---

#### 12. **Feedback & Bug Reporting**

**Location**: `lib/screens/feedback_screen.dart`, `lib/screens/report_bug_screen.dart`

**Feedback System**:
- 5-star rating
- Written feedback
- Category selection (UI/UX, Performance, Features, etc.)
- Anonymous or named feedback
- Screenshot attachment
- Automatic device info collection

**Bug Report System**:
- Shake-to-report gesture detection
- Bug description input
- Steps to reproduce
- Expected vs actual behavior
- Screenshot capture
- Automatic diagnostics data
- Device and app version info

**Shake Detection** (`lib/utils/shake_detector.dart`):
```dart
class ShakeDetector extends StatefulWidget {
  final VoidCallback onShake;
  final Widget child;
  
  @override
  _ShakeDetectorState createState() => _ShakeDetectorState();
}

class _ShakeDetectorState extends State<ShakeDetector> {
  StreamSubscription? _subscription;
  DateTime? _lastShakeTime;
  static const _shakeThreshold = 2.7;
  static const _shakeDebounceDuration = Duration(milliseconds: 500);
  
  @override
  void initState() {
    super.initState();
    _subscription = accelerometerEvents.listen((AccelerometerEvent event) {
      final acceleration = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z
      );
      
      if (acceleration > _shakeThreshold) {
        final now = DateTime.now();
        if (_lastShakeTime == null || 
            now.difference(_lastShakeTime!) > _shakeDebounceDuration) {
          _lastShakeTime = now;
          widget.onShake();
        }
      }
    });
  }
  
  @override
  Widget build(BuildContext context) => widget.child;
  
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
```

**Bug Report Submission**:
```dart
Future<void> submitBugReport({
  required String description,
  required String stepsToReproduce,
  String? expectedBehavior,
  String? actualBehavior,
  File? screenshot,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  
  // Collect diagnostics
  final packageInfo = await PackageInfo.fromPlatform();
  final deviceInfo = await DeviceInfoPlugin().androidInfo;
  
  // Create bug report document
  final reportId = Uuid().v4();
  await FirebaseFirestore.instance
      .collection('bug_reports')
      .doc(reportId)
      .set({
    'id': reportId,
    'userId': user.uid,
    'userEmail': user.email,
    'description': description,
    'stepsToReproduce': stepsToReproduce,
    'expectedBehavior': expectedBehavior,
    'actualBehavior': actualBehavior,
    'appVersion': packageInfo.version,
    'buildNumber': packageInfo.buildNumber,
    'platform': 'Android',
    'osVersion': deviceInfo.version.release,
    'deviceModel': deviceInfo.model,
    'createdAt': FieldValue.serverTimestamp(),
    'status': 'open',
  });
  
  // Upload screenshot if provided
  if (screenshot != null) {
    final ref = FirebaseStorage.instance
        .ref()
        .child('bug_reports')
        .child(reportId)
        .child('screenshot.png');
    await ref.putFile(screenshot);
  }
  
  FeedbackHelper.success('Bug report submitted. Thank you!');
}
```

---

#### 13. **Settings & Preferences**

**Location**: `lib/screens/settings_screen.dart`

**Settings Categories**:
1. **Appearance**
   - Dark/Light theme toggle
   - Accent color selection
   - Font size adjustment

2. **Notifications**
   - Enable/disable push notifications
   - Notification categories toggles
   - Quiet hours

3. **Privacy**
   - Analytics opt-in/out
   - Crashlytics opt-in/out
   - Clear cache
   - Clear history

4. **Shopping**
   - Default payment method
   - Auto-apply offers
   - Low stock alerts
   - Price drop alerts

5. **Accessibility**
   - Voice feedback toggle
   - Haptic feedback toggle
   - Screen reader support

6. **About**
   - App version
   - Build number
   - Licenses
   - Open source attributions

**Theme Toggle Implementation**:
```dart
// In AppStateProvider
Future<void> toggleTheme(bool isDark) async {
  _isDarkMode = isDark;
  notifyListeners();
  
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isDarkMode', isDark);
  
  // Update system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ),
  );
}
```

---

#### 14. **Diagnostics Screen**

**Location**: `lib/screens/diagnostics_screen.dart`

**Purpose**: Developer/Admin tool to inspect app health and Firebase connection status

**Information Displayed**:
- Firebase initialization status
- Auth connection status
- Firestore connection status
- Current user details
- Project ID
- App name
- Storage bucket
- Messaging sender ID
- Analytics tracking status
- Crashlytics status
- Network connectivity
- Database cache size
- Last sync timestamp

**Implementation**:
```dart
class DiagnosticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseApp = Firebase.app();
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    
    return Scaffold(
      appBar: AppBar(title: Text('System Diagnostics')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSection('Firebase', [
            _buildRow('Status', firebaseApp != null ? '✅ Connected' : '❌ Not initialized'),
            _buildRow('Project ID', firebaseApp.options.projectId),
            _buildRow('App ID', firebaseApp.options.appId),
            _buildRow('API Key', firebaseApp.options.apiKey.substring(0, 10) + '...'),
          ]),
          
          _buildSection('Authentication', [
            _buildRow('Status', user != null ? '✅ Signed In' : '❌ Not signed in'),
            if (user != null) ...[
              _buildRow('UID', user.uid),
              _buildRow('Email', user.email ?? 'N/A'),
              _buildRow('Display Name', user.displayName ?? 'N/A'),
              _buildRow('Email Verified', user.emailVerified ? 'Yes' : 'No'),
            ],
          ]),
          
          _buildSection('Firestore', [
            _buildRow('Status', '✅ Connected'),
            _buildRow('Host', 'firestore.googleapis.com'),
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('products').limit(1).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return _buildRow('Test Query', snapshot.hasData ? '✅ Success' : '❌ Failed');
                }
                return _buildRow('Test Query', '⏳ Testing...');
              },
            ),
          ]),
          
          _buildSection('Analytics', [
            _buildRow('Status', '✅ Enabled'),
            _buildRow('Instance ID', FirebaseAnalytics.instance.hashCode.toString()),
          ]),
        ],
      ),
    );
  }
  
  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
  
  Widget _buildRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
```

---

## Web Admin Dashboard - Complete Guide

### Dashboard Overview

**Technology**: Vanilla HTML, CSS (Tailwind), JavaScript (ES6+)
**Firebase SDK**: v8 (modular approach)
**UI Framework**: Tailwind CSS with custom glassmorphism design
**Charts**: Chart.js 3.9.1

**File**: `web/admin.html` (2305 lines)

### Authentication & Access Control

**Admin Whitelist**:
```javascript
const ALLOWED_EMAILS = [
  'admin1@example.com',
  'admin2@example.com'
];

function checkAdminAccess(user) {
  if (!ALLOWED_EMAILS.includes(user.email)) {
    alert('Access Denied. This dashboard is restricted to authorized admins only.');
    firebase.auth().signOut();
    return false;
  }
  return true;
}
```

**Sign In with Google**:
```javascript
async function signIn() {
  const provider = new firebase.auth.GoogleAuthProvider();
  try {
    const result = await firebase.auth().signInWithPopup(provider);
    const user = result.user;
    
    if (checkAdminAccess(user)) {
      document.getElementById('login-screen').classList.add('hidden');
      document.getElementById('app-container').classList.remove('hidden');
      initializeDashboard();
    }
  } catch (error) {
    console.error('Sign-in error:', error);
    alert('Sign-in failed: ' + error.message);
  }
}
```

### Dashboard Tab Structure

1. **Dashboard** - Overview with key metrics
2. **Notify** - Send broadcast notifications
3. **Products** - Product catalog management
4. **Orders** - Order history and management
5. **Users** - User database
6. **Analytics** - Business intelligence
7. **Feedbacks** - Customer feedback
8. **Bug Reports** - Bug tracking

---

### Dashboard Tab (Home)

**Key Metrics Displayed**:
- Total Inventory Count
- Low Stock Alerts
- Total Orders
- Total Revenue

**Implementation**:
```javascript
async function loadDashboardStats() {
  // Total Products
  const productsSnapshot = await db.collection('products').get();
  document.getElementById('stat-total-products').textContent = productsSnapshot.size;
  
  // Low Stock Products (stock <= 10)
  const lowStockProducts = productsSnapshot.docs.filter(doc => 
    (doc.data().stockQuantity || 0) <= 10
  );
  document.getElementById('stat-low-stock').textContent = lowStockProducts.length;
  
  // Display low stock list
  const lowStockList = document.getElementById('low-stock-list');
  if (lowStockProducts.length > 0) {
    lowStockList.innerHTML = lowStockProducts.map(doc => {
      const product = doc.data();
      return `
        <div class="flex items-center justify-between p-3 bg-orange-500/10 border border-orange-500/20 rounded-lg">
          <div class="flex items-center gap-3">
            <span class="text-2xl">${product.imageEmoji || '📦'}</span>
            <div>
              <p class="font-semibold text-white">${product.name}</p>
              <p class="text-sm text-slate-400">${product.category}</p>
            </div>
          </div>
          <span class="text-orange-400 font-bold">${product.stockQuantity} left</span>
        </div>
      `;
    }).join('');
  } else {
    lowStockList.innerHTML = '<p class="text-slate-500 italic">All stock levels sufficient.</p>';
  }
  
  // Total Orders
  const ordersSnapshot = await db.collection('orders').get();
  document.getElementById('stat-total-orders').textContent = ordersSnapshot.size;
  
  // Total Revenue
  let totalRevenue = 0;
  ordersSnapshot.docs.forEach(doc => {
    totalRevenue += doc.data().total || 0;
  });
  document.getElementById('stat-total-revenue').textContent = 
    `₹${(totalRevenue / 100).toFixed(2)}`;
}
```

---

### Notify Tab (Broadcast Notifications)

**Purpose**: Send push notifications to all app users

**Features**:
- Title and message input
- Send to all users simultaneously
- Notification history tracking
- Delete sent notifications
- Real-time delivery status

**Implementation**:
```javascript
async function sendNotificationToAll(event) {
  event.preventDefault();
  
  const title = document.getElementById('notify-title').value;
  const message = document.getElementById('notify-message').value;
  
  if (!title || !message) {
    alert('Please fill in all fields');
    return;
  }
  
  const statusDiv = document.getElementById('notify-status');
  statusDiv.innerHTML = '<p class="text-yellow-400">Sending...</p>';
  
  try {
    // Get all users with FCM tokens
    const usersSnapshot = await db.collection('users').get();
    const tokens = [];
    
    usersSnapshot.forEach(doc => {
      const fcmToken = doc.data().fcm_token;
      if (fcmToken) {
        tokens.push(fcmToken);
      }
    });
    
    if (tokens.length === 0) {
      statusDiv.innerHTML = '<p class="text-red-400">No users with active tokens found</p>';
      return;
    }
    
    // Save notification to history
    await db.collection('notification_history').add({
      title: title,
      message: message,
      sentAt: firebase.firestore.FieldValue.serverTimestamp(),
      recipientCount: tokens.length,
    });
    
    // Save to each user's notifications subcollection
    const batch = db.batch();
    for (const userDoc of usersSnapshot.docs) {
      const notifRef = db.collection('users')
        .doc(userDoc.id)
        .collection('notifications')
        .doc();
      
      batch.set(notifRef, {
        id: notifRef.id,
        title: title,
        body: message,
        type: 'admin_broadcast',
        read: false,
        timestamp: firebase.firestore.FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    
    statusDiv.innerHTML = `<p class="text-green-400">✅ Notification sent to ${tokens.length} users</p>`;
    
    // Clear form
    document.getElementById('notify-form').reset();
    
    // Reload history
    loadNotificationHistory();
    
  } catch (error) {
    console.error('Error sending notification:', error);
    statusDiv.innerHTML = `<p class="text-red-400">❌ Error: ${error.message}</p>`;
  }
}

async function loadNotificationHistory() {
  const tbody = document.getElementById('notification-history-table');
  
  try {
    const snapshot = await db.collection('notification_history')
      .orderBy('sentAt', 'desc')
      .limit(50)
      .get();
    
    if (snapshot.empty) {
      tbody.innerHTML = '<tr><td colspan="4" class="px-4 py-8 text-center text-slate-500">No notifications sent yet</td></tr>';
      return;
    }
    
    tbody.innerHTML = snapshot.docs.map(doc => {
      const data = doc.data();
      const date = data.sentAt ? data.sentAt.toDate() : new Date();
      
      return `
        <tr class="hover:bg-white/5 transition-colors">
          <td class="px-4 py-3 text-white">${data.title}</td>
          <td class="px-4 py-3 text-slate-300">${data.message}</td>
          <td class="px-4 py-3 text-slate-400">${formatDate(date)}</td>
          <td class="px-4 py-3 text-right">
            <button onclick="deleteNotification('${doc.id}')" 
              class="text-red-400 hover:text-red-300 transition-colors">
              <span class="material-symbols-rounded">delete</span>
            </button>
          </td>
        </tr>
      `;
    }).join('');
  } catch (error) {
    console.error('Error loading notification history:', error);
    tbody.innerHTML = '<tr><td colspan="4" class="px-4 py-8 text-center text-red-400">Error loading history</td></tr>';
  }
}
```

---

### Products Tab (Inventory Management)

**Features**:
- View all products in paginated table
- Add new products
- Edit existing products
- Delete products
- Search and filter
- Export to CSV
- Print product list
- Bulk actions

**Product Table UI**:
- Product name and emoji
- Barcode
- Category
- Price (in ₹)
- Stock quantity with color coding
- Actions (Edit, Delete)

**Add Product Modal**:
```javascript
function openAddProductModal() {
  const modal = document.createElement('div');
  modal.className = 'fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4';
  modal.innerHTML = `
    <div class="glass-panel rounded-2xl p-8 max-w-2xl w-full max-h-[90vh] overflow-y-auto">
      <h2 class="text-2xl font-bold text-white mb-6 flex items-center gap-2">
        <span class="material-symbols-rounded text-primary-400">add_circle</span>
        Add New Product
      </h2>
      <form id="add-product-form" class="space-y-4">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block text-slate-400 mb-2">Product Name*</label>
            <input type="text" id="product-name" required 
              class="w-full bg-slate-900/50 border border-white/10 rounded-lg px-4 py-2.5 text-white">
          </div>
          <div>
            <label class="block text-slate-400 mb-2">Brand</label>
            <input type="text" id="product-brand" 
              class="w-full bg-slate-900/50 border border-white/10 rounded-lg px-4 py-2.5 text-white">
          </div>
          <div>
            <label class="block text-slate-400 mb-2">Category*</label>
            <select id="product-category" required 
              class="w-full bg-slate-900/50 border border-white/10 rounded-lg px-4 py-2.5 text-white">
              <option value="">Select category</option>
              <option value="groceries">Groceries</option>
              <option value="dairy">Dairy</option>
              <option value="snacks">Snacks</option>
              <option value="beverages">Beverages</option>
              <option value="personal_care">Personal Care</option>
              <option value="household">Household</option>
              <option value="other">Other</option>
            </select>
          </div>
          <div>
            <label class="block text-slate-400 mb-2">Price (₹)*</label>
            <input type="number" id="product-price" step="0.01" required 
              class="w-full bg-slate-900/50 border border-white/10 rounded-lg px-4 py-2.5 text-white">
          </div>
          <div>
            <label class="block text-slate-400 mb-2">Stock Quantity*</label>
            <input type="number" id="product-stock" required 
              class="w-full bg-slate-900/50 border border-white/10 rounded-lg px-4 py-2.5 text-white">
          </div>
          <div>
            <label class="block text-slate-400 mb-2">Barcode</label>
            <input type="text" id="product-barcode" 
              class="w-full bg-slate-900/50 border border-white/10 rounded-lg px-4 py-2.5 text-white">
          </div>
          <div>
            <label class="block text-slate-400 mb-2">Emoji Icon</label>
            <input type="text" id="product-emoji" placeholder="📦" maxlength="2"
              class="w-full bg-slate-900/50 border border-white/10 rounded-lg px-4 py-2.5 text-white">
          </div>
        </div>
        <div>
          <label class="block text-slate-400 mb-2">Description</label>
          <textarea id="product-description" rows="3" 
            class="w-full bg-slate-900/50 border border-white/10 rounded-lg px-4 py-2.5 text-white"></textarea>
        </div>
        <div class="flex gap-3 pt-4">
          <button type="submit" 
            class="flex-1 px-6 py-3 bg-primary-600 hover:bg-primary-500 text-white rounded-xl font-bold">
            Add Product
          </button>
          <button type="button" onclick="this.closest('.fixed').remove()" 
            class="px-6 py-3 bg-slate-800 hover:bg-slate-700 text-white rounded-xl font-semibold">
            Cancel
          </button>
        </div>
      </form>
    </div>
  `;
  
  document.body.appendChild(modal);
  
  // Handle form submission
  document.getElementById('add-product-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    await addProduct();
    modal.remove();
  });
}

async function addProduct() {
  const name = document.getElementById('product-name').value;
  const brand = document.getElementById('product-brand').value;
  const category = document.getElementById('product-category').value;
  const priceRupees = parseFloat(document.getElementById('product-price').value);
  const stock = parseInt(document.getElementById('product-stock').value);
  const barcode = document.getElementById('product-barcode').value;
  const emoji = document.getElementById('product-emoji').value || '📦';
  const description = document.getElementById('product-description').value;
  
  // Convert rupees to paise for storage
  const pricePaise = Math.round(priceRupees * 100);
  
  try {
    await db.collection('products').add({
      name: name,
      brand: brand,
      category: category,
      price: pricePaise,
      stockQuantity: stock,
      barcode: barcode || null,
      imageEmoji: emoji,
      description: description,
      isFavorite: false,
      dietaryBadges: [],
      createdAt: firebase.firestore.FieldValue.serverTimestamp(),
      updatedAt: firebase.firestore.FieldValue.serverTimestamp(),
      purchaseCount: 0,
    });
    
    alert('Product added successfully!');
    loadProducts(); // Reload product list
  } catch (error) {
    console.error('Error adding product:', error);
    alert('Error adding product: ' + error.message);
  }
}
```

**Edit Product**:
```javascript
async function editProduct(productId) {
  // Fetch product data
  const doc = await db.collection('products').doc(productId).get();
  if (!doc.exists) {
    alert('Product not found');
    return;
  }
  
  const product = doc.data();
  
  // Show modal with pre-filled data
  const modal = document.createElement('div');
  modal.className = 'fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4';
  modal.innerHTML = `
    <div class="glass-panel rounded-2xl p-8 max-w-2xl w-full">
      <h2 class="text-2xl font-bold text-white mb-6">Edit Product</h2>
      <form id="edit-product-form" class="space-y-4">
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-slate-400 mb-2">Product Name</label>
            <input type="text" id="edit-name" value="${product.name}" required 
              class="w-full bg-slate-900/50 border border-white/10 rounded-lg px-4 py-2.5 text-white">
          </div>
          <div>
            <label class="block text-slate-400 mb-2">Price (₹)</label>
            <input type="number" id="edit-price" step="0.01" value="${(product.price / 100).toFixed(2)}" required 
              class="w-full bg-slate-900/50 border border-white/10 rounded-lg px-4 py-2.5 text-white">
          </div>
          <div>
            <label class="block text-slate-400 mb-2">Stock</label>
            <input type="number" id="edit-stock" value="${product.stockQuantity}" required 
              class="w-full bg-slate-900/50 border border-white/10 rounded-lg px-4 py-2.5 text-white">
          </div>
          <div>
            <label class="block text-slate-400 mb-2">Category</label>
            <input type="text" id="edit-category" value="${product.category}" 
              class="w-full bg-slate-900/50 border border-white/10 rounded-lg px-4 py-2.5 text-white">
          </div>
        </div>
        <div class="flex gap-3">
          <button type="submit" 
            class="flex-1 px-6 py-3 bg-primary-600 hover:bg-primary-500 text-white rounded-xl font-bold">
            Save Changes
          </button>
          <button type="button" onclick="this.closest('.fixed').remove()" 
            class="px-6 py-3 bg-slate-800 hover:bg-slate-700 text-white rounded-xl">
            Cancel
          </button>
        </div>
      </form>
    </div>
  `;
  
  document.body.appendChild(modal);
  
  document.getElementById('edit-product-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const newName = document.getElementById('edit-name').value;
    const newPriceRupees = parseFloat(document.getElementById('edit-price').value);
    const newStock = parseInt(document.getElementById('edit-stock').value);
    const newCategory = document.getElementById('edit-category').value;
    
    try {
      await db.collection('products').doc(productId).update({
        name: newName,
        price: Math.round(newPriceRupees * 100),
        stockQuantity: newStock,
        category: newCategory,
        updatedAt: firebase.firestore.FieldValue.serverTimestamp(),
      });
      
      alert('Product updated successfully!');
      modal.remove();
      loadProducts();
    } catch (error) {
      console.error('Error updating product:', error);
      alert('Error: ' + error.message);
    }
  });
}
```

**Delete Product**:
```javascript
async function deleteProduct(productId) {
  if (!confirm('Are you sure you want to delete this product? This action cannot be undone.')) {
    return;
  }
  
  try {
    await db.collection('products').doc(productId).delete();
    alert('Product deleted successfully!');
    loadProducts();
  } catch (error) {
    console.error('Error deleting product:', error);
    alert('Error: ' + error.message);
  }
}
```

**Export to CSV**:
```javascript
async function exportProductsCSV() {
  const snapshot = await db.collection('products').get();
  
  // CSV headers
  let csv = 'Name,Category,Brand,Price (₹),Stock,Barcode\n';
  
  // CSV rows
  snapshot.docs.forEach(doc => {
    const p = doc.data();
    csv += `"${p.name}","${p.category}","${p.brand || ''}",${(p.price / 100).toFixed(2)},${p.stockQuantity},"${p.barcode || ''}"\n`;
  });
  
  // Download
  const blob = new Blob([csv], { type: 'text/csv' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `products_${new Date().toISOString().split('T')[0]}.csv`;
  a.click();
}
```

**Search/Filter Products**:
```javascript
function filterProducts() {
  const searchInput = document.getElementById('search-products').value.toLowerCase();
  const rows = document.querySelectorAll('#products-table tr');
  
  rows.forEach(row => {
    const text = row.textContent.toLowerCase();
    if (text.includes(searchInput)) {
      row.style.display = '';
    } else {
      row.style.display = 'none';
    }
  });
}
```

---

### Orders Tab

**Features**:
- View all orders from all users
- Order details popup
- Filter by status/payment method
- Export orders to CSV
- Print order list
- Search by order ID or user

**Load Orders**:
```javascript
async function loadOrders() {
  const tbody = document.getElementById('orders-table');
  tbody.innerHTML = '<tr><td colspan="8" class="text-center py-8"><div class="loader inline-block"></div> Loading...</td></tr>';
  
  try {
    const snapshot = await db.collection('orders')
      .orderBy('createdAt', 'desc')
      .limit(100)
      .get();
    
    if (snapshot.empty) {
      tbody.innerHTML = '<tr><td colspan="8" class="text-center py-8 text-slate-500">No orders yet</td></tr>';
      return;
    }
    
    tbody.innerHTML = snapshot.docs.map(doc => {
      const order = doc.data();
      const date = order.createdAt ? order.createdAt.toDate() : new Date();
      
      // Status badge color
      const statusColor = {
        'completed': 'bg-green-500/10 text-green-400 border-green-500/20',
        'pending': 'bg-yellow-500/10 text-yellow-400 border-yellow-500/20',
        'cancelled': 'bg-red-500/10 text-red-400 border-red-500/20',
      }[order.status] || 'bg-slate-500/10 text-slate-400';
      
      // Payment status badge
      const paymentColor = {
        'Paid': 'bg-green-500/10 text-green-400',
        'Pending Payment': 'bg-yellow-500/10 text-yellow-400',
        'Failed': 'bg-red-500/10 text-red-400',
      }[order.paymentStatus] || 'bg-slate-500/10 text-slate-400';
      
      return `
        <tr class="hover:bg-white/5 transition-colors">
          <td class="px-6 py-4">
            <button onclick="viewOrderDetails('${doc.id}')" 
              class="text-primary-400 hover:text-primary-300 font-mono font-semibold">
              ${order.id || doc.id}
            </button>
          </td>
          <td class="px-6 py-4 text-slate-300">${order.userId?.substring(0, 8)}...</td>
          <td class="px-6 py-4 text-slate-300">${formatDate(date)}</td>
          <td class="px-6 py-4">
            <span class="px-2 py-1 rounded text-xs font-semibold ${statusColor} inline-block">
              ${order.status}
            </span>
          </td>
          <td class="px-6 py-4 text-white font-semibold">₹${(order.total / 100).toFixed(2)}</td>
          <td class="px-6 py-4 text-slate-300">${order.paymentMethod}</td>
          <td class="px-6 py-4">
            <span class="px-2 py-1 rounded text-xs ${paymentColor}">
              ${order.paymentStatus}
            </span>
          </td>
          <td class="px-6 py-4 text-right">
            <button onclick="viewOrderDetails('${doc.id}')"
              class="text-primary-400 hover:text-primary-300 transition-colors">
              <span class="material-symbols-rounded">visibility</span>
            </button>
          </td>
        </tr>
      `;
    }).join('');
  } catch (error) {
    console.error('Error loading orders:', error);
    tbody.innerHTML = '<tr><td colspan="8" class="text-center py-8 text-red-400">Error loading orders</td></tr>';
  }
}
```

**Order Details Popup**:
```javascript
async function viewOrderDetails(orderId) {
  const doc = await db.collection('orders').doc(orderId).get();
  if (!doc.exists) {
    alert('Order not found');
    return;
  }
  
  const order = doc.data();
  const date = order.createdAt ? order.createdAt.toDate() : new Date();
  
  // Create modal
  const modal = document.createElement('div');
  modal.className = 'fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4';
  modal.innerHTML = `
    <div class="glass-panel rounded-2xl p-8 max-w-3xl w-full max-h-[90vh] overflow-y-auto">
      <div class="flex items-center justify-between mb-6">
        <h2 class="text-2xl font-bold text-white">Order Details</h2>
        <button onclick="this.closest('.fixed').remove()" 
          class="text-slate-400 hover:text-white">
          <span class="material-symbols-rounded">close</span>
        </button>
      </div>
      
      <div class="grid grid-cols-2 gap-4 mb-6 text-sm">
        <div>
          <p class="text-slate-400">Order ID</p>
          <p class="text-white font-mono">${order.id}</p>
        </div>
        <div>
          <p class="text-slate-400">Date</p>
          <p class="text-white">${formatDate(date)}</p>
        </div>
        <div>
          <p class="text-slate-400">Payment Method</p>
          <p class="text-white">${order.paymentMethod}</p>
        </div>
        <div>
          <p class="text-slate-400">Payment Status</p>
          <p class="text-white">${order.paymentStatus}</p>
        </div>
      </div>
      
      <div class="mb-6">
        <h3 class="text-lg font-semibold text-white mb-3">Items (${order.items?.length || 0})</h3>
        <div class="space-y-2">
          ${order.items?.map(item => `
            <div class="flex items-center justify-between p-3 bg-slate-900/50 rounded-lg">
              <div class="flex items-center gap-3">
                <span class="text-2xl">${item.productEmoji || '📦'}</span>
                <div>
                  <p class="text-white">${item.productName}</p>
                  <p class="text-sm text-slate-400">Qty: ${item.quantity} × ₹${(item.price / 100).toFixed(2)}</p>
                </div>
              </div>
              <p class="text-white font-semibold">₹${(item.total / 100).toFixed(2)}</p>
            </div>
          `).join('') || '<p class="text-slate-500">No items</p>'}
        </div>
      </div>
      
      <div class="border-t border-white/10 pt-4">
        <div class="flex justify-between text-lg">
          <span class="text-slate-300">Subtotal</span>
          <span class="text-white">₹${(order.subtotal / 100).toFixed(2)}</span>
        </div>
        <div class="flex justify-between text-lg mt-2">
          <span class="text-slate-300">Tax</span>
          <span class="text-white">₹${((order.tax || 0) / 100).toFixed(2)}</span>
        </div>
        <div class="flex justify-between text-xl font-bold mt-3">
          <span class="text-white">Total</span>
          <span class="text-primary-400">₹${(order.total / 100).toFixed(2)}</span>
        </div>
      </div>
    </div>
  `;
  
  document.body.appendChild(modal);
}
```

---

### Users Tab

**Features**:
- View all registered users
- User details (name, email, phone, role)
- Suspend/unsuspend users
- Delete user accounts
- Search users
- Export user list

**Load Users**:
```javascript
async function loadUsers() {
  const tbody = document.getElementById('users-table');
  tbody.innerHTML = '<tr><td colspan="6" class="text-center py-8"><div class="loader"></div></td></tr>';
  
  try {
    const snapshot = await db.collection('users').get();
    
    if (snapshot.empty) {
      tbody.innerHTML = '<tr><td colspan="6" class="text-center py-8 text-slate-500">No users found</td></tr>';
      return;
    }
    
    tbody.innerHTML = snapshot.docs.map(doc => {
      const user = doc.data();
      const createdAt = user.createdAt ? user.createdAt.toDate() : new Date();
      
      return `
        <tr class="hover:bg-white/5 transition-colors">
          <td class="px-6 py-4">
            <div class="flex items-center gap-3">
              ${user.photoURL ? 
                `<img src="${user.photoURL}" alt="Avatar" class="w-10 h-10 rounded-full">` :
                `<div class="w-10 h-10 rounded-full bg-slate-800 flex items-center justify-center text-2xl">
                  ${user.avatarEmoji || '👤'}
                </div>`
              }
              <div>
                <p class="text-white font-semibold">${user.name || user.displayName || 'N/A'}</p>
                <p class="text-xs text-slate-400">${user.email}</p>
              </div>
            </div>
          </td>
          <td class="px-6 py-4 text-slate-300">${user.phone || 'N/A'}</td>
          <td class="px-6 py-4">
            <span class="px-2 py-1 rounded text-xs font-semibold ${
              user.role === 'admin' ? 'bg-purple-500/10 text-purple-400' : 'bg-blue-500/10 text-blue-400'
            }">
              ${user.role || 'customer'}
            </span>
          </td>
          <td class="px-6 py-4 text-slate-400 text-sm">${formatDate(createdAt)}</td>
          <td class="px-6 py-4">
            ${user.isSuspended ? 
              '<span class="px-2 py-1 rounded text-xs bg-red-500/10 text-red-400">Suspended</span>' :
              '<span class="px-2 py-1 rounded text-xs bg-green-500/10 text-green-400">Active</span>'
            }
          </td>
          <td class="px-6 py-4 text-right">
            <button onclick="toggleSuspendUser('${doc.id}', ${!user.isSuspended})" 
              class="text-yellow-400 hover:text-yellow-300 mr-3">
              <span class="material-symbols-rounded">${user.isSuspended ? 'check_circle' : 'block'}</span>
            </button>
            <button onclick="deleteUser('${doc.id}')" 
              class="text-red-400 hover:text-red-300">
              <span class="material-symbols-rounded">delete</span>
            </button>
          </td>
        </tr>
      `;
    }).join('');
  } catch (error) {
    console.error('Error loading users:', error);
    tbody.innerHTML = '<tr><td colspan="6" class="text-center py-8 text-red-400">Error loading users</td></tr>';
  }
}
```

**Suspend/Unsuspend User**:
```javascript
async function toggleSuspendUser(userId, suspend) {
  const action = suspend ? 'suspend' : 'unsuspend';
  if (!confirm(`Are you sure you want to ${action} this user?`)) {
    return;
  }
  
  try {
    await db.collection('users').doc(userId).update({
      isSuspended: suspend,
      updatedAt: firebase.firestore.FieldValue.serverTimestamp(),
    });
    
    alert(`User ${suspend ? 'suspended' : 'unsuspended'} successfully!`);
    loadUsers();
  } catch (error) {
    console.error(`Error ${action}ing user:`, error);
    alert('Error: ' + error.message);
  }
}
```

---

### Analytics Tab

**Features**:
- Revenue trends (daily, weekly, monthly)
- Top selling products
- Category performance
- User growth metrics
- Order statistics
- Visual charts (Line, Bar, Pie, Doughnut)

**Revenue Chart (Chart.js)**:
```javascript
async function loadAnalyticsData() {
  // Fetch orders for last 30 days
  const thirtyDaysAgo = new Date();
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
  
  const ordersSnapshot = await db.collection('orders')
    .where('createdAt', '>=', firebase.firestore.Timestamp.fromDate(thirtyDaysAgo))
    .get();
  
  // Group by date
  const revenueByDate = {};
  ordersSnapshot.docs.forEach(doc => {
    const order = doc.data();
    const date = order.createdAt.toDate().toISOString().split('T')[0];
    
    if (!revenueByDate[date]) {
      revenueByDate[date] = 0;
    }
    revenueByDate[date] += order.total / 100;
  });
  
  // Prepare chart data
  const labels = Object.keys(revenueByDate).sort();
  const data = labels.map(date => revenueByDate[date]);
  
  // Create chart
  const ctx = document.getElementById('revenue-chart').getContext('2d');
  new Chart(ctx, {
    type: 'line',
    data: {
      labels: labels.map(date => new Date(date).toLocaleDateString('en-IN', { day: 'numeric', month: 'short' })),
      datasets: [{
        label: 'Revenue (₹)',
        data: data,
        borderColor: '#10b981',
        backgroundColor: 'rgba(16, 185, 129, 0.1)',
        fill: true,
        tension: 0.4,
      }],
    },
    options: {
      responsive: true,
      plugins: {
        legend: {
          display: true,
          labels: { color: '#cbd5e1' },
        },
      },
      scales: {
        x: {
          ticks: { color: '#94a3b8' },
          grid: { color: 'rgba(255, 255, 255, 0.1)' },
        },
        y: {
          ticks: { color: '#94a3b8' },
          grid: { color: 'rgba(255, 255, 255, 0.1)' },
        },
      },
    },
  });
}
```

**Top Products Chart**:
```javascript
async function loadTopProducts() {
  const productsSnapshot = await db.collection('products')
    .orderBy('purchaseCount', 'desc')
    .limit(10)
    .get();
  
  const labels = [];
  const data = [];
  
  productsSnapshot.docs.forEach(doc => {
    const product = doc.data();
    labels.push(product.name);
    data.push(product.purchaseCount || 0);
  });
  
  const ctx = document.getElementById('top-products-chart').getContext('2d');
  new Chart(ctx, {
    type: 'bar',
    data: {
      labels: labels,
      datasets: [{
        label: 'Times Purchased',
        data: data,
        backgroundColor: '#10b981',
      }],
    },
    options: {
      indexAxis: 'y',
      responsive: true,
      plugins: {
        legend: { display: false },
      },
      scales: {
        x: {
          ticks: { color: '#94a3b8' },
          grid: { color: 'rgba(255, 255, 255, 0.1)' },
        },
        y: {
          ticks: { color: '#94a3b8' },
          grid: { display: false },
        },
      },
    },
  });
}
```

---

### Feedbacks Tab

**Features**:
- View all customer feedback
- Star ratings display
- Read comments
- Filter by rating
- Delete feedback
- Export feedback data

**Load Feedbacks**:
```javascript
async function loadFeedbacks() {
  const feedbacksContainer = document.getElementById('feedbacks-container');
  feedbacksContainer.innerHTML = '<div class="text-center py-8"><div class="loader"></div></div>';
  
  try {
    const snapshot = await db.collection('feedbacks')
      .orderBy('createdAt', 'desc')
      .get();
    
    if (snapshot.empty) {
      feedbacksContainer.innerHTML = '<p class="text-center py-8 text-slate-500">No feedback yet</p>';
      return;
    }
    
    feedbacksContainer.innerHTML = snapshot.docs.map(doc => {
      const feedback = doc.data();
      const date = feedback.createdAt ? feedback.createdAt.toDate() : new Date();
      
      // Generate star rating
      const stars = '⭐'.repeat(Math.round(feedback.rating || 0));
      
      return `
        <div class="glass-panel rounded-xl p-6">
          <div class="flex items-start justify-between mb-4">
            <div>
              <p class="text-white font-semibold">${feedback.userName || 'Anonymous'}</p>
              <p class="text-sm text-slate-400">${formatDate(date)}</p>
            </div>
            <div class="flex items-center gap-2">
              <span class="text-xl">${stars}</span>
              <button onclick="deleteFeedback('${doc.id}')" 
                class="text-red-400 hover:text-red-300">
                <span class="material-symbols-rounded text-sm">delete</span>
              </button>
            </div>
          </div>
          <p class="text-slate-300">${feedback.comment || 'No comment'}</p>
          ${feedback.category ? `
            <span class="inline-block mt-3 px-3 py-1 rounded-full bg-slate-800 text-xs text-slate-400">
              ${feedback.category}
            </span>
          ` : ''}
        </div>
      `;
    }).join('');
  } catch (error) {
    console.error('Error loading feedbacks:', error);
    feedbacksContainer.innerHTML = '<p class="text-center py-8 text-red-400">Error loading feedback</p>';
  }
}
```

---

###Bug Reports Tab

**Features**:
- View all bug reports
- Report details (description, steps, device info)
- Status management (open, in-progress, resolved, closed)
- Priority assignment
- Delete reports

**Load Bug Reports**:
```javascript
async function loadBugReports() {
  const container = document.getElementById('bug-reports-container');
  container.innerHTML = '<div class="text-center py-8"><div class="loader"></div></div>';
  
  try {
    const snapshot = await db.collection('bug_reports')
      .orderBy('createdAt', 'desc')
      .get();
    
    if (snapshot.empty) {
      container.innerHTML = '<p class="text-center py-8 text-slate-500">No bug reports yet</p>';
      return;
    }
    
    container.innerHTML = snapshot.docs.map(doc => {
      const report = doc.data();
      const date = report.createdAt ? report.createdAt.toDate() : new Date();
      
      const statusColors = {
        'open': 'bg-red-500/10 text-red-400 border-red-500/20',
        'in-progress': 'bg-yellow-500/10 text-yellow-400 border-yellow-500/20',
        'resolved': 'bg-green-500/10 text-green-400 border-green-500/20',
        'closed': 'bg-slate-500/10 text-slate-400 border-slate-500/20',
      };
      
      return `
        <div class="glass-panel rounded-xl p-6">
          <div class="flex justify-between items-start mb-4">
            <div>
              <div class="flex items-center gap-2 mb-2">
                <span class="px-3 py-1 rounded-full text-xs font-semibold border ${statusColors[report.status] || statusColors['open']}">
                  ${report.status || 'open'}
                </span>
                <span class="text-xs text-slate-500 font-mono">#${report.id.substring(0, 8)}</span>
              </div>
              <p class="text-white font-semibold">${report.description}</p>
              <p class="text-sm text-slate-400 mt-1">Reported by: ${report.userEmail || 'Unknown'}</p>
              <p class="text-xs text-slate-500">${formatDate(date)}</p>
            </div>
            <button onclick="deleteBugReport('${doc.id}')" 
              class="text-red-400 hover:text-red-300">
              <span class="material-symbols-rounded">delete</span>
            </button>
          </div>
          
          ${report.stepsToReproduce ? `
            <div class="mt-4 p-3 bg-slate-900/50 rounded-lg">
              <p class="text-xs text-slate-400 mb-1">Steps to reproduce:</p>
              <p class="text-sm text-slate-300 whitespace-pre-wrap">${report.stepsToReproduce}</p>
            </div>
          ` : ''}
          
          <div class="mt-4 flex flex-wrap gap-2 text-xs text-slate-500">
            <span>📱 ${report.deviceModel || 'Unknown'}</span>
            <span>🤖 Android ${report.osVersion || 'Unknown'}</span>
            <span>📦 v${report.appVersion || 'Unknown'}</span>
          </div>
          
          <div class="mt-4 flex gap-2">
            ${['open', 'in-progress', 'resolved', 'closed'].map(status => `
              <buttononclick="updateBugReportStatus('${doc.id}', '${status}')" 
                class="px-3 py-1 rounded text-xs ${report.status === status ? 'bg-primary-600 text-white' : 'bg-slate-800 text-slate-400 hover:bg-slate-700'}">
                ${status}
              </button>
            `).join('')}
          </div>
        </div>
      `;
    }).join('');
  } catch (error) {
    console.error('Error loading bug reports:', error);
    container.innerHTML = '<p class="text-center py-8 text-red-400">Error loading bug reports</p>';
  }
}

async function updateBugReportStatus(reportId, newStatus) {
  try {
    await db.collection('bug_reports').doc(reportId).update({
      status: newStatus,
      updatedAt: firebase.firestore.FieldValue.serverTimestamp(),
    });
    loadBugReports();
  } catch (error) {
    console.error('Error updating status:', error);
    alert('Error: ' + error.message);
  }
}
```

---

## Firebase Backend Infrastructure

### Firebase Services Used

#### 1. Firebase Authentication

**Configuration**: `lib/firebase_options.dart`

**Providers Enabled**:
- Google Sign-In (OAuth 2.0)
- Email/Password

**Features**:
- User registration and login
- Password reset via email
- Session management
- Token refresh
- Multi-platform support (Android, iOS, Web)

**Security Rules**:
- All users must be authenticated to access app features
- Admin whitelist enforced in Firestore rules
- Token expiration: 1 hour (auto-refresh)

---

#### 2. Cloud Firestore (Database)

**Structure**:
```
/products/{productId}
  - id, name, category, brand, price, stockQuantity, barcode, imageEmoji
  - description, dietaryBadges, isFavorite
  - createdAt, updatedAt, purchaseCount

/orders/{orderId}
  - id, userId, items[], subtotal, tax, discount, total
  - paymentMethod, paymentStatus, status, exitCode
  - createdAt, updatedAt

/receipts/{receiptId}
  - orderId, userId, items[], total
  - generatedAt, format (PDF/JSON)

/users/{userId}
  - email, name, displayName, phone, photoURL, avatarEmoji
  -role, isSuspended, membershipTier, fcm_token
  - createdAt, updatedAt, lastLoginTime
  
  /users/{userId}/notifications/{notifId}
    - id, title, body, type, read, timestamp, data
  
  /users/{userId}/favorites/{productId}
    - productId, addedAt
  
  /users/{userId}/addresses/{addressId}
    - name, street, city, zipCode, phone, isDefault
  
  /users/{userId}/paymentMethods/{methodId}
    - type, lastFour, expiryDate, isDefault

/feedbacks/{feedbackId}
  - userId, userName, rating, comment, category
  - createdAt

/bug_reports/{reportId}
  - userId, userEmail, description, stepsToReproduce
  - expectedBehavior, actualBehavior
  - appVersion, buildNumber, platform, osVersion, deviceModel
  - status (open, in-progress, resolved, closed)
  - createdAt, updatedAt

/budgets/{budgetId}
  - userId, amount, period (weekly/monthly)
  - startDate, endDate, currentSpent
  - createdAt, updatedAt

/analytics/{eventId}
  - userId, eventName, parameters, timestamp

/notification_history/{notifId}
  - title, message, sentAt, recipientCount
```

**Indexes Required**:
```javascript
// firestore.indexes.json
{
  "indexes": [
    {
      "collectionGroup": "orders",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "products",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "category", "order": "ASCENDING" },
        { "fieldPath": "name", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "orders",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    }
  ]
}
```

---

#### 3. Firebase Cloud Messaging (FCM)

**Purpose**: Send push notifications to mobile app users

**Notification Types**:
- Order updates
- Stock alerts
- Price drops
- Promotional offers
- Admin broadcasts

**Implementation Flow**:
1. User grants notification permission
2. FCM generates unique device token
3. Token stored in Firestore `/users/{uid}/fcm_token`
4. Admin sends notification via web dashboard
5. Cloud Function/Admin SDK sends to FCM
6. FCM delivers to device
7. App shows notification via flutter_local_notifications

**Payload Structure**:
```javascript
{
  notification: {
    title: "Order Confirmed",
    body: "Your order #12345 has been confirmed",
  },
  data: {
    type: "order_update",
    orderId: "ORDER_123",
    action: "view_order",
  },
  token: "device_fcm_token",
}
```

---

#### 4. Firebase Analytics

**Events Tracked**:
- `app_open`: App launched
- `sign_up`: New user registration
- `login`: User sign in
- `view_item`: Product viewed
- `add_to_cart`: Item added to cart
- `remove_from_cart`: Item removed
- `begin_checkout`: Checkout started
- `purchase`: Order completed
- `search`: Search performed
- `share`: Content shared

**User Properties**:
- `user_role`: customer/admin
- `membership_tier`: User/Premium
- `total_orders`: Lifetime order count
- `total_spent`: Lifetime spending

**Custom Events**:
```dart
AnalyticsService().logEvent('voice_search_used', {
  'query': searchQuery,
  'results_count': results.length,
});

AnalyticsService().logEvent('budget_exceeded', {
  'budget_amount': budget.amount,
  'exceeded_by': exceededAmount,
});
```

---

#### 5. Firebase Crashlytics

**Purpose**: Real-time crash reporting and monitoring

**Features**:
- Automatic crash detection
- Stack trace collection
- User impact metrics
- Custom logging
- Fatal/non-fatal error tracking

**Integration**:
```dart
// In main.dart
void main() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    await Firebase.initializeApp();
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    
    runApp(const SmartCartApp());
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

// Custom logging
FirebaseCrashlytics.instance.log('User performed action X');

// Set user identifier
FirebaseCrashlytics.instance.setUserIdentifier(userId);

// Record non-fatal error
try {
  // risky operation
} catch (e, stack) {
  FirebaseCrashlytics.instance.recordError(e, stack, fatal: false);
}
```

---

#### 6. Firebase Hosting

**Purpose**: Host web admin dashboard

**Deployment**:
```bash
firebase init hosting
firebase deploy --only hosting
```

**Configuration** (`firebase.json`):
```json
{
  "hosting": {
    "public": "web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      {
        "source": "**

## Getting started
1) Install prerequisites
   - Flutter 3.38.6+ with Android SDK 33+
   - Firebase CLI (optional, for deploys)

2) Clone and install
   ```bash
   git clone https://github.com/yourusername/SmartCart.git
   cd SmartCart
   flutter pub get
   ```

3) Configure Firebase
   - Create a Firebase project
   - Download `android/app/google-services.json`
   - Ensure `lib/firebase_options.dart` matches your project (FlutterFire CLI)

4) Run locally
   ```bash
   flutter analyze
   flutter test
   flutter run
   ```

## Testing
- Unit/integration suite: 76 tests across 11 files (see test/)
- Run individually (per-file) or together:
  ```bash
  flutter test
  flutter test test/models_test.dart
  flutter test integration_test/
  ```

## Production gatekeeper
`publish_check.ps1` runs a full pre-release checklist:
- Environment and critical files validation
- Runs each test file and the full suite; reports counts
- Flutter analyze
- Optional widget tests and coverage
- Security scan for keys/passwords in `lib/`
- Builds release APKs split per ABI and writes SHA256 checksums
- Generates `build_info.json` with version, time, and Flutter version
Run it before shipping:
```powershell
./publish_check.ps1
```

## CI/CD
- GitHub Actions workflow uses Flutter SDK (subosito/flutter-action) to run `flutter pub get`, `flutter analyze`, and `flutter test` on every push
- Add store signing steps or Play Store upload as needed

## Build and release
- Debug: `flutter build apk --debug`
- Release (manual): `flutter build apk --release --split-per-abi`
- Release (scripted): `./publish_check.ps1` then upload APKs from `releases/PROD_BUILD_*`

## Security and access
- Authentication: Google Sign-In required for all users
- Admin whitelist (web): admin1@example.com, admin2@example.com
- Firestore rules isolate user data under `/users/{userId}/` and restrict writes by role

## Troubleshooting
- If tests report zero executed, rerun with `flutter test --verbose` and check `publish_check.ps1` logs
- If Firebase errors appear, verify `google-services.json` path and `firebase_options.dart`
- For CI issues, confirm the GitHub Actions workflow uses Flutter (not Dart) commands

## License
Proprietary. All rights reserved.

3. **Configure Firebase**
   - Copy your `google-services.json` to `android/app/`
   - Update the file with your Firebase config and ensure your app's package name matches
   - **Add SHA fingerprints**:
     - Add both **SHA-1** and **SHA-256** for your debug/release keystores in Firebase Console → Project settings → Your apps → Add fingerprint.
     - Example debug fingerprints from this project (run `keytool` to verify locally):
       - SHA-1: `5B:4E:90:04:A4:E5:4E:C2:8E:5A:10:E0:A8:15:91:F5:46:F3:C4:6C`
       - SHA-256: `EA:85:93:D4:76:D9:00:DF:43:04:76:58:F2:71:A1:1E:B9:AC:7A:3F:A9:7E:6C:EF:DF:8E:56:3C`
     - After adding fingerprints, re-download `google-services.json` and replace `android/app/google-services.json`.
   - Web admin: create `web/firebase_config.js` from `web/firebase_config.js.example` and add your Firebase config to it (this file is gitignored).
   - Enable Authentication, Firestore, and other required services

4. **Run App**
   ```bash
   flutter run
   ```

### Web Dashboard Setup
1. **Navigate to Web Directory**
   ```bash
   cd web
   ```

2. **Configure Firebase**
   - Update Firebase config in 
   - Set up Firestore security rules
   - Configure authentication providers

3. **Deploy to Firebase Hosting**
   ```bash
   firebase init hosting
   firebase deploy --only hosting
   ```

## Running the App

### Development Mode
```bash
# Run on connected device/emulator
flutter run

# Run on specific platform
flutter run -d android
flutter run -d ios

# Hot reload for development
flutter run --hot
```

### Production Build
```bash
# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release

# Build web
flutter build web
```

### Web Dashboard
- Access via Firebase hosting URL
- Admin login with whitelisted Google accounts
- Real-time data updates without refresh

## Useful Commands

### Flutter Commands
```bash
# Install dependencies
flutter pub get

# Clean build cache
flutter clean

# Run the app in development mode
flutter run

# Run on specific device/platform
flutter run -d android
flutter run -d ios
flutter run -d chrome

# Hot reload (while app is running)
r

# Build for production
flutter build apk --release
flutter build ios --release
flutter build web

# Analyze code for issues
flutter analyze

# Run tests
flutter test

# Check Flutter environment
flutter doctor

# Upgrade Flutter SDK
flutter upgrade

# List connected devices
flutter devices
```

### Firebase Commands
```bash
# Initialize Firebase in project
firebase init

# Login to Firebase
firebase login

# Deploy to Firebase Hosting
firebase deploy --only hosting

# Automated deploy via GitHub Actions
To enable automatic deploys of the `web/` admin UI on pushes to `main`:

1. Create a CI token locally:
   ```bash
   firebase login:ci
   ```
   Copy the token and add it as the `FIREBASE_TOKEN` secret in your GitHub repository settings.

2. Optionally, create a single JSON string for your web firebase config and add it as `WEB_FIREBASE_CONFIG` in GitHub Secrets. The workflow will write `web/firebase_config.js` from this secret at deploy time.

3. Push to `main` and GitHub Actions will run `.github/workflows/firebase-hosting.yml` to deploy the `web/` folder. This workflow uses the `FIREBASE_TOKEN` and (optionally) `WEB_FIREBASE_CONFIG` secrets.

# Deploy specific functions
firebase deploy --only functions

# Start Firebase emulators
firebase emulators:start

# View Firebase project info
firebase projects:list

# Add Firebase to Flutter project
flutterfire configure
```

### Git Commands
```bash
# Clone the repository
git clone https://github.com/yourusername/SmartCart.git

# Check status
git status

# Add files to staging
git add .

# Commit changes
git commit -m "Your commit message"

# Push to remote
git push origin main

# Pull latest changes
git pull origin main

# Create new branch
git checkout -b feature-branch

# Switch branches
git checkout main

# View commit history
git log --oneline
```

### Android Specific Commands
```bash
# Build Android APK
flutter build apk --release

# Build Android App Bundle
flutter build appbundle --release

# Install APK to connected device
flutter install

# List connected Android devices
adb devices

# View Android logs
adb logcat
```

### iOS Specific Commands (macOS only)
```bash
# Build for iOS
flutter build ios --release

# Open iOS project in Xcode
open ios/Runner.xcworkspace

# Clean iOS build
flutter clean && cd ios && pod install && cd ..
```

### Web Specific Commands
```bash
# Build for web
flutter build web

# Serve web app locally
flutter run -d chrome

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

### Development Workflow Commands
```bash
# Full clean and rebuild
flutter clean && flutter pub get && flutter run

# Run with specific flavor (if configured)
flutter run --flavor development

# Generate localization files
flutter gen-l10n

# Generate launcher icons
flutter pub run flutter_launcher_icons:main

# Generate native splash screen
flutter pub run flutter_native_splash:create

# Update app version
flutter pub run version:update
```

### Testing and Quality Commands
```bash
# Run unit tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart

# Check code coverage
flutter test --coverage

# Format code
flutter format lib/

# Fix code issues automatically
flutter fix --apply

# Analyze dependencies
flutter pub outdated
flutter pub upgrade
```

### Deployment Commands
```bash
# Build and deploy Android
flutter build apk --release
# Then upload to Play Store

# Build and deploy iOS
flutter build ios --release
# Then archive in Xcode and upload to App Store

# Deploy web to Firebase
flutter build web
firebase deploy --only hosting

# Create release tag
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

## Usage Guide

### For Customers
1. **Getting Started**: Register with Google account
2. **Shopping**: Use scanner to add items or browse manually
3. **Cart Management**: Adjust quantities and check stock
4. **Payment**: Select preferred payment method
5. **Analytics**: View spending patterns in profile

### For Admins
1. **Dashboard Overview**: Monitor key metrics
2. **Inventory**: Update stock and product details
3. **Orders**: Process and track customer orders
4. **Analytics**: Review sales data and trends
5. **User Management**: Handle customer accounts

## Benefits and How It Helps Users

### For Customers
- **Time Savings**: 70% faster checkout process
- **Convenience**: Shop at your own pace without lines
- **Budget Control**: Real-time spending tracking
- **Accessibility**: Voice feedback for visually impaired users
- **Data Insights**: Understand spending patterns
- **Environmental Impact**: Reduced paper receipt usage

### For Store Owners
- **Operational Efficiency**: Streamlined inventory management
- **Data-Driven Decisions**: Comprehensive analytics
- **Customer Insights**: Understanding shopping behavior
- **Reduced Costs**: Lower staffing requirements for checkout
- **Real-time Monitoring**: Live inventory and sales tracking
- **Scalability**: Easy to expand product catalog

### For Society
- **Contactless Shopping**: Reduced physical contact during shopping
- **Waste Reduction**: Digital receipts and minimal packaging
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
- **GitHub Repository**: https://github.com/yourusername/SmartCart
- **Firebase Project**: your-project-id
- **Web Dashboard**: https://your-project.web.app/admin
- **Landing Page**: https://your-project.web.app

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

## 📚 Comprehensive Architecture & Backend Deep Dive

This section covers the **internal workings** of every system — how data moves from a user's tap on the screen all the way to Firebase and back, how every exception is caught and surfaced, how each service responds to edge cases, and how the entire architecture ties together. No code snippets here — just architecture, workflows, decisions, and the "why" behind every layer.

---

### 🏗️ Application Bootstrap Workflow

When a user launches SmartCart, the following **exact sequence** occurs:

```
┌─────────────────────────────────────────────────────────────────────┐
│                     APP LAUNCH SEQUENCE                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. Dart runtime starts → main() called inside runZonedGuarded()   │
│     ↓                                                               │
│  2. WidgetsFlutterBinding.ensureInitialized()                       │
│     ↓ (required before any async work)                              │
│  3. Firebase.initializeApp() with platform-specific options         │
│     ├── SUCCESS → Firebase SDK ready                                │
│     └── FAILURE → Prints error, app continues degraded              │
│     ↓                                                               │
│  4. FirebaseAuth language set to English                            │
│     ↓                                                               │
│  5. Crashlytics collection enabled                                  │
│     ↓                                                               │
│  6. Firestore offline persistence configured (100MB cache)          │
│     ├── Network toggled (disable then enable) to force sync         │
│     └── Only for mobile (not web)                                   │
│     ↓                                                               │
│  7. AnalyticsService.initialize() — logs app_open event             │
│     ↓                                                               │
│  8. FlutterError.onError → wired to Crashlytics                    │
│     ↓                                                               │
│  9. runApp(SmartCartApp()) - Widget tree begins building            │
│     ↓                                                               │
│  10. Check SharedPreferences for onboarding_completed flag          │
│      ├── FALSE → Show OnboardingScreen                              │
│      └── TRUE → Check auth state                                    │
│      ↓                                                               │
│  11. StreamBuilder listens to FirebaseAuth.authStateChanges()       │
│      ├── WAITING + cached user exists → Go to Home immediately      │
│      ├── WAITING + no cached user → Show loading spinner            │
│      ├── HAS USER → Show RoleBasedHome (wrapped in SuspensionGuard)│
│      └── NO USER → Show LoginScreen                                 │
│      ↓                                                               │
│  12. ChangeNotifierProvider creates AppStateProvider                │
│      Simultaneously loads:                                          │
│      • Theme preference (SharedPreferences)                         │
│      • Products (Firestore, first 20 via pagination)                │
│      • Addresses (Firestore real-time listener)                     │
│      • User profile (Firestore real-time listener)                  │
│      • Payment methods (Firestore real-time listener)               │
│      • Orders (Firestore real-time listener, filtered by userId)    │
│      ↓                                                               │
│  13. ShakeListener widget wraps entire app                          │
│      ↓ (listens to accelerometer for shake-to-report-bug)           │
│  14. App is fully interactive                                       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

**Zone Error Handling**: The entire application runs inside `runZonedGuarded`. Any uncaught exception anywhere in the Dart isolate — whether from async gaps, timer callbacks, or stream errors — is intercepted and forwarded to Crashlytics with a `fatal: true` flag. This means **zero silent failures**. Every crash is recorded with full stack trace in the Firebase Console.

**Degraded Mode**: If Firebase initialization fails (no internet, corrupted config), the app doesn't crash. It prints the error and attempts to continue. Firestore's offline cache means previously loaded products/orders are still available. Only features requiring live auth (login, new orders) will fail gracefully.

---

### 🔐 Authentication System — Complete Lifecycle

#### Sign-Up Flow (Email/Password)

```
User enters email, password, name, selects role
  ↓
ClientSide: Validate fields (not empty, valid email format, password 8+ chars)
  ↓
AuthService.signUpWithEmail() called
  ↓
Firebase Auth: createUserWithEmailAndPassword()
  ├── SUCCESS → UserCredential returned
  │   ↓
  │   Update display name in Firebase Auth
  │   ↓
  │   Create complete profile document in Firestore /users/{uid}
  │   Document contains:
  │     • name, email, displayName
  │     • role ("customer")
  │     • phone (empty string)
  │     • photoURL (null for email signup)
  │     • avatarEmoji ("👤")
  │     • isSuspended (false)
  │     • createdAt (server timestamp)
  │     • updatedAt (server timestamp)
  │     • lastLoginTime (server timestamp)
  │   ↓
  │   Return to UI → Navigate to Home
  │
  └── FAILURE → FirebaseAuthException caught
      ↓
      _handleAuthException() maps error codes to human-readable messages:
        • "email-already-in-use" → "An account already exists with this email."
        • "weak-password" → "The password is too weak."
        • "invalid-email" → "The email address is not valid."
        • "operation-not-allowed" → "Operation not allowed. Please contact support."
        • default → "An error occurred. Please try again."
      ↓
      Human-readable error string thrown back to UI
      ↓
      UI shows error in SnackBar (red, floating, with dismiss action)
```

#### Sign-In Flow (Google)

```
User taps "Sign in with Google"
  ↓
AuthService.signInWithGoogle() called
  ↓
ATTEMPT 1: Native Google Sign-In (via Play Services)
  ↓
GoogleSignIn.signIn() → Opens Google account picker overlay
  ├── User selects account → GoogleSignInAccount returned
  │   ↓
  │   Get authentication tokens (accessToken + idToken)
  │   ↓
  │   Create GoogleAuthProvider credential
  │   ↓
  │   Firebase Auth: signInWithCredential(credential)
  │   ├── SUCCESS → UserCredential returned
  │   │   ↓
  │   │   _createOrUpdateUserProfile() called:
  │   │     ↓
  │   │     Check if /users/{uid} document exists in Firestore
  │   │     ├── DOES NOT EXIST (first-time user):
  │   │     │   Create new document with:
  │   │     │   • name from Google profile
  │   │     │   • email from Google
  │   │     │   • photoURL from Google profile picture
  │   │     │   • role = "customer"
  │   │     │   • isSuspended = false
  │   │     │   • timestamps
  │   │     │
  │   │     └── EXISTS (returning user):
  │   │         Update:
  │   │         • lastLoginTime
  │   │         • name (only if currently null/empty/"Unknown")
  │   │         • email (only if null/empty)
  │   │         • photoURL (if changed from last login)
  │   │
  │   │   ↓
  │   │   Return to UI → Navigate to Home
  │   │
  │   └── FAILURE → Falls through to provider-based flow
  │
  ├── User cancels → googleUser is null
  │   ↓
  │   ATTEMPT 2: Provider-based Google Sign-In
  │   ↓
  │   Create GoogleAuthProvider with scopes (email, profile)
  │   Set custom parameter: prompt = "select_account"
  │   ↓
  │   Firebase Auth: signInWithProvider()
  │   ├── SUCCESS → Same profile creation flow
  │   └── FAILURE → Error thrown
  │
  └── ERROR (Play Services missing, misconfiguration):
      ↓
      Error string analyzed for known patterns:
      ├── Contains "DEVELOPER_ERROR" or "Unknown calling package":
      │   → Throw detailed actionable message:
      │   "SHA-1/SHA-256 fingerprints not configured in Firebase,
      │    re-download google-services.json, rebuild"
      │
      └── Any other error:
          → Throw generic "Google Sign-In failed: {error}"
      ↓
      UI catches and shows error in SnackBar
```

#### Suspension Check Guards

```
User successfully authenticated → RoleBasedHome loads
  ↓
SuspensionGuard widget wraps the entire customer interface
  ↓
On every build, SuspensionGuard checks:
  1. Is user logged in? (FirebaseAuth.currentUser != null)
  2. Fetch /users/{uid} document from Firestore
  3. Read 'isSuspended' field
     ├── FALSE → Render child (MainScaffold with all screens)
     └── TRUE → Show suspension screen
         • Red warning UI
         • "Your account has been suspended"
         • Contact support information
         • Logout button only (no access to any features)
```

---

### 🛒 Complete Shopping Journey — From Download to Getting Item

Here's the **full end-to-end journey** of a customer — from opening the app for the first time to walking out of the store with their items:

```
╔══════════════════════════════════════════════════════════════════════╗
║                  COMPLETE USER JOURNEY                               ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  PHASE 1: ONBOARDING (First Time Only)                               ║
║  ─────────────────────────────────────                               ║
║  • User downloads app from Play Store                                ║
║  • Installs and opens → splash screen shows                          ║
║  • SharedPreferences checked: "onboarding_completed" = false         ║
║  • Onboarding slides shown (app features, how it works)              ║
║  • User completes onboarding → flag saved as true                    ║
║  • Never shown again on this device                                  ║
║                                                                      ║
║  PHASE 2: AUTHENTICATION                                             ║
║  ─────────────────────────────                                       ║
║  • LoginScreen presented                                             ║
║  • User chooses: Email/Password OR Google Sign-In                    ║
║  • Firebase Auth creates/validates credentials                       ║
║  • Firestore user profile document created/updated                   ║
║  • Auth state stream fires → UI transitions to HomeScreen            ║
║  • AppStateProvider loads all user data in parallel:                  ║
║    - Products (paginated, 20 at a time)                              ║
║    - Orders (real-time listener, filtered by userId)                  ║
║    - Profile (real-time listener)                                    ║
║    - Payment methods (real-time listener)                             ║
║    - Addresses (real-time listener)                                   ║
║    - Theme preference                                                 ║
║                                                                      ║
║  PHASE 3: BROWSING & DISCOVERY                                       ║
║  ──────────────────────────────                                      ║
║  • HomeScreen shows: Quick stats, recent orders, quick actions        ║
║  • User navigates to Store tab (bottom nav)                           ║
║  • Product grid loads with shimmer skeleton while fetching            ║
║  • Products arrive from Firestore → shimmer replaced with cards       ║
║  • User can:                                                         ║
║    a) Scroll infinite list (auto-loads next 20 when near bottom)      ║
║    b) Search by text (filters client-side across name/brand/category) ║
║    c) Search by voice (microphone button → speech_to_text)            ║
║    d) Filter by category chips (horizontal scroll at top)             ║
║    e) Scan barcode (FAB button → camera opens)                        ║
║  • Barcode scan flow:                                                 ║
║    - Camera opens via mobile_scanner                                  ║
║    - Barcode detected → raw value extracted                           ║
║    - searchProductByBarcode(rawValue) called on provider              ║
║    - Product found → detail sheet shown                               ║
║    - Product NOT found → "Product not found" feedback                 ║
║                                                                       ║
║  PHASE 4: ADDING TO CART                                              ║
║  ────────────────────────────                                         ║
║  • User taps "Add" on product card or detail sheet                    ║
║  • AppStateProvider.addToCart(product) called                         ║
║  • Validation checks (detailed in Cart Backend section below):        ║
║    ├── Product already in cart?                                       ║
║    │   ├── YES → Check if quantity < stockQuantity                    ║
║    │   │   ├── CAN ADD → Increment quantity by 1                      ║
║    │   │   │   → Haptic feedback (medium impact vibration)            ║
║    │   │   │   → Green snackbar: "Product quantity increased"         ║
║    │   │   └── CANNOT → Orange warning snackbar: "Max stock reached"  ║
║    │   └── NO → New item in cart                                      ║
║    │       ├── stockQuantity > 0?                                     ║
║    │       │   ├── YES → CartItem created with quantity = 1            ║
║    │       │   │   → Haptic feedback                                   ║
║    │       │   │   → Analytics: trackAddToCart event logged             ║
║    │       │   │   → Green snackbar: "Product added to cart"            ║
║    │       │   └── NO → Red error snackbar: "Product is out of stock"  ║
║  • notifyListeners() → Cart badge on navbar updates instantly          ║
║  • Cart total recalculated (sum of price × quantity for all items)     ║
║                                                                      ║
║  PHASE 5: CART REVIEW                                                 ║
║  ────────────────────────                                             ║
║  • User navigates to Cart tab                                         ║
║  • Cart screen shows all items with:                                  ║
║    - Product emoji, name, brand                                       ║
║    - Unit price and line total                                         ║
║    - Quantity +/- buttons with stock validation                        ║
║    - Remove button                                                     ║
║    - Stock status indicator per item                                   ║
║  • Bottom section shows: Subtotal, estimated total                    ║
║  • "Proceed to Checkout" button enabled only if cart not empty         ║
║                                                                      ║
║  PHASE 6: CHECKOUT & PAYMENT                                          ║
║  ────────────────────────────                                         ║
║  • User taps "Proceed to Checkout"                                    ║
║  • Payment selection screen presented:                                ║
║    - UPI Payment (Google Pay, PhonePe, Paytm, Amazon Pay)             ║
║    - Cash on Delivery (COD)                                            ║
║  •                                                                    ║
║  • UPI FLOW:                                                          ║
║    1. UPI link generated with: merchant UPI ID, amount,               ║
║       transaction reference, description                              ║
║    2. UPI link launched via url_launcher                               ║
║    3. Android system handles routing to user's UPI app                 ║
║    4. User completes payment in UPI app                                ║
║    5. Control returns to SmartCart                                      ║
║    6. createPaymentRequest() called with paymentMethod = "UPI"         ║
║    7. Payment status set to "Paid"                                     ║
║  •                                                                    ║
║  • COD FLOW:                                                          ║
║    1. createPaymentRequest() called with paymentMethod = "COD"         ║
║    2. Payment status set to "Pending Payment"                          ║
║    3. Exit code generated for counter verification                     ║
║  •                                                                    ║
║  • ORDER PLACEMENT (Both flows converge here):                         ║
║    → See "Order Placement Backend" section for full detail             ║
║                                                                      ║
║  PHASE 7: ORDER CONFIRMATION                                          ║
║  ────────────────────────────                                         ║
║  • Success screen shown with:                                          ║
║    - Order Number (12-character alphanumeric)                          ║
║    - Receipt Number (full UUID)                                        ║
║    - Exit Code (6-character verification code)                         ║
║    - Total amount in ₹                                                 ║
║    - Payment method used                                               ║
║  • Local notification sent: "Order Confirmed"                          ║
║  • Cart is cleared                                                     ║
║  • Order appears in Order History with real-time status                 ║
║                                                                      ║
║  PHASE 8: STORE EXIT                                                   ║
║  ──────────────────────                                                ║
║  • User shows Exit Code at counter                                     ║
║  • Staff verifies code against admin dashboard                         ║
║  • For COD: User pays cash at counter                                  ║
║  • User exits store with items                                         ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

---

### 📦 Order Placement Backend — Every Detail

When the user clicks "Place Order", here's **exactly** what happens on the backend:

```
createPaymentRequest() called with paymentMethod and amount
  ↓
STEP 1: PRE-VALIDATION
  ↓
  Check: Is cart empty?
  ├── YES → Return null immediately (no-op)
  └── NO → Continue
  ↓
  Check: canPlaceOrder() → Iterates every cart item
  For each CartItem:
    ├── item.product.stockQuantity >= item.quantity? → OK, next item
    └── item.product.stockQuantity < item.quantity? → FAIL
        → Exception thrown with detailed message:
          "ProductName: Only X available, you need Y (Z short)"
        → Exception propagated to UI → Red error dialog shown
        → Order ABORTED completely (nothing written to Firestore)
  ↓
STEP 2: DETERMINE PAYMENT STATUS
  ↓
  paymentMethod contains "cod" (case-insensitive)?
  ├── YES → paymentStatus = "Pending Payment"
  └── NO  → paymentStatus = "Paid"
  ↓
STEP 3: GENERATE UNIQUE IDs
  ↓
  UniqueIdService.generateUniqueOrderIds() generates:
  • receiptId → Full UUID (e.g., "550e8400-e29b-41d4-a716-446655440000")
  • orderNumber → 12-character random alphanumeric (e.g., "A7X9K2M4P1Q3")
  • exitCode → 6-character verification code (e.g., "X4K9M2")
  
  Each ID is checked against Firestore to ensure no collisions:
    → Query /orders where orderNumber == generated
    → If exists, regenerate and recheck (loop until unique)
    → This guarantees globally unique order numbers
  ↓
STEP 4: CREATE ORDER OBJECT (In-Memory)
  ↓
  Order {
    id: receiptId
    date: DateTime.now()
    items: deep copy of cart items (quantity + product reference)
    total: cartTotal (sum of price × quantity in paise)
    status: "Pending"
    paymentMethod: "UPI" or "COD"
    paymentStatus: "Paid" or "Pending Payment"
  }
  ↓
STEP 5: WRITE TO FIRESTORE
  ↓
  Document path: /orders/{receiptId}
  Fields written:
    • id, receiptNo, orderNumber, exitCode
    • userId (from FirebaseAuth.currentUser.uid)
    • email (from FirebaseAuth.currentUser.email)
    • date, total, status, paymentMethod, paymentStatus
    • items array — each item contains:
      { productId, productName, quantity, price }
    • createdAt (FieldValue.serverTimestamp())
  
  Exception handling:
    ├── SUCCESS → Continue to stock deduction
    └── FAILURE → Error logged with type and full message
        → Error rethrown → UI shows error dialog
        → Order ABORTED (no stock deducted, cart NOT cleared)
  ↓
STEP 6: STOCK DEDUCTION (Per-Item Transactional)
  ↓
  For EACH item in cart:
    ↓
    Firestore Transaction opened on /products/{productId}
      ↓
      Read current stockQuantity from Firestore
      ↓
      Calculate: newStock = (currentStock - orderQuantity)
      ↓
      Clamp to minimum 0 (never negative): newStock.clamp(0, ∞)
      ↓
      Write back: { stockQuantity: newStock, updatedAt: serverTimestamp }
      ↓
      Transaction committed atomically
      
      WHY TRANSACTION?
      • Prevents race conditions when two users order the same product
      • Guarantees read-then-write is atomic
      • If another write happened between read and write, 
        transaction automatically retries (Firebase handles this)
      • Stock can never go negative due to clamp
    ↓
    Analytics event logged: trackPurchase(productId, name, quantity, totalPrice)
  ↓
STEP 7: LOCAL STATE UPDATE
  ↓
  • Order inserted at index 0 of _orders list (most recent first)
  • Cart cleared (all items removed)
  • notifyListeners() called → All listening widgets rebuild:
    - Cart badge shows 0
    - Cart screen shows "empty" state
    - Order history shows new order at top
  ↓
STEP 8: RETURN ORDER DETAILS
  ↓
  Read back from Firestore the saved order document
  Return Map with: orderNumber, exitCode, receiptNo, total (converted to ₹)
  ↓
  UI receives this → Shows success screen with all details
```

**Exception Cascade for Order Placement**:
```
Exception at any step → What happens:

├── Cart empty → Returns null silently (no error shown)
│
├── User not authenticated → 
│   Exception("You must be signed in to place an order")
│   → UI shows login prompt
│
├── Insufficient stock →
│   Exception("ProductName: Only X available, you need Y (Z short)")
│   → UI shows specific stock error dialog
│   → User can adjust quantities or remove items
│
├── Firestore write fails (network/permission) →
│   Original Firestore error rethrown
│   → UI shows generic error dialog
│   → Cart preserved (nothing lost)
│   → User can retry
│
├── Stock transaction fails →
│   Firebase auto-retries transaction up to 25 times
│   If all retries fail → Error logged + rethrown
│   → ORDER ALREADY WRITTEN but stock not fully deducted
│   → Inventory reconciliation service can fix this later
│
└── Analytics logging fails →
    Error caught silently (non-critical)
    → Logged to Crashlytics for debugging
    → Order still succeeds (analytics is fire-and-forget)
```

---

### 🔄 Real-Time Data Synchronization Model

SmartCart uses **real-time listeners** (Firestore snapshots) for most data, NOT one-time fetches. Here's how each data stream works:

```
╔════════════════════════════════════════════════════════════════════╗
║              REAL-TIME LISTENERS ARCHITECTURE                      ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  LISTENER 1: Orders Stream                                         ║
║  ─────────────────────────                                         ║
║  Collection: /orders                                               ║
║  Filter: userId == currentUser.uid                                  ║
║  Sort: createdAt descending                                         ║
║  Behavior: Every time ANY order for this user changes               ║
║  (new order, status update, deletion) the entire list               ║
║  is re-processed and local _orders list rebuilt                     ║
║  → notifyListeners() → UI rebuilds order history                   ║
║  Error handling: onError callback logs error, UI shows stale data   ║
║                                                                    ║
║  LISTENER 2: User Profile Stream                                    ║
║  ────────────────────────────                                       ║
║  Document: /users/{uid}                                              ║
║  Behavior: Every change to user's profile document                  ║
║  (name, phone, avatar, suspension status) automatically             ║
║  updates local _userProfile object                                  ║
║  → notifyListeners() → Profile screen, nav bar, etc. update         ║
║  Key: If admin suspends user via web dashboard, the profile         ║
║  listener fires immediately → SuspensionGuard kicks in               ║
║                                                                    ║
║  LISTENER 3: Payment Methods Stream                                 ║
║  ──────────────────────────────────                                 ║
║  Collection: /users/{uid}/paymentMethods                             ║
║  Behavior: Real-time sync of saved payment cards/methods            ║
║  → Local list rebuilt on every change                                ║
║                                                                    ║
║  LISTENER 4: Addresses Stream                                       ║
║  ─────────────────────────────                                      ║
║  Collection: /addresses                                              ║
║  Behavior: Real-time sync of saved addresses                        ║
║                                                                    ║
║  ONE-TIME FETCH: Products                                           ║
║  ─────────────────────────────                                      ║
║  Collection: /products                                               ║
║  NOT a real-time listener (too expensive for 1000+ products)        ║
║  Uses pagination: First batch of 20, then loadMore on scroll        ║
║  Refresh available via pull-to-refresh (full re-fetch)              ║
║                                                                    ║
║  ONE-TIME FETCH: Notifications                                      ║
║  ──────────────────────────────                                     ║
║  Collection: /users/{uid}/notifications                              ║
║  Fetched on demand when notification screen opened                  ║
║  Sorted by timestamp descending                                     ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

**Why real-time for orders but not products?**
- Orders: Few per user (10-100), frequently change status, user expects instant updates
- Products: Hundreds/thousands, rarely change, pagination is more efficient than listening to entire collection

---

### ⚠️ Exception Handling Architecture

SmartCart has a **4-layer exception handling strategy**:

```
╔════════════════════════════════════════════════════════════════════╗
║                  EXCEPTION HANDLING LAYERS                         ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  LAYER 1: ZONE-LEVEL (Global Catch-All)                            ║
║  ──────────────────────────────────────                             ║
║  Scope: Entire application                                         ║
║  Mechanism: runZonedGuarded wraps main()                            ║
║  Catches: Any uncaught async error, timer error, stream error       ║
║  Response: Sends to Crashlytics with fatal=true flag                ║
║  User sees: App may crash, but crash is recorded for debugging      ║
║  Recovery: User restarts app; data integrity maintained              ║
║  (Firestore transactions are atomic, partial writes impossible)     ║
║                                                                    ║
║  LAYER 2: FLUTTER ERROR HANDLER                                     ║
║  ──────────────────────────────                                     ║
║  Scope: Flutter framework errors (layout, rendering, gestures)      ║
║  Mechanism: FlutterError.onError wired to Crashlytics               ║
║  Catches: Overflow errors, null widget errors, assertion failures   ║
║  Response: Error recorded in Crashlytics with full details           ║
║  User sees: Debug mode shows red error screen; release shows blank   ║
║  Recovery: Error boundary catches and shows fallback UI              ║
║                                                                    ║
║  LAYER 3: SERVICE-LEVEL (Per-Operation)                              ║
║  ──────────────────────────────────────                              ║
║  Scope: Each Firebase operation, each service method                 ║
║  Mechanism: try/catch in every async method                          ║
║  Response varies by error type:                                      ║
║                                                                    ║
║  ┌─────────────────────────┬──────────────────────────────────────┐ ║
║  │ Error Type              │ Response                              │ ║
║  ├─────────────────────────┼──────────────────────────────────────┤ ║
║  │ FirebaseAuthException   │ Mapped to human-readable message     │ ║
║  │                         │ via _handleAuthException()           │ ║
║  │                         │ (7 specific codes handled)           │ ║
║  ├─────────────────────────┼──────────────────────────────────────┤ ║
║  │ Permission Denied       │ FirestoreErrorHandler checks if      │ ║
║  │                         │ user is signed in; if not, redirects │ ║
║  │                         │ to login; if yes, shows "no access"  │ ║
║  ├─────────────────────────┼──────────────────────────────────────┤ ║
║  │ Network Error           │ "Check your connection" message      │ ║
║  │                         │ Offline cache serves stale data      │ ║
║  ├─────────────────────────┼──────────────────────────────────────┤ ║
║  │ Not Found               │ "Requested data not found" message   │ ║
║  ├─────────────────────────┼──────────────────────────────────────┤ ║
║  │ Already Exists           │ "This item already exists" message  │ ║
║  ├─────────────────────────┼──────────────────────────────────────┤ ║
║  │ Invalid Data            │ "Invalid data, check your input"    │ ║
║  ├─────────────────────────┼──────────────────────────────────────┤ ║
║  │ DEVELOPER_ERROR (OAuth) │ Detailed SHA fingerprint guidance    │ ║
║  ├─────────────────────────┼──────────────────────────────────────┤ ║
║  │ Unknown/Default         │ "An error occurred. Try again."     │ ║
║  └─────────────────────────┴──────────────────────────────────────┘ ║
║                                                                    ║
║  LAYER 4: UI-LEVEL (User Feedback)                                  ║
║  ─────────────────────────────────                                  ║
║  Scope: Visual feedback to user                                     ║
║  Mechanism: FirestoreErrorHandler.showError() and                   ║
║             FeedbackHelper (success/warning/error snackbars)        ║
║  Elements:                                                          ║
║  • Error icon (red) + message in floating SnackBar                  ║
║  • Success icon (green) for confirmations                           ║
║  • Warning icon (orange) for stock limits, budget alerts            ║
║  • Auto-dismiss after 2-4 seconds with manual dismiss option        ║
║  • context.mounted check before showing (prevents "context          ║
║    no longer valid" crashes when user navigated away)                ║
║                                                                    ║
║  LAYER 4B: ANALYTICS-LEVEL (Silent Recording)                       ║
║  ─────────────────────────────────────────────                      ║
║  Many errors are ALSO silently logged to analytics:                  ║
║  • _analytics?.logError() with error code and parameters             ║
║  • recordError() sent to Crashlytics for crash-free metrics          ║
║  • Custom keys set for filtering (error_code, context)               ║
║  • This happens IN ADDITION to user-facing feedback                  ║
║  • Analytics errors themselves are caught silently                   ║
║    (analytics should never cause app failure)                        ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

**The "handleAsync" Wrapper Pattern**:

The FirestoreErrorHandler provides a universal wrapper for any async operation:

```
Operation wrapped in handleAsync():
  ↓
  Show loading indicator (optional)
  ↓
  Execute the async operation
  ├── SUCCESS:
  │   Show success SnackBar (green, optional message)
  │   Return result to caller
  │
  └── FAILURE:
      Check: redirectOnAuth == true AND error is auth-related?
      ├── YES → Navigator.pushReplacementNamed('/login')
      │         (forces re-authentication)
      └── NO  → showError() with user-friendly message
      Return null to caller
```

---

### 🏪 Inventory Management — Behind the Scenes

```
╔════════════════════════════════════════════════════════════════════╗
║                INVENTORY LIFECYCLE                                  ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  STOCK STATUS DETERMINATION                                        ║
║  ──────────────────────────────                                    ║
║  For any product, InventoryService classifies stock:                ║
║                                                                    ║
║  stockQuantity = 0     → 🔴 OUT OF STOCK (isEmpty = true)         ║
║  stockQuantity < 5     → 🟠 CRITICAL (isCritical = true)          ║
║  stockQuantity < 10    → 🟡 LOW STOCK (isLowStock = true)         ║
║  stockQuantity >= 10   → 🟢 GOOD (all false)                      ║
║                                                                    ║
║  LOW STOCK ALERT WORKFLOW                                           ║
║  ──────────────────────────                                        ║
║  When stock drops below threshold (after order placement):          ║
║    ↓                                                                ║
║  notifyLowStock() called with productId, name, currentStock        ║
║    ↓                                                                ║
║  Check: Is stock actually low? (< 10)                               ║
║  ├── NO → Return (no alert needed)                                  ║
║  └── YES → Create alert document in /inventory_alerts               ║
║      Document contains:                                             ║
║      • Alert ID: ALERT_{timestamp}                                  ║
║      • productId, productName                                       ║
║      • currentStock, threshold (10)                                  ║
║      • severity: "CRITICAL" (< 5) or "WARNING" (< 10)              ║
║      • status emoji                                                  ║
║      • createdAt (server timestamp)                                  ║
║      • resolved: false                                               ║
║    ↓                                                                ║
║  Admin sees alert in web dashboard → Can take action                ║
║  Admin resolves alert → resolved: true, resolvedAt, note            ║
║                                                                    ║
║  STOCK TRANSACTION AUDIT TRAIL                                      ║
║  ──────────────────────────────                                     ║
║  Every stock change is logged in /stock_history:                    ║
║  • Document ID: HIST_{timestamp}                                    ║
║  • productId, productName                                           ║
║  • quantityChange: +10 (restock) or -3 (order)                     ║
║  • reason: "Customer Order", "Inventory Recalculation", "Restock"  ║
║  • timestamp (server)                                               ║
║                                                                    ║
║  INVENTORY RECONCILIATION                                           ║
║  ─────────────────────────                                          ║
║  Periodic job (triggered by admin) that verifies data integrity:    ║
║    ↓                                                                ║
║  1. Fetch ALL products from /products                               ║
║  2. For each product:                                               ║
║     a. Query ALL orders containing that productId                   ║
║     b. Sum total quantity sold across all orders                     ║
║     c. Calculate expected stock = initial_stock - total_sold        ║
║     d. Compare expected vs actual (current stockQuantity)           ║
║     e. If mismatch (discrepancy):                                   ║
║        → Log the discrepancy                                        ║
║        → Fix stock to expected value                                 ║
║        → Record correction in stock_history                          ║
║  3. All fixes batched into single Firestore batch write              ║
║  4. Return results: scanned, discrepancies, fixed, errors           ║
║                                                                    ║
║  RECOMMENDED PRODUCTS ENGINE                                        ║
║  ──────────────────────────────                                     ║
║  When cart has items:                                                ║
║    → Get unique categories from cart items                           ║
║    → Query products in same categories (limit 20)                   ║
║    → Filter out: already in cart, out of stock                      ║
║    → Return first 6 as recommendations                              ║
║  When cart is empty:                                                 ║
║    → Return 6 in-stock products (popularity-based future)           ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

### 🔔 Notification System — Complete Flow

```
╔════════════════════════════════════════════════════════════════════╗
║              NOTIFICATION ARCHITECTURE                              ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  INITIALIZATION (App Start)                                         ║
║  ────────────────────────────                                       ║
║  NotificationService is a SINGLETON (factory constructor)           ║
║    ↓                                                                ║
║  1. Request permission from user (alert, badge, sound)              ║
║     Response logged: authorized / denied / provisional              ║
║  2. Get FCM token from Firebase Messaging                           ║
║     Token logged for debugging                                      ║
║  3. Initialize local notifications plugin                           ║
║     Create Android notification channel: "smartcart_channel"        ║
║     Set importance: MAX, priority: HIGH                             ║
║  4. Register foreground message handler                              ║
║  5. Register background message tap handler                         ║
║                                                                    ║
║  MESSAGE TYPES AND HANDLING                                         ║
║  ──────────────────────────────                                     ║
║                                                                    ║
║  ┌──────────────┬──────────────────────────────────────────────┐   ║
║  │ App State    │ What Happens When Message Arrives             │   ║
║  ├──────────────┼──────────────────────────────────────────────┤   ║
║  │ FOREGROUND   │ onMessage listener fires                      │   ║
║  │              │ → _showLocalNotification() called              │   ║
║  │              │ → Creates local notification via plugin       │   ║
║  │              │ → User sees banner at top of screen            │   ║
║  ├──────────────┼──────────────────────────────────────────────┤   ║
║  │ BACKGROUND   │ FCM handles display automatically             │   ║
║  │              │ → System notification tray shows message       │   ║
║  │              │ → User taps → onMessageOpenedApp fires        │   ║
║  │              │ → _handleNotificationTap() processes payload   │   ║
║  ├──────────────┼──────────────────────────────────────────────┤   ║
║  │ TERMINATED   │ FCM handles display automatically             │   ║
║  │              │ → User taps → App launches                     │   ║
║  │              │ → Initial message checked on startup           │   ║
║  └──────────────┴──────────────────────────────────────────────┘   ║
║                                                                    ║
║  NOTIFICATION PAYLOAD ROUTING                                       ║
║  ──────────────────────────────                                     ║
║  When user taps notification, payload 'type' field determines       ║
║  navigation:                                                        ║
║  • type = "order_confirmed" → Navigate to Orders screen             ║
║  • type = "order_shipped" → Navigate to Orders with tracking        ║
║  • type = "stock_alert" → Navigate to Admin dashboard               ║
║  • no type → Default behavior (open app to last screen)             ║
║                                                                    ║
║  ADMIN BROADCAST NOTIFICATIONS (Web Dashboard)                      ║
║  ──────────────────────────────────────────────                     ║
║  Admin types message in "Notify" tab on web dashboard               ║
║    ↓                                                                ║
║  Message written to /users/{uid}/notifications for ALL users        ║
║    ↓                                                                ║
║  Each notification document contains:                               ║
║  • title, body, timestamp, read: false                               ║
║    ↓                                                                ║
║  Mobile app: loadNotifications() fetches from Firestore              ║
║  Unread count computed: filter where read == false                   ║
║  Badge shown on notification bell icon                               ║
║    ↓                                                                ║
║  User opens notification → markNotificationRead(id)                  ║
║  OR "Mark All Read" → batch update all unread to read: true          ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

### 📊 Analytics & Crash Reporting — How Data Flows

```
╔════════════════════════════════════════════════════════════════════╗
║              ANALYTICS DATA PIPELINE                                ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  DUAL TRACKING STRATEGY                                             ║
║  ────────────────────────                                           ║
║  SmartCart tracks analytics in TWO places simultaneously:            ║
║                                                                    ║
║  1. Firebase Analytics (Google's analytics platform)                 ║
║     • Pre-built events: app_open, login, sign_up, screen_view      ║
║     • Custom events: add_to_cart, purchase, product_view            ║
║     • User properties: userId, role                                  ║
║     • Automatic: session duration, device info, crashes              ║
║     → Data viewable in Firebase Console → Analytics dashboard       ║
║                                                                    ║
║  2. Firestore Collections (Custom analytics store)                   ║
║     • /analytics/products/views → product view tracking              ║
║     • /analytics/orders/daily → daily order aggregates               ║
║     • Product document: viewCount, purchaseCount incremented         ║
║     → Data queried by web dashboard for custom charts                ║
║     → Enables real-time analytics (Chart.js on web)                  ║
║                                                                    ║
║  WHAT'S TRACKED (Every event and where it goes)                     ║
║  ──────────────────────────────────────────────                     ║
║                                                                    ║
║  ┌────────────────────┬─────────────┬────────────┐                 ║
║  │ Event              │ Firebase    │ Firestore   │                 ║
║  │                    │ Analytics   │ Custom      │                 ║
║  ├────────────────────┼─────────────┼────────────┤                 ║
║  │ App Open           │ ✅ auto     │ ❌          │                 ║
║  │ Login              │ ✅ method   │ ❌          │                 ║
║  │ Sign Up            │ ✅ method   │ ❌          │                 ║
║  │ Screen View        │ ✅ name     │ ❌          │                 ║
║  │ Product View       │ ✅ id,name  │ ✅ viewCount│                 ║
║  │ Add to Cart        │ ✅ id,name  │ ❌          │                 ║
║  │ Remove from Cart   │ ✅ id       │ ❌          │                 ║
║  │ Purchase           │ ✅ all      │ ✅ counter  │                 ║
║  │ Checkout Start     │ ✅          │ ❌          │                 ║
║  │ Search             │ ✅ query    │ ❌          │                 ║
║  │ Favorite Toggle    │ ✅ id       │ ❌          │                 ║
║  │ Share Product      │ ✅ id       │ ❌          │                 ║
║  │ Budget Set         │ ✅ amount   │ ❌          │                 ║
║  │ Theme Change       │ ✅ mode     │ ❌          │                 ║
║  │ Error              │ ❌          │ ❌ (Crash.) │                 ║
║  └────────────────────┴─────────────┴────────────┘                 ║
║                                                                    ║
║  CRASHLYTICS INTEGRATION                                            ║
║  ────────────────────────                                           ║
║  Enabled in release mode only (disabled in debug to avoid noise)    ║
║                                                                    ║
║  Error recording hierarchy:                                          ║
║  • Fatal errors → FlutterError.onError → recordFlutterFatalError    ║
║  • Zone errors → runZonedGuarded → recordError(fatal: true)          ║
║  • Service errors → recordError(fatal: false) + custom keys         ║
║  • Non-fatal logs → _crashlytics.log(message)                        ║
║                                                                    ║
║  Custom keys attached to errors:                                     ║
║  • error_code: "REFRESH_PRODUCTS_ERROR", "AUTH_FAILED", etc.        ║
║  • user_id: Current user's UID                                       ║
║  • Any additional context parameters                                 ║
║                                                                    ║
║  PERFORMANCE MONITORING                                              ║
║  ────────────────────────                                           ║
║  PerformanceMonitor utility tracks operation timing:                 ║
║  • startTimer('loadProducts') → records start time                   ║
║  • stopTimer('loadProducts') → calculates elapsed, logs metric       ║
║  Used for: product loading, search, cart operations                  ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

### 💳 Payment Processing — Backend Mechanics

```
╔════════════════════════════════════════════════════════════════════╗
║                 PAYMENT PROCESSING FLOW                             ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  UPI PAYMENT ARCHITECTURE                                           ║
║  ─────────────────────────                                          ║
║  SmartCart does NOT process payments directly.                       ║
║  It generates a UPI deep link and delegates to the user's           ║
║  installed UPI app (Google Pay, PhonePe, etc.)                      ║
║                                                                    ║
║  UPI Link Structure:                                                 ║
║  upi://pay?pa={merchantId}&pn={name}&am={amount}&cu=INR             ║
║           &tr={transactionRef}&tn={description}                      ║
║                                                                    ║
║  Link Generation Steps:                                              ║
║  1. Dart Uri class constructs the link with scheme "upi"             ║
║  2. All values URI-encoded (special chars handled)                   ║
║  3. Amount formatted to 2 decimal places                             ║
║  4. Transaction reference is unique order ID                         ║
║                                                                    ║
║  Payment App Detection:                                              ║
║  1. canLaunchUrl() checks if ANY UPI app is installed                ║
║  2. If check fails → assumes supported (better UX than blocking)    ║
║  3. All PaymentApp enum values returned (Android routes to right app)║
║                                                                    ║
║  Launch Flow:                                                        ║
║  1. url_launcher opens UPI link in external app mode                 ║
║  2. Android system determines which app handles "upi://" scheme      ║
║  3. If multiple UPI apps → Android shows app chooser                 ║
║  4. User completes payment in chosen app                             ║
║  5. Control returns to SmartCart                                      ║
║                                                                    ║
║  EXCEPTION HANDLING IN PAYMENT:                                      ║
║  1. canLaunchUrl() fails → Assume UPI supported (graceful fallback)  ║
║  2. launchUrl() fails → Error: "Make sure you have a UPI app"        ║
║  3. User cancels in UPI app → No crash, user returns to SmartCart    ║
║  4. Payment declined → User handles in UPI app, retries as needed    ║
║                                                                    ║
║  COD (CASH ON DELIVERY) PAYMENT                                     ║
║  ────────────────────────────                                        ║
║  No external service involved                                        ║
║  1. Order created with paymentStatus = "Pending Payment"             ║
║  2. Exit code generated for verification                              ║
║  3. User pays cash at store counter                                   ║
║  4. Staff verifies exit code on admin dashboard                       ║
║  5. Admin updates order status to "Completed"                         ║
║                                                                    ║
║  PAYMENT REQUEST → ORDER CONVERSION                                  ║
║  ──────────────────────────────────                                  ║
║  Previously, SmartCart had an admin-approval flow:                     ║
║  User creates payment request → Admin approves → Order placed         ║
║                                                                    ║
║  CURRENT FLOW (Simplified):                                          ║
║  User clicks pay → Order placed DIRECTLY (no admin approval)          ║
║  The createPaymentRequest() method now:                               ║
║  1. Determines payment status from method (COD → pending, UPI → paid)║
║  2. Calls placeOrder() directly                                       ║
║  3. Reads back order details from Firestore                           ║
║  4. Returns orderNumber, exitCode, receiptNo, total to UI             ║
║  5. Calls onApproved callback immediately                             ║
║                                                                    ║
║  If any step fails:                                                   ║
║  → onRejected callback called with error reason string                ║
║  → Error rethrown for UI to handle                                    ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

### 🌐 Web Admin Dashboard — Backend Response Handling

```
╔════════════════════════════════════════════════════════════════════╗
║            WEB DASHBOARD BACKEND INTERACTION                        ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  AUTHENTICATION FLOW                                                ║
║  ────────────────────                                               ║
║  1. Page loads → Firebase v8 SDK initialized                         ║
║  2. onAuthStateChanged listener set up                               ║
║  3. Login form shown                                                 ║
║  4. Admin enters email/password → signInWithEmailAndPassword()       ║
║  5. On success: Check if email is in admin whitelist                 ║
║     Whitelist (hardcoded): [                                         ║
║       "admin1@example.com",                                          ║
║       "admin@smartcart.com",                                         ║
║       "en24309314@git.india.edu.in"                                  ║
║     ]                                                                ║
║     ├── IN LIST → Show dashboard, hide login overlay                 ║
║     │   Also check user role in Firestore /users/{uid}               ║
║     │   If role != "admin" → Update to "admin" automatically         ║
║     └── NOT IN LIST → Sign out immediately                           ║
║         → Show error: "only whitelisted admins can access"           ║
║                                                                    ║
║  PRODUCTS TAB — CRUD OPERATIONS                                     ║
║  ────────────────────────────────                                    ║
║                                                                    ║
║  CREATE PRODUCT:                                                     ║
║  1. Admin fills form: name, category, brand, price, stock, emoji     ║
║  2. Validation: All required fields filled, price > 0, stock >= 0    ║
║  3. Document created in /products with auto-generated ID              ║
║  4. Fields: name, category, brand, description, price (in paise),    ║
║     stockQuantity, imageEmoji, barcode, createdAt, updatedAt         ║
║  5. Success → Toast notification, form cleared, list refreshed       ║
║  6. Failure → Alert with error message                               ║
║                                                                    ║
║  UPDATE PRODUCT:                                                     ║
║  1. Admin clicks edit icon on product row                             ║
║  2. Current values loaded into edit form                               ║
║  3. Admin modifies fields and submits                                  ║
║  4. Firestore .update() called on /products/{id}                      ║
║  5. Only changed fields + updatedAt written                           ║
║  6. Mobile app reflects changes on next refresh (not real-time)       ║
║                                                                    ║
║  DELETE PRODUCT:                                                     ║
║  1. Admin clicks delete icon → confirmation prompt                    ║
║  2. Firestore .delete() called on /products/{id}                      ║
║  3. Product removed from mobile app on next refresh                   ║
║  4. Existing orders referencing this product are NOT affected          ║
║     (order stores productName snapshot, not reference)                ║
║                                                                    ║
║  BULK CSV IMPORT:                                                    ║
║  1. Admin uploads CSV file via file picker                            ║
║  2. JavaScript FileReader parses CSV                                  ║
║  3. Each row validated: required fields, numeric price/stock          ║
║  4. Duplicate check: query /products where name == row.name           ║
║     ├── DUPLICATE → Skip with warning                                ║
║     └── UNIQUE → Create document                                     ║
║  5. Progress tracked: success count, skip count, fail count           ║
║  6. Final report shown to admin                                       ║
║                                                                    ║
║  ORDERS TAB — STATUS MANAGEMENT                                     ║
║  ────────────────────────────────                                    ║
║  1. All orders fetched from /orders, sorted by createdAt desc        ║
║  2. Each order shows: order number, user email, items, total, status ║
║  3. Admin can change status: Pending → Processing → Shipped → Done  ║
║  4. Status change: Firestore .update() on /orders/{id}               ║
║  5. Mobile app listener fires → user sees updated status instantly   ║
║                                                                    ║
║  USERS TAB — ACCOUNT MANAGEMENT                                     ║
║  ────────────────────────────────                                    ║
║  1. All users fetched from /users collection                          ║
║  2. Each user shows: name, email, role, suspension status             ║
║  3. Admin can:                                                        ║
║     a. Change role (customer ↔ admin)                                 ║
║        → Firestore .update() on /users/{uid} with role field          ║
║     b. Suspend account                                                ║
║        → Set isSuspended: true in /users/{uid}                        ║
║        → Mobile app profile listener fires immediately                ║
║        → SuspensionGuard activates → User locked out of all features ║
║     c. Unsuspend account                                              ║
║        → Set isSuspended: false → User regains access instantly       ║
║     d. Delete user (removes Firestore document only)                  ║
║        → Firebase Auth account NOT deleted (requires Admin SDK)       ║
║                                                                    ║
║  ANALYTICS TAB — DATA AGGREGATION                                    ║
║  ────────────────────────────────                                    ║
║  On tab load:                                                         ║
║  1. Fetch all orders → calculate: total revenue, order count          ║
║  2. Fetch all products → calculate: total products, stock stats       ║
║  3. Fetch all users → count: total users, active users                ║
║  4. Group orders by date → revenue per day for line chart             ║
║  5. Group orders by product → top selling items for bar chart         ║
║  6. All calculated client-side (no Cloud Functions needed)            ║
║  7. Charts rendered with Chart.js (line, bar, doughnut)               ║
║                                                                    ║
║  NOTIFICATIONS TAB — BROADCAST MECHANISM                             ║
║  ────────────────────────────────────────                            ║
║  1. Admin types title + message body                                  ║
║  2. "Send to All" clicked                                             ║
║  3. Fetch ALL user documents from /users                              ║
║  4. For EACH user:                                                    ║
║     → Create document in /users/{uid}/notifications                   ║
║     → Fields: title, body, timestamp, read: false                     ║
║  5. This is a fan-out write (N documents for N users)                 ║
║  6. Mobile app fetches notifications on screen open                   ║
║  7. Each user sees the broadcast in their notification list           ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

### 🔄 State Management — Provider Pattern in Detail

```
╔════════════════════════════════════════════════════════════════════╗
║              STATE MANAGEMENT ARCHITECTURE                          ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  AppStateProvider is a SINGLE ChangeNotifier that manages:          ║
║                                                                    ║
║  ┌──────────────────────────────────────────────────────────┐      ║
║  │ STATE PROPERTIES (all private with public getters)        │      ║
║  ├──────────────────────────────────────────────────────────┤      ║
║  │ _isDarkMode          │ bool    │ Theme preference         │      ║
║  │ _notifications       │ List    │ In-app notifications     │      ║
║  │ _isLoadingProducts   │ bool    │ Loading spinner flag      │      ║
║  │ _products            │ List    │ Product catalog           │      ║
║  │ _hasMoreProducts     │ bool    │ Pagination flag           │      ║
║  │ _lastProductDoc      │ Doc?    │ Pagination cursor         │      ║
║  │ _selectedCategory    │ String  │ Current filter            │      ║
║  │ _searchQuery         │ String  │ Current search text       │      ║
║  │ _userProfile         │ Object  │ Current user's profile    │      ║
║  │ _cart                │ List    │ Shopping cart items        │      ║
║  │ _orders              │ List    │ Order history             │      ║
║  │ _paymentRequests     │ List    │ Payment request history   │      ║
║  │ _paymentMethods      │ List    │ Saved payment methods     │      ║
║  │ _addresses           │ List    │ Saved addresses           │      ║
║  │ _notificationsEnabled│ bool    │ Notification toggle       │      ║
║  └──────────────────────────────────────────────────────────┘      ║
║                                                                    ║
║  DATA FLOW PATTERN                                                  ║
║  ─────────────────                                                  ║
║                                                                    ║
║  User Tap → Widget calls Provider method                            ║
║    ↓                                                                ║
║  Provider validates input (stock check, auth check, etc.)           ║
║    ↓                                                                ║
║  Provider updates internal state (local)                             ║
║    ↓                                                                ║
║  Provider writes to Firestore (remote) — in parallel or after       ║
║    ↓                                                                ║
║  Provider calls notifyListeners()                                    ║
║    ↓                                                                ║
║  All Consumer<AppStateProvider> widgets rebuild                      ║
║  (only the ones watching changed properties actually re-render)      ║
║                                                                    ║
║  WIDGET ACCESS PATTERNS                                              ║
║  ─────────────────────                                               ║
║                                                                    ║
║  context.read<AppStateProvider>()                                    ║
║    → One-time read, no subscription                                  ║
║    → Used in: button callbacks, init methods                         ║
║    → Does NOT cause rebuilds                                         ║
║                                                                    ║
║  context.watch<AppStateProvider>()                                   ║
║    → Subscribes to ALL changes                                       ║
║    → Widget rebuilds on ANY notifyListeners()                        ║
║    → Used in: build methods that need reactive data                  ║
║    → CAUTION: Can cause excessive rebuilds                          ║
║                                                                    ║
║  Consumer<AppStateProvider>(builder: ...)                             ║
║    → Subscribes but limits rebuild scope                             ║
║    → Only the Consumer's child rebuilds, not parent                  ║
║    → Used in: Cart badge, product count, specific data displays      ║
║    → PREFERRED for performance-sensitive areas                       ║
║                                                                    ║
║  DEPENDENCY INJECTION                                                ║
║  ─────────────────────                                               ║
║  AppStateProvider accepts optional constructor parameters:            ║
║  • AuthService (injectable for testing with mocks)                   ║
║  • AnalyticsService (injectable, nullable)                           ║
║  • InventoryService (injectable for testing)                         ║
║  Default implementations used if not provided                        ║
║                                                                    ║
║  DISPOSE & CLEANUP                                                   ║
║  ─────────────────                                                   ║
║  On provider disposal:                                               ║
║  • _paymentRequestSubscription cancelled (StreamSubscription)        ║
║  • Real-time Firestore listeners auto-cancelled by Provider          ║
║  • super.dispose() called                                            ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

### 📱 Navigation Architecture

```
╔════════════════════════════════════════════════════════════════════╗
║                  NAVIGATION SYSTEM                                  ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  SCREEN HIERARCHY                                                   ║
║  ─────────────────                                                  ║
║                                                                    ║
║  SmartCartApp (MaterialApp)                                          ║
║  ├── OnboardingScreen (shown once)                                   ║
║  ├── LoginScreen                                                     ║
║  │   ├── SignUpScreen                                                ║
║  │   └── ForgotPasswordScreen                                       ║
║  └── RoleBasedHome                                                   ║
║      └── SuspensionGuard                                             ║
║          └── MainScaffold (with BottomAppBar)                        ║
║              ├── Tab 0: HomeScreen                                   ║
║              │   ├── Quick Stats Cards                               ║
║              │   ├── Recent Orders                                    ║
║              │   └── Quick Actions                                    ║
║              ├── Tab 1: StoreScreen                                   ║
║              │   ├── Search Bar (text + voice)                        ║
║              │   ├── Category Chips                                   ║
║              │   ├── Product Grid (paginated)                         ║
║              │   └── ProductDetailSheet (bottom sheet)                ║
║              ├── FAB: BarcodeScannerScreen (camera overlay)           ║
║              ├── Tab 2: CartScreen                                    ║
║              │   ├── Cart Items List                                  ║
║              │   ├── Cart Summary                                     ║
║              │   └── PaymentSelectionScreen                           ║
║              │       ├── PaymentMethodsScreen                         ║
║              │       └── PaymentSuccessScreen                         ║
║              └── Tab 3: ProfileScreen                                 ║
║                  ├── EditProfileScreen                                ║
║                  ├── OrderHistoryScreen                               ║
║                  │   └── Order Detail                                 ║
║                  ├── SpendingAnalyticsScreen                          ║
║                  ├── BudgetSettingsScreen                             ║
║                  ├── NotificationsScreen                              ║
║                  ├── FeedbackScreen                                   ║
║                  ├── ReportBugScreen                                  ║
║                  ├── SettingsScreen                                   ║
║                  └── DiagnosticsScreen                                ║
║                                                                    ║
║  NAVIGATION TRANSITIONS                                              ║
║  ─────────────────────                                               ║
║  • Tab switching: IndexedStack (keeps all tabs alive in memory)      ║
║    → Instant switching, no rebuild, state preserved                   ║
║  • Named routes: Slide transition from right (custom PageRouteBuilder)║
║  • Material routes: Default platform transitions                      ║
║    → Android: Zoom transition                                         ║
║    → iOS: Cupertino slide                                             ║
║  • Barcode scanner: Standard push (full-screen camera)               ║
║  • Shake to report: Direct push to ReportBugScreen via navigatorKey  ║
║    → Uses global navigator key (works from ANY context)               ║
║    → ShakeListener has built-in debounce (prevents spam)              ║
║                                                                    ║
║  AUTH-BASED ROUTING                                                  ║
║  ──────────────────                                                  ║
║  StreamBuilder on authStateChanges determines initial route:          ║
║  • Signed in → Home (with cached user check for instant load)        ║
║  • Not signed in → Login                                              ║
║  • On sign out → Navigator.pushReplacementNamed('/login')             ║
║    → Replaces entire stack (can't go "back" to protected screens)    ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

### 🗄️ Firestore Database Schema — Complete Document Structure

```
╔════════════════════════════════════════════════════════════════════╗
║                  DATABASE SCHEMA                                    ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  /products/{productId}                                               ║
║  ──────────────────────                                              ║
║  • name: string (required)                                           ║
║  • category: string (e.g., "dairy", "snacks", "beverages")          ║
║  • brand: string                                                     ║
║  • description: string                                               ║
║  • price: number (stored in PAISE, e.g., 6500 = ₹65.00)            ║
║  • stockQuantity: number (current available stock)                   ║
║  • imageEmoji: string (e.g., "🥛", "🍕")                            ║
║  • barcode: string (optional, for scanner lookup)                    ║
║  • viewCount: number (incremented on product view)                   ║
║  • purchaseCount: number (incremented on purchase)                   ║
║  • createdAt: timestamp (server)                                     ║
║  • updatedAt: timestamp (server)                                     ║
║                                                                    ║
║  /users/{userId}                                                     ║
║  ──────────────────                                                  ║
║  • name: string                                                      ║
║  • displayName: string                                               ║
║  • email: string                                                     ║
║  • phone: string                                                     ║
║  • photoURL: string (Google profile picture, null for email signup)  ║
║  • avatarEmoji: string (default "👤")                                ║
║  • role: string ("customer" or "admin")                              ║
║  • isSuspended: boolean (default false)                               ║
║  • createdAt: timestamp                                               ║
║  • updatedAt: timestamp                                               ║
║  • lastLoginTime: timestamp                                           ║
║    └── /notifications/{notificationId}                                ║
║        • title: string                                                ║
║        • body: string                                                 ║
║        • timestamp: timestamp                                         ║
║        • read: boolean                                                ║
║    └── /paymentMethods/{methodId}                                     ║
║        • cardNumber: string                                           ║
║        • cardHolder: string                                           ║
║        • expiryDate: string                                           ║
║        • createdAt: timestamp                                         ║
║                                                                    ║
║  /orders/{orderId}                                                   ║
║  ──────────────────                                                  ║
║  • id: string (same as document ID, equals receiptNo)                ║
║  • receiptNo: string (full UUID)                                     ║
║  • orderNumber: string (12-char user-friendly)                       ║
║  • exitCode: string (6-char verification code)                       ║
║  • userId: string (owner's Firebase Auth UID)                        ║
║  • email: string (for email-based order lookup)                      ║
║  • date: timestamp                                                    ║
║  • total: number (in paise)                                           ║
║  • status: string ("Pending" → "Processing" → "Shipped" → "Done")   ║
║  • paymentMethod: string ("UPI" or "COD")                            ║
║  • paymentStatus: string ("Paid" or "Pending Payment")               ║
║  • items: array of objects:                                           ║
║    [{ productId, productName, quantity, price }]                      ║
║  • createdAt: timestamp (server)                                      ║
║                                                                    ║
║  /inventory_alerts/{alertId}                                         ║
║  ──────────────────────────                                          ║
║  • id: string (ALERT_{timestamp})                                    ║
║  • productId: string                                                  ║
║  • productName: string                                                ║
║  • currentStock: number                                               ║
║  • threshold: number (10)                                             ║
║  • severity: string ("CRITICAL" or "WARNING")                         ║
║  • status: string (emoji status)                                      ║
║  • createdAt: timestamp                                               ║
║  • resolved: boolean                                                  ║
║  • resolvedAt: timestamp (when resolved)                              ║
║  • note: string (resolution note)                                     ║
║                                                                    ║
║  /stock_history/{historyId}                                           ║
║  ──────────────────────────                                          ║
║  • id: string (HIST_{timestamp})                                     ║
║  • productId: string                                                  ║
║  • productName: string                                                ║
║  • quantityChange: number (+/-)                                       ║
║  • reason: string                                                     ║
║  • timestamp: timestamp                                               ║
║                                                                    ║
║  /feedbacks/{feedbackId}                                              ║
║  ──────────────────────                                               ║
║  • userId, email, name                                                ║
║  • type: "feedback" or "bug_report"                                   ║
║  • category: string                                                   ║
║  • message: string                                                    ║
║  • rating: number (1-5)                                               ║
║  • deviceInfo: object (model, os, app version)                        ║
║  • timestamp: timestamp                                               ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

### 🔒 Firestore Security Rules — Decision Tree

```
Every Firestore request goes through this decision tree:

REQUEST ARRIVES
  ↓
Is the path /{anything}?
  → Check: Is requester in admin whitelist?
    ├── YES → ALLOW (admins can read/write/delete ANYTHING)
    └── NO → Continue to specific rules
  ↓
Is the path /users/{userId}?
  → Check: Is request.auth.uid == userId?
    ├── YES → ALLOW read/write (users own their data)
    └── NO → DENY
  → Also applies to ALL subcollections (/notifications, /paymentMethods)
  ↓
Is the path /products/{productId}?
  → READ/LIST: Is user signed in? → ALLOW
  → WRITE: Is user signed in AND only updating allowed fields?
    Allowed fields: stockQuantity, purchaseCount, updatedAt
    ├── YES → ALLOW (normal users can update stock after purchase)
    └── NO → DENY (can't change name, price, etc.)
  ↓
Is the path /orders/{orderId}?
  → READ: Is user signed in AND order.userId == request.auth.uid?
    → ALLOW (users can only read their own orders)
  → CREATE: Is user signed in AND request data userId matches auth uid?
    → ALLOW (users can only create orders for themselves)
  → UPDATE: Same ownership check for both old and new data
    → ALLOW (prevents transferring orders to another user)
  ↓
Any other path → Default DENY
```

---

### 🏗️ Service Architecture — How Each Service Responds

```
╔════════════════════════════════════════════════════════════════════╗
║              SERVICE LAYER ARCHITECTURE                             ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  SINGLETON SERVICES (one instance for entire app lifecycle):        ║
║  • AnalyticsService — via factory constructor                       ║
║  • NotificationService — via factory constructor                    ║
║                                                                    ║
║  INJECTED SERVICES (created per AppStateProvider instance):         ║
║  • AuthService — handles all Firebase Auth operations               ║
║  • InventoryService — handles stock management                      ║
║                                                                    ║
║  STATIC SERVICES (no instance needed, all static methods):          ║
║  • PaymentService — UPI link generation, app launching              ║
║  • UniqueIdService — order ID generation                            ║
║  • FirestoreErrorHandler — error classification and display         ║
║                                                                    ║
║  SERVICE RESPONSE PATTERNS:                                         ║
║  ─────────────────────────                                          ║
║                                                                    ║
║  Pattern 1: RETURN OR THROW (AuthService)                           ║
║  • Success → Return data (UserCredential, String role)              ║
║  • Failure → Throw human-readable error string                      ║
║  • Caller wraps in try/catch, shows error to user                   ║
║                                                                    ║
║  Pattern 2: SILENT FAIL (AnalyticsService)                          ║
║  • Success → Event logged, continue                                  ║
║  • Failure → recordError() to Crashlytics, continue                  ║
║  • NEVER throws, NEVER blocks, NEVER shows error to user            ║
║  • Rationale: Analytics should never degrade user experience         ║
║                                                                    ║
║  Pattern 3: LOG AND CONTINUE (InventoryService)                     ║
║  • Success → debugPrint confirmation                                 ║
║  • Failure → debugPrint error, return empty/default                  ║
║  • Non-critical operations that shouldn't block core flows           ║
║                                                                    ║
║  Pattern 4: FIRE AND FORGET (NotificationService)                   ║
║  • Success → Notification shown                                      ║
║  • Failure → Error logged, no retry                                  ║
║  • User may not see notification, but app continues normally         ║
║                                                                    ║
║  Pattern 5: RETHROW (AppStateProvider.placeOrder)                    ║
║  • Success → Order placed, cart cleared                              ║
║  • Failure → Error logged AND rethrown to caller                     ║
║  • UI catches and shows appropriate error dialog                     ║
║  • This is for CRITICAL operations where user must know about failure║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

### 🔄 Product Loading — Pagination Architecture

```
INITIAL LOAD (App startup):
  ↓
loadProductsFromFirestore() called
  ↓
Check: _products.isNotEmpty?
├── YES → Return immediately (already loaded, no redundant fetch)
└── NO → Continue
  ↓
Start performance timer: 'loadProducts'
Set _isLoadingProducts = true → Shimmer skeleton shown
notifyListeners()
  ↓
Query: /products ordered by name, LIMIT 20
  ↓
Response arrives:
  ↓
For each document:
  → Map Firestore fields to Product model
  → Handle nulls with defaults (name: '', category: 'other', emoji: '📦')
  → Price converted: data['price'] → toDouble() → toInt()
  → Stock: data['stockQuantity'] → toInt()
  ↓
Save last document as pagination cursor (_lastProductDoc)
Check: docs.length == 20?
├── YES → _hasMoreProducts = true (there might be more)
└── NO → _hasMoreProducts = false (we got everything)
  ↓
Stop performance timer
Set _isLoadingProducts = false → Shimmer replaced with actual grid
notifyListeners()

LOAD MORE (User scrolls near bottom):
  ↓
loadMoreProducts() called
  ↓
Guard checks:
├── !_hasMoreProducts → Return (nothing more to load)
├── _isLoadingMoreProducts → Return (already loading)
└── _lastProductDoc == null → Return (no cursor)
  ↓
Set _isLoadingMoreProducts = true
notifyListeners()
  ↓
Query: /products ordered by name, START AFTER lastDoc, LIMIT 20
  ↓
New products APPENDED to existing list (not replaced)
Update cursor and hasMore flag
  ↓
Set _isLoadingMoreProducts = false
notifyListeners()

PULL-TO-REFRESH:
  ↓
refreshProducts() called
  ↓
Set _isLoadingProducts = true
  ↓
Query: /products (ALL, no limit, no pagination)
  ↓
REPLACE entire product list (not append)
  ↓
On error: Log to analytics with error code 'REFRESH_PRODUCTS_ERROR'
  ↓
ALWAYS: Set _isLoadingProducts = false (in finally block)
  → Even on error, loading spinner stops
  → User sees stale data or empty state, not infinite spinner
```

---

### 🛡️ Resilience Patterns

**1. Graceful Degradation**
- Firebase fails at startup → App continues with cached data
- Analytics fails → Silently logged, app unaffected
- Network unavailable → Firestore offline cache serves data
- Notification permission denied → App works without notifications

**2. Atomic Operations**
- Stock deduction uses Firestore Transactions (read-modify-write atomic)
- Batch writes for bulk notification marking (all-or-nothing)
- Order creation is single document write (atomic by nature)

**3. Idempotency**
- loadProductsFromFirestore() checks if already loaded before fetching
- Order IDs checked for uniqueness against Firestore before use
- Profile creation checks if document exists before creating

**4. State Consistency**
- Cart operations are synchronous (local state) + async (Firestore)
- If Firestore write fails, local state is already updated → user sees cart change
- On next app open, Firestore is source of truth for orders/profile

**5. Error Boundaries**
- SuspensionGuard wraps entire customer interface
- AuthGuard wraps screens requiring login
- context.mounted checks prevent setState on disposed widgets
- StreamSubscription cancelled in dispose() to prevent memory leaks

---

### 🔍 Search System — Multi-Mode Architecture

```
╔════════════════════════════════════════════════════════════════════╗
║                   SEARCH SYSTEM                                     ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  MODE 1: TEXT SEARCH                                                ║
║  ─────────────────────                                              ║
║  User types in search bar                                           ║
║    ↓                                                                ║
║  onChanged fires on every keystroke                                 ║
║    ↓                                                                ║
║  AppStateProvider.searchQuery setter called                         ║
║    ↓                                                                ║
║  Client-side filtering on ALREADY LOADED products                   ║
║  (Products are NOT re-fetched from Firestore per search)            ║
║    ↓                                                                ║
║  Filter logic checks MULTIPLE fields (case-insensitive):            ║
║  • product.name.toLowerCase().contains(query)                        ║
║  • product.brand.toLowerCase().contains(query)                       ║
║  • product.category.toLowerCase().contains(query)                    ║
║  • product.description.toLowerCase().contains(query)                 ║
║    ↓                                                                ║
║  Matching products returned via filteredProducts getter              ║
║    ↓                                                                ║
║  Grid rebuilds instantly (no network latency)                        ║
║                                                                    ║
║  WHY CLIENT-SIDE?                                                    ║
║  Firestore only supports exact matches and prefix queries.           ║
║  Full-text search across multiple fields requires Algolia or         ║
║  similar. With products < 1000, client-side filtering is faster      ║
║  and simpler.                                                        ║
║                                                                    ║
║  MODE 2: VOICE SEARCH                                                ║
║  ─────────────────────                                               ║
║  User taps microphone icon                                           ║
║    ↓                                                                ║
║  speech_to_text plugin activated                                     ║
║    ↓                                                                ║
║  Listen for speech → Convert to text string                          ║
║    ↓                                                                ║
║  Text injected into search bar                                       ║
║    ↓                                                                ║
║  Same text search flow as above                                      ║
║  Exception handling:                                                 ║
║  • Microphone permission denied → Show permission dialog             ║
║  • No speech detected → Timeout, show "Try again"                    ║
║  • Speech recognition unavailable → Hide mic button                  ║
║                                                                    ║
║  MODE 3: BARCODE SCAN                                                ║
║  ─────────────────────                                               ║
║  User taps FAB (floating action button)                              ║
║    ↓                                                                ║
║  Camera opens via mobile_scanner                                     ║
║    ↓                                                                ║
║  Real-time barcode detection                                         ║
║    ↓                                                                ║
║  Barcode value extracted (string)                                    ║
║    ↓                                                                ║
║  searchProductByBarcode(value) on AppStateProvider                   ║
║    ↓                                                                ║
║  Loops through _products list checking product.barcode == value      ║
║    ├── FOUND → Return Product, UI shows detail sheet                 ║
║    └── NOT FOUND → Return null, UI shows "Product not found"         ║
║                                                                    ║
║  Exception handling:                                                 ║
║  • Camera permission denied → Show guidance                          ║
║  • Camera in use → Show error, suggest closing other apps            ║
║  • Invalid barcode format → Silently ignore, keep scanning           ║
║  • Scanner initialization error → Catch in try-catch, show snackbar  ║
║                                                                    ║
║  MODE 4: CATEGORY FILTER                                             ║
║  ─────────────────────────                                           ║
║  Horizontal chip bar at top of store screen                          ║
║    ↓                                                                ║
║  User taps category chip (e.g., "Dairy", "Snacks")                  ║
║    ↓                                                                ║
║  AppStateProvider.selectedCategory updated                           ║
║    ↓                                                                ║
║  filteredProducts getter applies category filter                     ║
║    ↓                                                                ║
║  "All" chip resets category to empty string (shows everything)       ║
║                                                                    ║
║  COMBINED FILTERING:                                                 ║
║  Search query AND category filter are applied simultaneously:        ║
║  → If category is "Dairy" AND search is "milk"                      ║
║  → Only dairy products containing "milk" shown                      ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

### 🧑‍💼 Admin vs Customer — Role-Based Access Control

```
╔════════════════════════════════════════════════════════════════════╗
║            ROLE-BASED ACCESS CONTROL (RBAC)                         ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  ROLE ASSIGNMENT                                                     ║
║  ─────────────────                                                   ║
║  • Default role on signup: "customer"                                ║
║  • Admin role can ONLY be set by:                                    ║
║    a. Existing admin changing role via web dashboard                  ║
║    b. Direct Firestore edit (for first admin)                        ║
║  • Role stored in: /users/{uid}/role field                           ║
║                                                                    ║
║  ┌────────────────────┬──────────┬──────────┐                      ║
║  │ Feature            │ Customer │ Admin    │                      ║
║  ├────────────────────┼──────────┼──────────┤                      ║
║  │ Browse Products    │ ✅       │ ✅       │                      ║
║  │ Add to Cart        │ ✅       │ ✅       │                      ║
║  │ Place Orders       │ ✅       │ ✅       │                      ║
║  │ View Own Orders    │ ✅       │ ✅       │                      ║
║  │ Edit Own Profile   │ ✅       │ ✅       │                      ║
║  │ Scan Barcodes      │ ✅       │ ✅       │                      ║
║  │ Set Budget         │ ✅       │ ✅       │                      ║
║  │ Submit Feedback    │ ✅       │ ✅       │                      ║
║  │                    │          │          │                      ║
║  │ Web Dashboard      │ ❌       │ ✅       │                      ║
║  │ Manage Products    │ ❌       │ ✅       │                      ║
║  │ View All Orders    │ ❌       │ ✅       │                      ║
║  │ Manage Users       │ ❌       │ ✅       │                      ║
║  │ Suspend Accounts   │ ❌       │ ✅       │                      ║
║  │ Change Roles       │ ❌       │ ✅       │                      ║
║  │ Send Notifications │ ❌       │ ✅       │                      ║
║  │ View Analytics     │ ❌       │ ✅       │                      ║
║  │ Bulk CSV Import    │ ❌       │ ✅       │                      ║
║  │ Inventory Alerts   │ ❌       │ ✅       │                      ║
║  └────────────────────┴──────────┴──────────┘                      ║
║                                                                    ║
║  WEB DASHBOARD ACCESS CONTROL                                       ║
║  ──────────────────────────────                                     ║
║  The web admin dashboard has a DOUBLE-LAYER access check:           ║
║                                                                    ║
║  Layer 1: Email whitelist (hardcoded in admin.html)                  ║
║  • List of approved admin emails checked on login                    ║
║  • If email not in list → Immediate sign-out + error message         ║
║                                                                    ║
║  Layer 2: Firestore role field                                       ║
║  • After whitelist passes, check /users/{uid}/role                   ║
║  • If role != "admin" → Auto-update to "admin"                      ║
║  • This ensures the mobile app also reflects admin status            ║
║                                                                    ║
║  WHY BOTH LAYERS?                                                    ║
║  Whitelist: Quick, client-side, prevents unauthorized login          ║
║  Firestore role: Enforces backend rules even if whitelist bypassed   ║
║  Together: Defense in depth                                          ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

### 📲 Barcode & QR Code System — Detailed Flow

```
╔════════════════════════════════════════════════════════════════════╗
║             BARCODE / QR CODE SYSTEM                                ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  IN-APP BARCODE SCANNER                                             ║
║  ────────────────────────                                           ║
║  Component: mobile_scanner package                                   ║
║  Camera: Back camera (auto-selected)                                 ║
║  Supported formats: EAN-8, EAN-13, UPC-A, UPC-E, Code128,          ║
║                     Code39, Code93, QR Code, DataMatrix, PDF417     ║
║                                                                    ║
║  Scan Flow:                                                         ║
║  1. User taps FAB (centered in bottom nav notch)                    ║
║  2. Camera permission checked                                        ║
║     ├── GRANTED → Camera preview opens full-screen                  ║
║     └── DENIED → Permission rationale shown → request again          ║
║  3. Scanner widget displays live camera feed                        ║
║  4. When barcode detected:                                           ║
║     → Callback fires with BarcodeCapture object                     ║
║     → Extract rawValue from first barcode                            ║
║     → Call provider.searchProductByBarcode(rawValue)                 ║
║     → Stop scanner (prevent duplicate scans)                        ║
║  5. Product lookup:                                                  ║
║     ├── FOUND → Pop scanner → Show product detail bottom sheet      ║
║     │   → User can add to cart from sheet                            ║
║     └── NOT FOUND → Show "Product not found" snackbar               ║
║        → Scanner restarts for next scan attempt                      ║
║                                                                    ║
║  QR CODE GENERATION (generate_qr.dart)                              ║
║  ──────────────────────────────────────                              ║
║  Standalone Dart script for product QR code generation               ║
║  Purpose: Generate printable QR labels for store shelves             ║
║                                                                    ║
║  Flow:                                                               ║
║  1. Script connects to Firestore                                     ║
║  2. Fetches all products from /products collection                  ║
║  3. For each product:                                                ║
║     → Encodes barcode field value into QR code                      ║
║     → Generates image (PNG format)                                   ║
║     → Saves with filename: {productName}_{barcode}.png              ║
║  4. All QR codes saved to output directory                          ║
║  5. Ready for printing on label sheets                              ║
║                                                                    ║
║  EXIT CODE VERIFICATION (QR at checkout)                            ║
║  ──────────────────────────────────────                              ║
║  After order placement:                                              ║
║  1. 6-character exit code generated (alphanumeric)                  ║
║  2. Displayed on success screen as text + QR code                   ║
║  3. At store exit:                                                    ║
║     → Staff scans QR or enters code manually                        ║
║     → Admin dashboard validates code against /orders collection      ║
║     → If valid and matching: Allow exit                               ║
║     → If invalid: Flag customer, request receipt                     ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

### 🎨 Theme System — Dynamic Switching

```
Theme Architecture:
  ↓
AppStateProvider holds _isDarkMode (boolean)
  ↓
On toggle: 
  1. Flip _isDarkMode value
  2. Save to SharedPreferences ('isDarkMode' key)
  3. notifyListeners()
  ↓
SmartCartApp widget uses Consumer<AppStateProvider>
  ↓
MaterialApp themeMode property reads isDarkMode:
  ├── true → ThemeMode.dark → dark theme applied
  └── false → ThemeMode.light → light theme applied
  ↓
Both themes defined in AppTheme class:
  • lightTheme: Material 3, blue seed color, light surfaces
  • darkTheme: Material 3, blue seed color, dark surfaces
  ↓
Theme persists across app restarts (SharedPreferences)
Theme loads on provider construction BEFORE first build
  → No flash of wrong theme on startup
```

---

### 📃 Receipt & PDF Generation

```
Order Confirmation → PDF Receipt Flow:
  ↓
User taps "Download Receipt" on order detail screen
  ↓
PdfService.generateReceipt(order) called
  ↓
PDF document built with:
  • Header: SmartCart logo (emoji), title "Purchase Receipt"
  • Order details: Receipt No., Order Number, Date, Exit Code
  • Item table: Product name, Qty, Unit Price, Line Total
  • Totals section: Subtotal, Tax (if applicable), Grand Total
  • Payment info: Method (UPI/COD), Status (Paid/Pending)
  • Footer: "Thank you for shopping with SmartCart"
  ↓
PDF saved as temporary file
  ↓
share_plus opens system share sheet
  ↓
User can: Save to Files, Email, WhatsApp, Print, etc.

Exception handling:
  • PDF generation fails → Error snackbar shown
  • File system permission denied → Fallback to in-memory
  • Share cancelled → No error (normal behavior)
```

---

### 🐛 Bug Reporting & Feedback System

```
╔════════════════════════════════════════════════════════════════════╗
║            FEEDBACK / BUG REPORT PIPELINE                           ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  FEEDBACK SUBMISSION                                                 ║
║  ─────────────────────                                               ║
║  User navigates to Profile → Send Feedback                          ║
║    ↓                                                                ║
║  Form collects:                                                      ║
║  • Category (dropdown): General, Feature Request, Bug, Other         ║
║  • Message (text area): Detailed description                         ║
║  • Rating (star selector): 1-5 stars                                 ║
║    ↓                                                                ║
║  On submit:                                                          ║
║  1. Validate: Message not empty, rating selected                     ║
║  2. Auto-collect device info:                                        ║
║     • Device model (via device_info_plus)                            ║
║     • OS version                                                     ║
║     • App version (via package_info_plus)                            ║
║  3. Write to /feedbacks collection:                                  ║
║     • userId, email, name                                             ║
║     • type: "feedback"                                                ║
║     • category, message, rating                                       ║
║     • deviceInfo: { model, os, appVersion }                           ║
║     • timestamp (server)                                              ║
║  4. Success → Green snackbar + form cleared                          ║
║  5. Failure → Red snackbar with error                                ║
║                                                                    ║
║  BUG REPORT (Shake to Report)                                        ║
║  ─────────────────────────────                                       ║
║  ShakeListener widget wraps entire app                               ║
║    ↓                                                                ║
║  Listens to accelerometer (sensors_plus)                             ║
║    ↓                                                                ║
║  Shake detected (acceleration > threshold):                          ║
║    ↓                                                                ║
║  Debounce check (prevent spam triggers)                              ║
║    ↓                                                                ║
║  Navigate to ReportBugScreen via global navigator key                ║
║  (Works from ANY screen in the app)                                  ║
║    ↓                                                                ║
║  Bug report form collects:                                            ║
║  • Bug description (required)                                        ║
║  • Steps to reproduce                                                ║
║  • Expected behavior                                                 ║
║  • Actual behavior                                                    ║
║    ↓                                                                ║
║  Same submission pipeline as feedback, with type: "bug_report"       ║
║                                                                    ║
║  ADMIN VIEW (Web Dashboard)                                          ║
║  ──────────────────────────                                          ║
║  Feedbacks tab shows all submissions from /feedbacks                 ║
║  Sorted by timestamp (newest first)                                  ║
║  Each entry displays: user, type, category, message, rating, date    ║
║  Admin can filter by type (feedback vs bug_report)                   ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

### 💰 Budget Management — How It Works

```
Budget System Flow:
  ↓
User sets monthly budget in Profile → Budget Settings
  ↓
Budget saved to SharedPreferences (local only, not synced)
  ↓
When adding items to cart:
  1. Calculate new cart total (current total + new item price)
  2. Compare against set budget
  3. If total > budget:
     → Show orange warning snackbar: "This will exceed your budget"
     → Item STILL added (warning, not block)
     → Budget exceeded indicator shown on cart screen
  4. If total <= budget:
     → Normal add flow, no warning
  ↓
Budget tracking visible on:
  • Cart screen: "Budget: ₹X / ₹Y used"
  • Spending analytics: Monthly spending vs budget chart
  ↓
BudgetService tracks:
  • Monthly spend calculation (sum of all orders this month)
  • Budget utilization percentage
  • Remaining budget
  • Projected monthly spend (based on daily average)
  ↓
Analytics event logged: budget_set (with amount)
```

---

### 🔊 Text-to-Speech — Accessibility Feature

```
TTS Integration:
  ↓
flutter_tts package initialized on demand
  ↓
Used in product detail screen:
  • User taps speaker icon next to product name
  • TTS reads: "{productName} by {brand}, priced at {price} rupees"
  • TTS reads product description if available
  ↓
TTS settings:
  • Language: English (en-US)
  • Speech rate: 0.5 (medium)
  • Volume: 1.0
  • Pitch: 1.0
  ↓
Exception handling:
  • TTS engine not available → Feature hidden (icon not shown)
  • Language not supported → Fallback to default system language
  • Speech interrupted (user navigates away) → TTS.stop() called in dispose()
```

---

### 📈 Spending Analytics — Data Pipeline

```
SpendingAnalyticsScreen loads:
  ↓
1. Fetch all orders for current user
     (from local _orders list, already loaded via real-time listener)
  ↓
2. Process orders into analytics buckets:
   • Monthly totals: Group by month, sum order totals
   • Category breakdown: Group by product category across all orders
   • Daily average: Total spend ÷ days since first order
   • Most purchased: Count product appearances across orders
   • Peak shopping days: Group orders by day of week
  ↓
3. All processing happens CLIENT-SIDE (no backend aggregation)
   → Instant results, no network call
   → Works offline with cached orders
  ↓
4. Charts rendered using custom Flutter widgets:
   • Bar chart: Monthly spending trend
   • Pie chart: Category distribution
   • Line chart: Spending over time
   • Stats cards: Average order, largest order, total orders
  ↓
5. Budget comparison overlay:
   • Budget line drawn on monthly chart
   • Months exceeding budget highlighted in red
   • Under-budget months in green
```

---

### 🔧 Build & Deployment Workflow

```
╔════════════════════════════════════════════════════════════════════╗
║              BUILD & RELEASE PIPELINE                                ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  DEVELOPMENT BUILD                                                  ║
║  ──────────────────                                                 ║
║  Developer runs debug build → Installs on connected device           ║
║  Hot reload available for iterative development                      ║
║  Debug banner shown in top-right corner                              ║
║  Crashlytics collection disabled (avoid noise)                       ║
║                                                                    ║
║  RELEASE BUILD (via publish_check.ps1)                               ║
║  ───────────────────────────────────────                             ║
║  Step 1: ENVIRONMENT VALIDATION                                      ║
║    • Flutter SDK present and on stable channel?                      ║
║    • Firebase CLI installed?                                         ║
║    • Connected device/emulator available?                            ║
║    ↓ PASS → Continue  |  FAIL → Abort with specific fix guidance     ║
║                                                                    ║
║  Step 2: PROJECT STRUCTURE CHECK                                     ║
║    • pubspec.yaml exists?                                            ║
║    • google-services.json exists?                                    ║
║    • firebase_options.dart exists?                                   ║
║    • All required directories present?                               ║
║    ↓ PASS → Continue  |  FAIL → List missing files                   ║
║                                                                    ║
║  Step 3: TEST SUITE EXECUTION                                        ║
║    • Each test file run individually (per-file validation)           ║
║    • Counts: passed, failed, skipped per file                        ║
║    • Total test count tracked                                         ║
║    ↓ ALL PASS → Continue  |  ANY FAIL → Show failures, abort         ║
║                                                                    ║
║  Step 4: FIREBASE CONFIGURATION VALIDATION                           ║
║    • Parse google-services.json                                      ║
║    • Verify project ID matches (smartcart-b0cac)                     ║
║    • Check package name matches                                      ║
║    ↓ VALID → Continue  |  INVALID → Show mismatch details            ║
║                                                                    ║
║  Step 5: CLEAN BUILD                                                 ║
║    • Flutter clean (remove all cached builds)                        ║
║    • Flutter pub get (fresh dependency resolution)                   ║
║    ↓ Always continues                                                ║
║                                                                    ║
║  Step 6: STATIC ANALYSIS                                             ║
║    • flutter analyze (lint rules from analysis_options.yaml)         ║
║    ↓ PASS → Continue  |  FAIL → Show lint errors, abort              ║
║                                                                    ║
║  Step 7: COVERAGE REPORT                                             ║
║    • Run tests with --coverage flag                                   ║
║    • Generate lcov.info                                               ║
║    • Calculate coverage percentage                                    ║
║    ↓ Report generated (informational, doesn't block)                 ║
║                                                                    ║
║  Step 8: SECURITY SCAN                                               ║
║    • Scan all source files for sensitive patterns                    ║
║    • Check for: hardcoded passwords, API keys, secrets               ║
║    • Patterns: "password=", "api_key=", "secret="                    ║
║    ↓ CLEAN → Continue  |  FOUND → Warning (doesn't abort)            ║
║                                                                    ║
║  Step 9: RELEASE BUILD                                               ║
║    • flutter build apk --release --split-per-abi                     ║
║    • Generates 3 APKs: arm64, armeabi-v7a, x86_64                   ║
║    ↓ SUCCESS → Continue  |  FAIL → Show build errors, abort          ║
║                                                                    ║
║  Step 10: POST-BUILD                                                 ║
║    • Generate SHA256 checksums for each APK                          ║
║    • Create build_info.json with metadata:                           ║
║      - Version, build date, Flutter version, Dart version            ║
║      - Tests passed count, coverage percentage                       ║
║    • Copy APKs + metadata to releases/ directory                     ║
║      Format: releases/PROD_BUILD_{date}_{time}/                      ║
║    ↓ DONE → Print success summary with file sizes                    ║
║                                                                    ║
║  WEB DASHBOARD DEPLOYMENT (Separate)                                ║
║  ─────────────────────────────────────                               ║
║  • firebase deploy --only hosting                                    ║
║  • Uploads admin.html + assets to Firebase Hosting                   ║
║  • Live at: https://smartcart-b0cac.web.app                         ║
║  • Preview channels available for staging                            ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

### 🧪 Testing Philosophy & Coverage

```
TEST ARCHITECTURE:
  ↓
76+ tests across 11 files covering:

  UNIT TESTS (40 tests):
  • Model creation: Product, CartItem, Order, UserProfile
  • Price conversion: paise ↔ rupees (₹65.00 = 6500 paise)
  • Cart calculations: total, item count, quantity limits
  • Search logic: text matching across multiple fields
  • Stock validation: sufficient stock, out of stock, at limit
  • Barcode lookup: found, not found, null barcode
  • Theme persistence: toggle, save, restore
  • Notification management: add, mark read, clear

  WIDGET TESTS (10 tests):
  • All screens render without overflow errors
  • Bottom navigation bar shows all 4 tabs + FAB
  • Quick action buttons are visible and tappable
  • Product cards display all required information
  • Cart screen shows empty state when no items

  INTEGRATION TESTS (20 tests):
  • Full shopping flow: Browse → Add to Cart → Checkout → Confirm
  • Registration → Login → Shop → Order sequence
  • Search → Filter → Add → Cart → Review flow
  • Reorder from history with stock revalidation
  • Theme switch persists across screen navigations

  PERFORMANCE TESTS (6 tests):
  • Product list renders 100 items in under 500ms
  • Search completes in under 200ms
  • Cart operations complete in under 50ms
  • Screen transitions maintain 60 FPS
  • Barcode scan detection under 1 second

TESTING PATTERNS USED:
  • Mocking: Firebase services mocked for unit tests
  • Dependency injection: Services passed via constructor for testability
  • Golden tests: Not currently used (emoji-based UI, no custom painting)
  • Widget testing: Uses pumpWidget with MaterialApp wrapper
  • Provider testing: AppStateProvider tested directly via methods
```

---

### 🛣️ Future Roadmap

**Short-term (Next 3 months)**:
- AI-Powered Recommendations — Personalized product suggestions, "Frequently bought together", smart reorder predictions based on purchase history patterns
- Multi-Language Support — Hindi, Marathi, Gujarati using Flutter's l10n framework with ARB files
- Loyalty Program — Points earned per ₹ spent, tier-based benefits (Bronze/Silver/Gold), referral rewards
- Enhanced Analytics — ML-powered spending insights, budget recommendations, purchase pattern detection

**Mid-term (6 months)**:
- AR Product Visualization — View products in augmented reality, size comparison with real objects
- Voice Assistant Integration — Google Assistant actions, Alexa Skills for voice ordering
- Smart Shelf Integration — IoT sensors for automatic stock tracking, real-time inventory from shelf weight sensors
- Advanced Payment Options — Credit/debit card integration via Razorpay, EMI options, wallet integration

**Long-term (1 year+)**:
- Multi-Store Support — Multiple retail locations, store locator with maps, store-specific inventory and pricing
- B2B Platform — Bulk ordering for businesses, business accounts with invoicing, net-30 payment terms
- Supply Chain Integration — Supplier portal for automated restocking, demand forecasting using historical data

---

### ❓ FAQ — Frequently Asked Questions

**General**

Q: What platforms does SmartCart support?
A: Currently Android only. iOS support requires Apple Developer enrollment ($99/year) and macOS for building. Web dashboard works on all modern browsers.

Q: Is SmartCart open source?
A: No, it's proprietary software © 2026 Shreyas Sanjay Pawar. All rights reserved.

Q: How is SmartCart different from other shopping apps?
A: SmartCart is designed for in-store smart shopping with barcode scanning, UPI payments, real-time inventory, and exit verification — replacing traditional checkout counters entirely.

**Technical**

Q: Which Flutter version should I use?
A: Flutter 3.38.6 (stable channel) or higher. Run the check with Flutter's version command and upgrade if needed.

Q: Do I need a Mac for development?
A: No. Windows and Linux work for Android builds. Mac required only for iOS.

Q: How do I update dependencies safely?
A: Run outdated check first → review breaking changes → upgrade → run full test suite → verify manually.

Q: What happens if Firestore is down?
A: The app continues working with offline cache. Products and orders cached locally. Cart works fully offline. Only placing new orders and signing in require internet.

**Firebase**

Q: Do I need a paid Firebase plan?
A: Free Spark plan sufficient for development and small-scale use. Blaze plan (pay-as-you-go) recommended for production with more than ~1000 daily users.

Q: How much does Firebase cost at scale?
A: Free tier includes 50K reads, 20K writes, 20K deletes per day. Beyond that: $0.06/100K reads, $0.18/100K writes. For 10K daily users, expect ~$5-15/month.

Q: Can I use my own backend instead of Firebase?
A: Technically yes, but requires significant refactoring. Firebase is deeply integrated into auth, database, analytics, messaging, and crash reporting. Estimated effort: 3-4 weeks for a senior developer.

**Security**

Q: Is user data safe?
A: Yes. All data encrypted in transit (TLS) and at rest (GCP). Firestore security rules enforce per-user data isolation. Passwords never stored in app — Firebase Auth handles hashing.

Q: Can admins see user passwords?
A: No. Firebase Auth uses bcrypt hashing. Even Firebase Console doesn't expose passwords. Admins can only reset passwords.

Q: What if someone gets the google-services.json file?
A: It contains project identification (not secrets). Firestore security rules prevent unauthorized access even with the config file. The real protection is in the server-side rules.

**Deployment**

Q: How do I publish to Google Play Store?
A: Run the gatekeeper script → Upload APK or App Bundle to Play Console → Fill store listing → Submit for review → Takes 1-3 days for first review.

Q: How often should I release updates?
A: Monthly for feature updates. Immediately for critical bug fixes. Use Crashlytics to identify crash-free rate and prioritize.

---

### 📖 Glossary

| Term | Definition |
|------|-----------|
| **ABI** | Application Binary Interface — CPU architecture (arm64, armeabi-v7a, x86_64) determining which APK runs on which device |
| **APK** | Android Package Kit — The installable file format for Android applications |
| **App Bundle (AAB)** | Android App Bundle — Google's preferred publishing format that optimizes download size per device |
| **ChangeNotifier** | Flutter class that provides change notifications to listeners, used by Provider for reactive state management |
| **COD** | Cash on Delivery — Payment collected at store exit counter |
| **Consumer** | Provider widget that rebuilds only its child tree when notified, more efficient than context.watch |
| **Crashlytics** | Firebase service for real-time crash reporting with stack traces and device context |
| **Exit Code** | 6-character alphanumeric verification code shown to staff when leaving store with items |
| **FCM** | Firebase Cloud Messaging — Google's push notification service for mobile and web |
| **Firestore** | Cloud Firestore — Google's scalable NoSQL document database with real-time sync |
| **IndexedStack** | Flutter widget that keeps all children alive but only displays one — used for tab navigation to preserve state |
| **Material 3** | Latest Material Design specification with dynamic color theming and updated component designs |
| **notifyListeners()** | Method called on ChangeNotifier to trigger UI rebuilds in all listening widgets |
| **OAuth 2.0** | Authorization framework used by Google Sign-In for secure third-party authentication |
| **Paise** | Smallest unit of Indian currency (1 Rupee = 100 Paise) — SmartCart stores all prices in paise for precision |
| **Provider** | State management solution for Flutter that uses InheritedWidget under the hood |
| **runZonedGuarded** | Dart zone that catches all uncaught async errors within its scope |
| **SHA Fingerprint** | Certificate fingerprint (SHA-1/SHA-256) used to verify app identity for Google Sign-In |
| **Singleton** | Design pattern ensuring only one instance of a class exists throughout app lifecycle |
| **StreamBuilder** | Flutter widget that rebuilds based on stream events — used for auth state and real-time data |
| **Transaction** | Firestore operation that reads and writes atomically — prevents race conditions |
| **UPI** | Unified Payments Interface — India's real-time payment system used by Google Pay, PhonePe, etc. |

---

### 📝 Changelog

**Version 2.0.0 (February 2026)**
- Added staggered animations across all screens
- Implemented voice search with speech_to_text
- Added shake-to-report bug feature with accelerometer detection
- Comprehensive test suite reaching 76 tests across 11 files
- Publish gatekeeper script for automated pre-release validation
- GitHub Actions CI/CD pipeline
- Fixed order history reorder stock validation (was allowing orders exceeding stock)
- Fixed price display inconsistency (paise to rupees conversion)
- Fixed all lint warnings from flutter analyze
- Comprehensive documentation (5000+ lines, architecture-focused)
- Improved UI with Material 3 dynamic theming
- Performance optimizations for product loading and search

**Version 1.0.0 (January 2026)**
- Initial release
- Core shopping functionality (browse, cart, checkout)
- Firebase integration (Auth, Firestore, Messaging, Analytics, Crashlytics)
- Google Sign-In with native + provider fallback
- Barcode scanning via mobile_scanner
- UPI payment link generation
- Web admin dashboard with Tailwind CSS and Chart.js
- Firestore security rules with role-based access

---

**End of Documentation**

---
