import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud;
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/analytics_service.dart';
import '../services/inventory_service.dart';
import '../utils/feedback_helper.dart';
import '../utils/performance_monitor.dart';
import '../services/unique_id_service.dart';

class AppStateProvider extends ChangeNotifier {
  // Constructor for testing with mock services
  AppStateProvider({
    AuthService? authService,
    AnalyticsService? analyticsService,
    InventoryService? inventoryService,
  })  : _authService = authService ?? AuthService(),
        _analytics = analyticsService,
        _inventory = inventoryService ?? InventoryService();

  // Theme Management
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  Future<void> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  // In-app notifications
  List<Map<String, dynamic>> _notifications = [];
  int get unreadNotificationCount =>
      _notifications.where((n) => n['read'] == false).length;
  List<Map<String, dynamic>> get notifications => _notifications;

  // Load notifications from Firestore
  Future<void> loadNotifications() async {
    final user = _authService.currentUser;
    if (user == null) return;
    final snapshot = await cloud.FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .get();
    _notifications = snapshot.docs.map((doc) => doc.data()).toList();
    notifyListeners();
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsRead() async {
    final user = _authService.currentUser;
    if (user == null) return;
    final batch = cloud.FirebaseFirestore.instance.batch();
    final snapshot = await cloud.FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .get();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
    await loadNotifications();
  }

  // Mark a single notification as read
  Future<void> markNotificationRead(String notificationId) async {
    final user = _authService.currentUser;
    if (user == null) return;
    try {
      await cloud.FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});
      await loadNotifications();
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  late final AuthService _authService;
  late final AnalyticsService? _analytics;
  late final InventoryService _inventory;

  // Payment request listener
  StreamSubscription<cloud.DocumentSnapshot>? _paymentRequestSubscription;

  // Loading states
  bool _isLoadingProducts = false;
  final bool _isLoadingAddresses = false;
  final bool _isLoadingProfile = false;
  final bool _isLoadingPaymentMethods = false;
  final bool _isLoadingOrders = false;

  bool get isLoadingProducts => _isLoadingProducts;
  bool get isLoadingAddresses => _isLoadingAddresses;
  bool get isLoadingProfile => _isLoadingProfile;
  bool get isLoadingPaymentMethods => _isLoadingPaymentMethods;
  bool get isLoadingOrders => _isLoadingOrders;

  bool get isLoading =>
      _isLoadingProducts ||
      _isLoadingAddresses ||
      _isLoadingProfile ||
      _isLoadingPaymentMethods ||
      _isLoadingOrders;

  // Products from Firestore
  List<Product> _products = [];
  List<Product> get products => _products;

  // For testing purposes
  void setTestProducts(List<Product> products) {
    _products = products;
    notifyListeners();
  }

  // Pagination
  bool _hasMoreProducts = true;
  bool _isLoadingMoreProducts = false;
  cloud.DocumentSnapshot? _lastProductDoc;
  static const int _productsPerPage = 20;

  bool get hasMoreProducts => _hasMoreProducts;
  bool get isLoadingMoreProducts => _isLoadingMoreProducts;

  // Popular products (limited to 10)
  List<Product> get popularProducts => _products.take(10).toList();

  // Selected category for filtering
  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Search query
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Filtered products by category
  List<Product> get filteredProducts {
    if (_selectedCategory == 'All') {
      return _products;
    }
    return _products
        .where(
          (p) => p.category.toLowerCase() == _selectedCategory.toLowerCase(),
        )
        .toList();
  }

  // Search products
  List<Product> searchProducts(String query) {
    if (query.isEmpty) {
      return _products;
    }
    final lowerQuery = query.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
          product.category.toLowerCase().contains(lowerQuery) ||
          product.brand.toLowerCase().contains(lowerQuery) ||
          product.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Get all unique categories from products
  List<String> get categories {
    final cats = _products.map((p) => p.category).toSet().toList();
    return ['All', ...cats];
  }

  // Load initial batch of products
  Future<void> loadProductsFromFirestore() async {
    if (_products.isNotEmpty) return; // Already loaded

    PerformanceMonitor().startTimer('loadProducts');
    _isLoadingProducts = true;
    notifyListeners();

    try {
      final query = cloud.FirebaseFirestore.instance
          .collection('products')
          .orderBy('name')
          .limit(_productsPerPage);

      final snapshot = await query.get();
      _products = snapshot.docs.map((doc) {
        return Product.fromMap(doc.data(), doc.id);
      }).toList();

      _lastProductDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      _hasMoreProducts = snapshot.docs.length == _productsPerPage;
      _isLoadingProducts = false;
      notifyListeners();

      PerformanceMonitor().stopTimer('loadProducts');
      debugPrint('✓ Loaded ${_products.length} products (initial batch)');
    } catch (e) {
      debugPrint('❌ Error loading products: $e');
      _isLoadingProducts = false;
      notifyListeners();
      PerformanceMonitor().stopTimer('loadProducts');
    }
  }

  // Load more products (pagination)
  Future<void> loadMoreProducts() async {
    if (!_hasMoreProducts ||
        _isLoadingMoreProducts ||
        _lastProductDoc == null) {
      return;
    }

    _isLoadingMoreProducts = true;
    notifyListeners();

    try {
      final query = cloud.FirebaseFirestore.instance
          .collection('products')
          .orderBy('name')
          .startAfterDocument(_lastProductDoc!)
          .limit(_productsPerPage);

      final snapshot = await query.get();
      final newProducts = snapshot.docs.map((doc) {
        return Product.fromMap(doc.data(), doc.id);
      }).toList();

      _products.addAll(newProducts);
      _lastProductDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      _hasMoreProducts = snapshot.docs.length == _productsPerPage;
      _isLoadingMoreProducts = false;
      notifyListeners();

      debugPrint(
        '✓ Loaded ${newProducts.length} more products (total: ${_products.length})',
      );
    } catch (e) {
      debugPrint('❌ Error loading more products: $e');
      _isLoadingMoreProducts = false;
      notifyListeners();
    }
  }

  // Force refresh products from Firestore (useful for web/mobile sync issues)
  Future<void> refreshProducts() async {
    _isLoadingProducts = true;
    notifyListeners();

    try {
      final snapshot = await cloud.FirebaseFirestore.instance
          .collection('products')
          .get();
      debugPrint('📦 Fetched ${snapshot.docs.length} total products');
      _products = snapshot.docs.map((doc) {
        final data = doc.data();
        debugPrint('📦 Product data: $data');
        return Product.fromMap(data, doc.id);
      }).toList();
      notifyListeners();
      debugPrint(
        '✓ Products refreshed from Firestore (${_products.length} items)',
      );
    } catch (e) {
      debugPrint('❌ Error refreshing products: $e');
      _analytics?.logError(
        'Failed to refresh products',
        errorCode: 'REFRESH_PRODUCTS_ERROR',
      );
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  // User Profile
  UserProfile _userProfile = UserProfile(
    name: "Guest User",
    email: "guest@smartcart.com",
    phone: "+1 234 567 8900",
    avatarEmoji: "👤",
    photoURL: null,
    role: "customer",
  );

  UserProfile get userProfile => _userProfile;

  // Load user data from Firebase Auth
  void loadUserFromAuth() {
    // Allow reloading after sign-in
    final user = _authService.currentUser;
    if (user != null) {
      // Use Firebase Auth data directly
      final displayName = user.displayName ?? user.email?.split('@')[0] ?? "User";
      final email = user.email ?? "no-email@smartcart.com";
      
      _userProfile = UserProfile(
        name: displayName,
        email: email,
        phone: user.phoneNumber ?? "",
        avatarEmoji: "👤",
        photoURL: user.photoURL, // Include Google profile picture
        role: "customer",
      );
      notifyListeners();
      // Auto-create or load profile from Firestore on sign-in
      initializeOrLoadUserProfile();
    }
  }

  // Initialize user profile on first sign-in or load existing
  Future<void> initializeOrLoadUserProfile() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      final doc = await cloud.FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        // Profile exists, start real-time listener
        loadProfileFromFirestore();
      } else {
        // First sign-in, create profile with Firebase Auth data
        final displayName = user.displayName ?? user.email?.split('@')[0] ?? "User";
        final email = user.email ?? "no-email@smartcart.com";
        
        await cloud.FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
              'name': displayName,
              'displayName': displayName,
              'email': email,
              'phone': user.phoneNumber ?? '',
              'photoURL': user.photoURL, // Save Google profile picture
              'avatarEmoji': '👤',
              'role': 'customer',
              'isSuspended': false,
              'createdAt': cloud.FieldValue.serverTimestamp(),
              'updatedAt': cloud.FieldValue.serverTimestamp(),
              'lastLoginTime': cloud.FieldValue.serverTimestamp(),
            });
        debugPrint('✅ New user profile created in Firestore: $displayName ($email)');
        // Start real-time listener
        loadProfileFromFirestore();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error initializing user profile: $e');
    }
  }

  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatarEmoji,
  }) {
    if (name != null) _userProfile.name = name;
    if (email != null) _userProfile.email = email;
    if (phone != null) _userProfile.phone = phone;
    if (avatarEmoji != null) _userProfile.avatarEmoji = avatarEmoji;
    notifyListeners();
    // Save to Firestore
    saveProfileToFirestore();
  }

  // Cart Logic
  final List<CartItem> _cart = [];

  List<CartItem> get cart => _cart;

  int get cartTotal => _cart.fold(
    0,
    (sum, item) => sum + (item.product.price.toInt() * item.quantity),
  );
  int get cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  void addToCart(Product product, {BuildContext? context}) {
    final index = _cart.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      // Product already in cart - check if we can add more
      if (_cart[index].quantity < product.stockQuantity) {
        _cart[index].quantity++;
        HapticFeedback.mediumImpact();  // Add haptic feedback
        if (context != null && context.mounted) {
          FeedbackHelper.showSuccessSnackBar(
            context,
            '${product.name} quantity increased',
          );
        }
      } else {
        if (context != null && context.mounted) {
          FeedbackHelper.showWarningSnackBar(
            context,
            'Maximum stock reached for ${product.name}',
          );
        }
        return;
      }
    } else {
      // New product - check if stock available
      if (product.stockQuantity > 0) {
        _cart.add(CartItem(product: product));
        HapticFeedback.mediumImpact();  // Add haptic feedback
        // Track add to cart
        _analytics?.trackAddToCart(product.id, product.name);
        if (context != null && context.mounted) {
          FeedbackHelper.showSuccessSnackBar(
            context,
            '${product.name} added to cart',
          );
        }
      } else {
        if (context != null && context.mounted) {
          FeedbackHelper.showErrorSnackBar(
            context,
            '${product.name} is out of stock',
          );
        }
        return;
      }
    }
    notifyListeners();
  }

  void removeFromCart(Product product) {
    final index = _cart.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      if (_cart[index].quantity > 1) {
        _cart[index].quantity--;
      } else {
        _cart.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // Order History
  final List<Order> _orders = [];
  List<Order> get orders => _orders;

  // Validate stock before placing order
  bool canPlaceOrder() {
    for (var item in _cart) {
      if (item.product.stockQuantity < item.quantity) {
        debugPrint(
          '❌ Insufficient stock for ${item.product.name}: need ${item.quantity}, have ${item.product.stockQuantity}',
        );
        return false;
      }
    }
    return true;
  }

  // Get stock error message
  String getStockErrorMessage() {
    for (var item in _cart) {
      if (item.product.stockQuantity < item.quantity) {
        final shortage = item.quantity - item.product.stockQuantity;
        return '${item.product.name}: Only ${item.product.stockQuantity} available, you need ${item.quantity} ($shortage short)';
      }
    }
    return 'Insufficient stock';
  }

  // ==================== PAYMENT REQUESTS ====================

  List<Map<String, dynamic>> _paymentRequests = [];
  List<Map<String, dynamic>> get paymentRequests => _paymentRequests;

  // Create payment request (pending admin approval)
  Future<Map<String, dynamic>?> createPaymentRequest({
    required String paymentMethod,
    required double amount,
    Function()? onApproved,
    Function(String reason)? onRejected,
  }) async {
    if (_cart.isEmpty) return null;

    // Validate stock before proceeding
    if (!canPlaceOrder()) {
      debugPrint('❌ Payment request cancelled: Stock validation failed');
      throw Exception(getStockErrorMessage());
    }

    try {
      // New behavior: directly place the order instead of creating a payment request.
      // Determine payment status for the order based on method.
      final paymentStatus = paymentMethod.toLowerCase().contains('cod')
          ? 'Pending Payment'
          : 'Paid';

      await placeOrder(
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
      );

      // Get the order details from the most recent order
      final order = _orders.isNotEmpty ? _orders.first : null;
      if (order == null) {
        throw Exception('Order was placed but not found in local state');
      }

      // Get the order document from Firestore to get the generated IDs
      final orderDoc = await cloud.FirebaseFirestore.instance
          .collection('orders')
          .doc(order.id)
          .get();

      if (!orderDoc.exists) {
        throw Exception('Order document not found in Firestore');
      }

      final orderData = orderDoc.data()!;
      final orderDetails = {
        'orderNumber': orderData['orderNumber'] as String,
        'exitCode': orderData['exitCode'] as String,
        'receiptNo': orderData['receiptNo'] as String,
        // Return total in INR (convert from internal paise representation)
        'total': order.total.toDouble() / 100.0,
        'paymentMethod': order.paymentMethod,
      };

      // Call approval callback immediately since no admin approval is required now.
      if (onApproved != null) onApproved();

      return orderDetails;
    } catch (e) {
      debugPrint('❌ Error processing payment directly: $e');
      if (onRejected != null) onRejected(e.toString());
      rethrow;
    }
  }

  // Payment request listener removed — admin approval flow discontinued.

  // Load all payment requests from Firestore - Real-time listener
  void loadPaymentRequestsFromFirestore() {
    try {
      cloud.FirebaseFirestore.instance
          .collection('payment_requests')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
              _paymentRequests = snapshot.docs.map((doc) {
                final data = doc.data();
                return {'id': doc.id, ...data};
              }).toList();
              notifyListeners();
            },
            onError: (e) {
              debugPrint('Error listening to payment requests: $e');
            },
          );
    } catch (e) {
      debugPrint('Error setting up payment requests listener: $e');
    }
  }

  // ==================== ORDER MANAGEMENT ====================

  Future<void> placeOrder({
    String paymentMethod = 'UPI',
    String paymentStatus = 'Pending Payment',
  }) async {
    if (_cart.isEmpty) return;

    final user = _authService.currentUser;
    if (user == null) {
      debugPrint('❌ Order cancelled: User not authenticated');
      throw Exception('You must be signed in to place an order');
    }
    
    final userId = user.uid;
    final userEmail = user.email ?? '';

    // Validate stock before proceeding
    if (!canPlaceOrder()) {
      debugPrint('❌ Order cancelled: Stock validation failed');
      throw Exception(getStockErrorMessage());
    }

    try {
      // Use shared UniqueIdService for unique IDs
      final ids = await UniqueIdService.generateUniqueOrderIds();
      final receiptId = ids['receiptId']!;
      final orderNumber = ids['orderNumber']!;
      final exitCode = ids['exitCode']!;

      final order = Order(
        id: receiptId, // Use receiptId as the main order ID
        date: DateTime.now(),
        items: _cart
            .map(
              (item) =>
                  CartItem(product: item.product, quantity: item.quantity),
            )
            .toList(),
        total: cartTotal,
        status: 'Pending',
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
      );

      // Save order to Firestore
      debugPrint('📝 Saving order to Firestore...');
      debugPrint('🔑 User ID: $userId');
      debugPrint('📧 User Email: $userEmail');
      debugPrint('📦 Order ID: ${order.id}');
      
      try {
        await cloud.FirebaseFirestore.instance
            .collection('orders')
            .doc(order.id)
            .set({
              'id': order.id,
              'receiptNo': receiptId, // Unique receipt/transaction ID (Full UUID)
              'orderNumber':
                  orderNumber, // User-friendly 12-char random order number
              'exitCode': exitCode, // Exit verification code
              'userId': userId,
              'email': userEmail, // Add email for order tracking
              'date': order.date,
              'items': order.items.map((item) => item.toMap()).toList(),
            'total': order.total,
            'status': order.status,
            'paymentMethod': order.paymentMethod,
            'paymentStatus': order.paymentStatus,
            'createdAt': cloud.FieldValue.serverTimestamp(),
          });
        debugPrint('✅ Order saved successfully to Firestore');
      } catch (e) {
        debugPrint('❌ FIRESTORE ERROR: $e');
        debugPrint('❌ Error type: ${e.runtimeType}');
        debugPrint('❌ Full error: ${e.toString()}');
        rethrow;
      }

      // Deduct stock from products (prevent negative stock) using transaction
      for (var item in _cart) {
        final productRef = cloud.FirebaseFirestore.instance
            .collection('products')
            .doc(item.product.id);

        await cloud.FirebaseFirestore.instance.runTransaction((
          transaction,
        ) async {
          final snapshot = await transaction.get(productRef);
          final currentStock = (snapshot.data()?['stockQuantity'] ?? 0) as int;
          final newStock = (currentStock - item.quantity)
              .clamp(0, double.infinity)
              .toInt();
          transaction.update(productRef, {
            'stockQuantity': newStock,
            'updatedAt': cloud.FieldValue.serverTimestamp(),
          });
        });

        // Track purchase
        _analytics?.trackPurchase(
          item.product.id,
          item.product.name,
          item.quantity,
          item.product.price.toInt() * item.quantity,
        );
      }

      _orders.insert(0, order);
      clearCart();
      notifyListeners();
      debugPrint('✅ Order placed successfully!');

      // Check and notify for low stock after order
      /* Inventory notifications placeholder */
      /*
      for (var item in _cart) {
        await _inventory.notifyLowStock(
          item.product.id,
          item.product.name,
          item.product.stockQuantity,
        );
      }
      */
    } catch (e) {
      // Error placing order
      debugPrint('❌ Error placing order: $e');
      rethrow;
    }
  }

  // ==================== INVENTORY MANAGEMENT ====================

  /// Check if item has stock
  bool hasStock(String productId, int quantity) {
    // Stock check placeholder
    return false;
  }

  /// Get stock status for product
  Map<String, dynamic> getStockStatus(int stock) {
    return _inventory.getStockStatus(stock);
  }

  /// Monitor all products for low stock
  Future<void> monitorInventory() async {
    // Inventory monitoring placeholder
    await _inventory.monitorAllStock();
  }

  /// Recalculate inventory based on orders
  Future<Map<String, dynamic>> recalculateInventory() async {
    // Inventory recalculation placeholder
    return await _inventory.recalculateInventory();
  }

  /// Get low stock alerts stream
  Stream<cloud.QuerySnapshot> getLowStockAlerts() {
    // Low stock alerts placeholder
    return _inventory.getLowStockAlerts();
  }

  /// Get stock history for a product
  Stream<cloud.QuerySnapshot> getStockHistory(String productId) {
    // Stock history placeholder
    return _inventory.getStockHistory(productId);
  }

  /// Resolve a low stock alert
  Future<void> resolveStockAlert(String alertId, {String note = ''}) async {
    // Alert resolution placeholder
    await _inventory.resolveAlert(alertId, note: note);
  }

  /// Get inventory statistics
  Future<Map<String, dynamic>> getInventoryStats() async {
    // Inventory stats placeholder
    return await _inventory.getInventoryStats();
  }

  // Payment Methods
  final List<PaymentMethod> _paymentMethods = [];
  List<PaymentMethod> get paymentMethods => _paymentMethods;

  void addPaymentMethod(
    String cardNumber,
    String cardHolder,
    String expiryDate,
  ) {
    final method = PaymentMethod(
      id: 'PM${DateTime.now().millisecondsSinceEpoch}',
      cardNumber: cardNumber,
      cardHolder: cardHolder,
      expiryDate: expiryDate,
    );
    _paymentMethods.add(method);
    notifyListeners();
    // Save to Firestore
    savePaymentMethodToFirestore(method);
  }

  void removePaymentMethod(String id) {
    _paymentMethods.removeWhere((method) => method.id == id);
    notifyListeners();
  }

  // Load and save payment methods to Firestore - Real-time listener
  void loadPaymentMethodsFromFirestore() {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      cloud.FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('paymentMethods')
          .snapshots()
          .listen(
            (snapshot) {
              _paymentMethods.clear();
              _paymentMethods.addAll(
                snapshot.docs.map((doc) {
                  return PaymentMethod.fromMap(doc.data(), doc.id);
                }),
              );
              notifyListeners();
            },
            onError: (e) {
              debugPrint('Error listening to payment methods: $e');
            },
          );
    } catch (e) {
      debugPrint('Error setting up payment methods listener: $e');
    }
  }

  Future<void> savePaymentMethodToFirestore(PaymentMethod method) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      await cloud.FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('paymentMethods')
          .doc(method.id)
          .set({
            ...method.toMap(),
            'createdAt': cloud.FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('Error saving payment method: $e');
    }
  }

  // Shipping Addresses
  final List<Address> _addresses = [];
  List<Address> get addresses => _addresses;

  void addAddress(
    String name,
    String street,
    String city,
    String zipCode,
    String phone,
  ) async {
    final address = Address(
      id: 'ADDR${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      street: street,
      city: city,
      zipCode: zipCode,
      phone: phone,
    );

    // Save to Firestore under user subcollection
    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('User not signed in');
      await cloud.FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .doc(address.id)
          .set({
            ...address.toMap(),
            'createdAt': cloud.FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('Error saving address: $e');
    }

    _addresses.add(address);
    notifyListeners();
  }

  void removeAddress(String id) {
    // Delete from Firestore
    cloud.FirebaseFirestore.instance
        .collection('addresses')
        .doc(id)
        .delete()
        .catchError((e) => debugPrint('Error deleting address: $e'));

    _addresses.removeWhere((address) => address.id == id);
    notifyListeners();
  }

  // Load addresses from Firestore
  void loadAddressesFromFirestore() {
    cloud.FirebaseFirestore.instance.collection('addresses').snapshots().listen(
      (snapshot) {
        _addresses.clear();
        _addresses.addAll(
          snapshot.docs.map((doc) {
            return Address.fromMap(doc.data());
          }),
        );
        notifyListeners();
      },
    );
  }

  // Load orders from Firestore - Real-time listener
  void loadOrdersFromFirestore() {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      cloud.FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
              _orders.clear();
              _orders.addAll(
                snapshot.docs.map((doc) {
                  return Order.fromMap(doc.data(), doc.id);
                }),
              );
              notifyListeners();
            },
            onError: (e) {
              debugPrint('Error listening to orders: $e');
            },
          );
    } catch (e) {
      debugPrint('Error setting up orders listener: $e');
    }
  }

  // Save user profile to Firestore
  Future<void> saveProfileToFirestore() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      await cloud.FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
            'name': _userProfile.name,
            'email': _userProfile.email,
            'phone': _userProfile.phone,
            'avatarEmoji': _userProfile.avatarEmoji,
            'photoURL': _userProfile.photoURL, // Save Google profile picture
            'updatedAt': cloud.FieldValue.serverTimestamp(),
          }, cloud.SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving profile: $e');
    }
  }

  // Load user profile from Firestore - Real-time listener
  void loadProfileFromFirestore() {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      cloud.FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen(
            (doc) {
              if (doc.exists) {
                final data = doc.data() ?? {};
                _userProfile = UserProfile(
                  name: data['name'] ?? user.displayName ?? 'User',
                  email:
                      data['email'] ?? user.email ?? 'no-email@smartcart.com',
                  phone: data['phone'] ?? '+1 234 567 8900',
                  avatarEmoji: data['avatarEmoji'] ?? '👤',
                  photoURL: data['photoURL'], // Load Google profile picture
                  role: data['role'] ?? 'customer',
                );
                notifyListeners();
              }
            },
            onError: (e) {
              debugPrint('Error listening to profile: $e');
            },
          );
    } catch (e) {
      debugPrint('Error setting up profile listener: $e');
    }
  }

  // Settings
  bool _notificationsEnabled = true;

  bool get notificationsEnabled => _notificationsEnabled;

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  // Update order status and send notification
  Future<void> updateOrderStatus(
    String orderId,
    String newStatus, {
    String? trackingUrl,
  }) async {
    try {
      await cloud.FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
            'status': newStatus,
            'updatedAt': cloud.FieldValue.serverTimestamp(),
          });

      // Update local order - create new instance
      final orderIndex = _orders.indexWhere((o) => o.id == orderId);
      if (orderIndex >= 0) {
        final oldOrder = _orders[orderIndex];
        final updatedOrder = Order(
          id: oldOrder.id,
          date: oldOrder.date,
          items: oldOrder.items,
          total: oldOrder.total,
          status: newStatus,
          paymentMethod: oldOrder.paymentMethod,
          paymentStatus: oldOrder.paymentStatus,
        );
        _orders[orderIndex] = updatedOrder;
        notifyListeners();
      }

      debugPrint('✅ Order status updated to: $newStatus');
    } catch (e) {
      debugPrint('❌ Error updating order status: $e');
    }
  }

  // Favorites Logic
  void toggleFavorite(Product product) {
    product.isFavorite = !product.isFavorite;
    notifyListeners();
  }

  // Reset stock for demo purposes
  Future<void> resetStock() async {
    // This would reset any local stock data if stored
    // For now, just notify listeners
    notifyListeners();
  }

  @override
  void dispose() {
    _paymentRequestSubscription?.cancel();
    super.dispose();
  }
}
