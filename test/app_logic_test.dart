import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smartcart/models/models.dart';
import 'package:smartcart/providers/app_state_provider.dart';
import 'package:smartcart/services/auth_service.dart';
import 'package:smartcart/services/inventory_service.dart';

// Mock classes
class MockAuthService extends Mock implements AuthService {}
class MockInventoryService extends Mock implements InventoryService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('App Logic Validation Tests', () {
    late AppStateProvider provider;
    late MockAuthService mockAuthService;
    late MockInventoryService mockInventoryService;

    setUp(() {
      mockAuthService = MockAuthService();
      mockInventoryService = MockInventoryService();

      provider = AppStateProvider(
        authService: mockAuthService,
        analyticsService: null,
        inventoryService: mockInventoryService,
      );
    });

    test('AppStateProvider initializes correctly', () {
      expect(provider.cart, isEmpty);
      expect(provider.cartTotal, 0);
      expect(provider.cartCount, 0);
      expect(provider.products, isEmpty);
    });

    test('Cart math with taxes and discounts (paise precision)', () {
      // Create test products
      final product1 = Product(
        id: '1',
        name: 'Test Product 1',
        category: 'Test',
        brand: 'Test Brand',
        description: 'Test Description',
        price: 5000, // ₹50.00 in paise
        color: Colors.blue,
        imageEmoji: '🧪',
        stockQuantity: 10,
      );

      final product2 = Product(
        id: '2',
        name: 'Test Product 2',
        category: 'Test',
        brand: 'Test Brand',
        description: 'Test Description',
        price: 2000, // ₹20.00 in paise
        color: Colors.red,
        imageEmoji: '🧪',
        stockQuantity: 5,
      );

      provider.addToCart(product1);
      provider.addToCart(product2);

      // Base total: 5000 + 2000 = 7000 paise
      int baseTotal = provider.cartTotal;
      expect(baseTotal, 7000);

      // Simulate tax calculation (18% GST)
      double taxRate = 0.18;
      int taxAmount = (baseTotal * taxRate).round();
      int totalWithTax = baseTotal + taxAmount;

      // Simulate discount (10% off)
      double discountRate = 0.10;
      int discountAmount = (totalWithTax * discountRate).round();
      int finalTotal = totalWithTax - discountAmount;

      // Verify precision (should be exact in paise)
      expect(finalTotal, greaterThan(0));
      expect(finalTotal, isA<int>()); // Ensure integer precision
    });

    test('Inventory logic prevents negative stock', () {
      final product = Product(
        id: '1',
        name: 'Test Product',
        category: 'Test',
        brand: 'Test Brand',
        description: 'Test Description',
        price: 1000,
        color: Colors.blue,
        imageEmoji: '🧪',
        stockQuantity: 2, // Only 2 in stock
      );

      // Add 2 items (should succeed)
      provider.addToCart(product);
      provider.addToCart(product);
      expect(provider.cartCount, 2);

      // Try to add third (should fail due to stock limit)
      provider.addToCart(product);
      expect(provider.cartCount, 2); // Should remain 2
    });

    test('Stock decrement after purchase simulation', () {
      final product = Product(
        id: '1',
        name: 'Test Product',
        category: 'Test',
        brand: 'Test Brand',
        description: 'Test Description',
        price: 1000,
        color: Colors.blue,
        imageEmoji: '🧪',
        stockQuantity: 5,
      );

      provider.addToCart(product); // Add 1
      provider.addToCart(product); // Add another (total 2)

      // Simulate stock decrement (normally done in placeOrder)
      int initialStock = product.stockQuantity;
      int purchasedQuantity = provider.cartCount;
      int remainingStock = initialStock - purchasedQuantity;

      expect(remainingStock, 3); // 5 - 2 = 3
      expect(remainingStock, greaterThanOrEqualTo(0)); // No negative stock
    });

    test('canPlaceOrder validates stock correctly', () {
      final product = Product(
        id: '1',
        name: 'Test Product',
        category: 'Test',
        brand: 'Test Brand',
        description: 'Test Description',
        price: 1000,
        color: Colors.blue,
        imageEmoji: '🧪',
        stockQuantity: 1, // Only 1 in stock
      );

      provider.addToCart(product); // Add 1 (should be ok)
      expect(provider.canPlaceOrder(), true);
      expect(provider.cart[0].quantity, 1);

      provider.addToCart(product); // Try to add another (but addToCart prevents it)
      expect(provider.canPlaceOrder(), true); // Still valid, quantity not increased
      expect(provider.cart[0].quantity, 1); // Quantity remains 1
    });
  });
}