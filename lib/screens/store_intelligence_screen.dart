import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state_provider.dart';
import '../services/inventory_service.dart';
import '../services/price_alert_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';

class StoreIntelligenceScreen extends StatefulWidget {
  const StoreIntelligenceScreen({super.key});

  @override
  State<StoreIntelligenceScreen> createState() =>
      _StoreIntelligenceScreenState();
}

class _StoreIntelligenceScreenState extends State<StoreIntelligenceScreen> {
  // Static categories for the grid view
  static final List<Map<String, dynamic>> categories = [
    {
      'name': 'Produce',
      'icon': Icons.local_grocery_store,
      'color': AppTheme.statusSuccess,
    },
    {'name': 'Dairy', 'icon': Icons.icecream, 'color': AppTheme.accentBlue},
    {'name': 'Bakery', 'icon': Icons.cake, 'color': AppTheme.accentOrange},
    {'name': 'Household', 'icon': Icons.home, 'color': AppTheme.accentPurple},
    {'name': 'Pantry', 'icon': Icons.kitchen, 'color': AppTheme.textSecondary},
  ];
  final InventoryService _inventoryService = InventoryService();
  final PriceAlertService _priceAlertService = PriceAlertService();
  List<Product> _allProducts = [];
  List<Product> _lowStockProducts = [];
  List<Product> _recommendedProducts = [];
  List<PriceAlert> _priceAlerts = [];
  bool _isLoading = true;
  bool _priceAlertsEnabled = false;

