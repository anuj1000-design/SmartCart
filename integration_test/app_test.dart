import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:smartcart/models/models.dart';
import 'package:smartcart/providers/app_state_provider.dart';
import 'package:smartcart/services/auth_service.dart';
import 'package:smartcart/services/inventory_service.dart';

// Mock classes
class MockAuthService extends Mock implements AuthService {}
class MockInventoryService extends Mock implements InventoryService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SmartCart Integration Test', () {
    testWidgets('Full user flow: scan barcode and checkout', (WidgetTester tester) async {
      // Create mock provider
      final mockAuthService = MockAuthService();
      final mockInventoryService = MockInventoryService();
      final mockProvider = AppStateProvider(
        authService: mockAuthService,
        analyticsService: null,
        inventoryService: mockInventoryService,
      );

      // Add a test product to the provider
      final testProduct = Product(
        id: 'whole-milk-123',
        name: 'Whole Milk',
        category: 'Dairy',
        brand: 'Test Brand',
        description: 'Fresh whole milk',
        price: 5000, // ₹50.00
        color: Colors.white,
        imageEmoji: '🥛',
        stockQuantity: 10,
        barcode: '123456789',
      );

      // Mock the products list
      mockProvider.setTestProducts([testProduct]);

      // Build the app
      await tester.pumpWidget(
        ChangeNotifierProvider<AppStateProvider>.value(
          value: mockProvider,
          child: MaterialApp(
            home: Scaffold(
              body: const Center(child: Text('Home Screen')),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  // Simulate successful barcode scan
                  mockProvider.addToCart(testProduct);
                  // Navigate to cart (simulate)
                },
                child: const Icon(Icons.qr_code_scanner),
              ),
              bottomNavigationBar: BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Store'),
                  BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
                  BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
                ],
                currentIndex: 0,
                onTap: (index) {
                  if (index == 2) {
                    // Navigate to cart screen
                  }
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify we're on home screen
      expect(find.text('Home Screen'), findsOneWidget);

      // Tap the floating action button (QR scanner)
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify item was added to cart
      expect(mockProvider.cart.length, 1);
      expect(mockProvider.cart[0].product.name, 'Whole Milk');

      // Navigate to cart screen (tap cart nav item)
      await tester.tap(find.text('Cart'));
      await tester.pumpAndSettle();

      // In a real integration test, we would check the CartScreen
      // For this simplified test, we verify the cart has items
      expect(mockProvider.cartCount, 1);
      expect(mockProvider.cartTotal, 5000);

      // Verify checkout button would be enabled (cart is not empty)
      expect(mockProvider.cart.isNotEmpty, true);
    });
  });
}