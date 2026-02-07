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
  
  group('AppStateProvider Cart Tests', () {
    late AppStateProvider provider;
    late MockAuthService mockAuthService;
    late MockInventoryService mockInventoryService;

    setUp(() {
      mockAuthService = MockAuthService();
      mockInventoryService = MockInventoryService();

      provider = AppStateProvider(
        authService: mockAuthService,
        analyticsService: null, // Disable analytics for testing
        inventoryService: mockInventoryService,
      );
    });

    test('initializes with empty cart', () {
      expect(provider.cart, isEmpty);
      expect(provider.cartTotal, 0);
      expect(provider.cartCount, 0);
    });

    test('adds products to cart and calculates total correctly', () {
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

      // Add products to cart
      provider.addToCart(product1);
      provider.addToCart(product2);

      // Verify cart contents
      expect(provider.cart.length, 2);
      expect(provider.cart[0].product.id, '1');
      expect(provider.cart[0].quantity, 1);
      expect(provider.cart[1].product.id, '2');
      expect(provider.cart[1].quantity, 1);

      // Verify total: 5000 + 2000 = 7000 paise
      expect(provider.cartTotal, 7000);
      expect(provider.cartCount, 2);
    });

    test('removes item from cart and updates total', () {
      // Create and add products
      final product1 = Product(
        id: '1',
        name: 'Test Product 1',
        category: 'Test',
        brand: 'Test Brand',
        description: 'Test Description',
        price: 5000,
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
        price: 2000,
        color: Colors.red,
        imageEmoji: '🧪',
        stockQuantity: 5,
      );

      provider.addToCart(product1);
      provider.addToCart(product2);

      // Verify initial state
      expect(provider.cartTotal, 7000);
      expect(provider.cartCount, 2);

      // Remove one item
      provider.removeFromCart(product1);

      // Verify cart now has only one item
      expect(provider.cart.length, 1);
      expect(provider.cart[0].product.id, '2');
      expect(provider.cartTotal, 2000); // Only product2 remains
      expect(provider.cartCount, 1);
    });

    test('increases quantity when adding same product', () {
      final product = Product(
        id: '1',
        name: 'Test Product',
        category: 'Test',
        brand: 'Test Brand',
        description: 'Test Description',
        price: 5000,
        color: Colors.blue,
        imageEmoji: '🧪',
        stockQuantity: 10,
      );

      provider.addToCart(product);
      provider.addToCart(product);

      expect(provider.cart.length, 1);
      expect(provider.cart[0].quantity, 2);
      expect(provider.cartTotal, 10000); // 5000 * 2
      expect(provider.cartCount, 2);
    });

    test('clears cart', () {
      final product = Product(
        id: '1',
        name: 'Test Product',
        category: 'Test',
        brand: 'Test Brand',
        description: 'Test Description',
        price: 5000,
        color: Colors.blue,
        imageEmoji: '🧪',
        stockQuantity: 10,
      );

      provider.addToCart(product);
      expect(provider.cart.isNotEmpty, true);

      provider.clearCart();
      expect(provider.cart, isEmpty);
      expect(provider.cartTotal, 0);
      expect(provider.cartCount, 0);
    });
  });
}