  @override
  void initState() {
    super.initState();
    // Schedule heavy async initialization after the first frame to avoid
    // calling provider methods (which notify listeners) during the build
    // phase and causing 'setState during build' exceptions.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStoreIntelligence();
      _checkPriceAlertsEnabled();
      _loadPriceAlerts();
    });
  }

  Future<void> _loadStoreIntelligence() async {
    setState(() => _isLoading = true);

    // Store context to avoid async gap issues
    final currentContext = context;
    // Get cart items before async call to avoid context issues
    final cartItems = Provider.of<AppStateProvider>(
      currentContext,
      listen: false,
    ).cart;

    try {
      // Load all products from AppStateProvider
      final appState = Provider.of<AppStateProvider>(
        currentContext,
        listen: false,
      );

      // Refresh products to ensure we have latest data
      await appState.refreshProducts();

      final allProducts = appState.products;
      debugPrint('📊 Store Intelligence loaded ${allProducts.length} products');

      // Load low stock products
      final lowStock = await _inventoryService.getLowStockProducts();
      // Load recommended products based on cart
      final recommendations = await _inventoryService.getRecommendedProducts(
        cartItems,
      );

      if (!mounted) return;
      setState(() {
        _allProducts = allProducts;
        _lowStockProducts = lowStock;
        _recommendedProducts = recommendations;
        _isLoading = false;
      });
      // Check for price changes after loading products
      _checkPriceChanges();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading store intelligence: $e'),
            backgroundColor: AppTheme.statusError,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: const Text(
          'Store Intelligence',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Always show the category grid at the top
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return GestureDetector(
                    onTap: () =>
                        _navigateToCategory(category['name'] as String),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.darkCardHover,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: (category['color'] as Color).withValues(
                            alpha: 0.4,
                          ),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            category['icon'] as IconData,
                            color: category['color'] as Color,
                            size: 28,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category['name'] as String,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
              )
            else ...[
              _buildRecommendationsSection(),
              const SizedBox(height: 16),
              _buildLowStockSection(),
              const SizedBox(height: 16),
              _buildPriceAlertsSection(),
              const SizedBox(height: 16),
              _buildInventoryInsightsSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: AppTheme.accentOrange),
              const SizedBox(width: 8),
              const Text(
                'Smart Recommendations',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_recommendedProducts.length} items',
                  style: const TextStyle(
                    color: AppTheme.accentOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_recommendedProducts.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Add items to your cart to get personalized recommendations',
                  style: TextStyle(color: AppTheme.textTertiary),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _recommendedProducts.length,
                itemBuilder: (context, index) {
                  final product = _recommendedProducts[index];
                  return _buildRecommendationCard(product);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(Product product) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.darkCardHover,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(product.imageEmoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(
                product.name,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '₹${(product.price / 100).toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppTheme.statusSuccess,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 28,
            child: ElevatedButton(
              onPressed: () => _addToCart(product),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.statusSuccess,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 28),
              ),
              child: const Text(
                '+',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: AppTheme.statusWarning),
              const SizedBox(width: 8),
              const Text(
                'Low Stock Alerts',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.statusWarning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_lowStockProducts.length} items',
                  style: const TextStyle(
                    color: AppTheme.statusWarning,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_lowStockProducts.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'All products are well stocked!',
                  style: TextStyle(color: AppTheme.textTertiary),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ..._lowStockProducts.map((product) => _buildLowStockItem(product)),
        ],
      ),
    );
  }

  Widget _buildLowStockItem(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.statusWarning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.statusWarning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Text(product.imageEmoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Only ${product.stockQuantity} left in stock',
                  style: const TextStyle(
                    color: AppTheme.statusWarning,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _addToCart(product),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusSuccess,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text('Add Now', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAlertsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications, color: AppTheme.primary),
              const SizedBox(width: 8),
              const Text(
                'Price Alerts',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Switch(
                value: _priceAlertsEnabled,
                onChanged: (value) {
                  setState(() {
                    _priceAlertsEnabled = value;
                  });
                  _togglePriceAlerts(value);
                },
                activeThumbColor: AppTheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Get notified when prices drop on items you\'ve viewed or added to cart.',
            style: TextStyle(color: AppTheme.textTertiary, fontSize: 14),
          ),
          const SizedBox(height: 12),
          if (_priceAlerts.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.darkCardHover,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.textTertiary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No price drops yet. We\'ll notify you when prices drop!',
                      style: TextStyle(color: AppTheme.textTertiary),
                    ),
                  ),
                ],
              ),
            )
          else
            ..._priceAlerts.take(3).map((alert) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.darkCardHover,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_down,
                      color: AppTheme.statusSuccess,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${alert.productName}: Price dropped by ${alert.priceDropPercentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '₹${alert.originalPrice.toStringAsFixed(2)} → ₹${alert.newPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppTheme.textTertiary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 50,
                      child: Text(
                        _getTimeAgo(alert.alertTime),
                        style: const TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          if (_priceAlerts.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    // Navigate to full alerts list
                  },
                  child: const Text('View all alerts'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInventoryInsightsSection() {
    // Calculate metrics
    final totalProducts = _allProducts.length;
    final lowStockCount = _lowStockProducts.length;

    // Get unique categories
    final Set<String> categories = {};
    for (var product in _allProducts) {
      if (product.category.isNotEmpty) {
        categories.add(product.category);
      }
    }
    final categoryCount = categories.length;

    // Calculate fresh items percentage (products with good stock)
    final freshCount = _allProducts.where((p) => p.stockQuantity > 10).length;
    final freshPercentage = totalProducts > 0
        ? (freshCount / totalProducts * 100).toInt()
        : 0;

    debugPrint(
      '📊 Inventory Insights - Total: $totalProducts, Low: $lowStockCount, Categories: $categoryCount, Fresh: $freshPercentage%',
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights, color: AppTheme.accentPurple),
              SizedBox(width: 8),
              Text(
                'Inventory Insights',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInsightCard(
                'Total Products',
                totalProducts.toString(),
                Icons.inventory,
                AppTheme.statusSuccess,
              ),
              const SizedBox(width: 12),
              _buildInsightCard(
                'Low Stock',
                lowStockCount.toString(),
                Icons.warning,
                AppTheme.statusWarning,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInsightCard(
                'Categories',
                categoryCount.toString(),
                Icons.category,
                AppTheme.accentBlue,
              ),
              const SizedBox(width: 12),
              _buildInsightCard(
                'Fresh Items',
                '$freshPercentage%',
                Icons.eco,
                AppTheme.statusSuccess,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkCardHover,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: AppTheme.textTertiary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCategory(String category) {
    // Navigate to store screen with category filter
    Navigator.pushNamed(context, '/store', arguments: {'category': category});
  }

  void _addToCart(Product product) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    appState.addToCart(product, context: context);

    // Track product for price alerts
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _priceAlertsEnabled) {
      _priceAlertService.trackProductForPriceAlert(
        user.uid,
        product.id,
        product.name,
        product.price.toDouble(),
      );
    }
  }

  void _togglePriceAlerts(bool enabled) {
    // This would typically involve:
    // 1. Storing user preference in shared preferences or database
    // 2. Setting up background price monitoring
    // 3. Sending notifications when prices drop

    final message = enabled
        ? 'Price alerts enabled! You\'ll be notified of price drops.'
        : 'Price alerts disabled.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.statusSuccess),
    );

    // Update settings in database
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _priceAlertService.setPriceAlertsEnabled(user.uid, enabled);
    }
  }

  Future<void> _checkPriceAlertsEnabled() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final enabled = await _priceAlertService.isPriceAlertsEnabled(user.uid);
      setState(() => _priceAlertsEnabled = enabled);
    }
  }

  void _loadPriceAlerts() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Listen to all price alerts from the shop, not just tracked items
      _priceAlertService.getAllPriceAlerts(user.uid).listen((alerts) {
        setState(() => _priceAlerts = alerts);
      });
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return dateTime.toString().split(' ')[0];
    }
  }

  /// Check for price changes in ALL products and create alerts
  Future<void> _checkPriceChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Track all products in the shop for price monitoring
      final productList = _allProducts
          .map((p) => {'id': p.id, 'name': p.name, 'price': p.price.toDouble()})
          .toList();

      // This will check all products and create alerts for any price drops
      await _priceAlertService.trackAllProductsForPriceAlerts(
        user.uid,
        productList,
      );
    } catch (e) {
      debugPrint('Error checking price changes: $e');
    }
  }
}
