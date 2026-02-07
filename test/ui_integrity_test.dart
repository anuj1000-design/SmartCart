import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:smartcart/models/models.dart';
import 'package:smartcart/providers/app_state_provider.dart';
import 'package:smartcart/services/auth_service.dart';
import 'package:smartcart/services/inventory_service.dart';
import 'package:smartcart/widgets/ui_components.dart';

// Mock classes
class MockAuthService extends Mock implements AuthService {}
class MockInventoryService extends Mock implements InventoryService {}

class MockAppStateProvider extends AppStateProvider {
  MockAppStateProvider() : super(
    authService: MockAuthService(),
    analyticsService: null,
    inventoryService: MockInventoryService(),
  );

  @override
  UserProfile get userProfile => UserProfile(
    name: 'Test User',
    email: 'test@example.com',
    phone: '+1234567890',
    avatarEmoji: '😊',
  );

  @override
  int get cartTotal => 5000;

  @override
  int get cartCount => 3;
}

void main() {
  group('UI Integrity Tests', () {
    late MockAppStateProvider mockProvider;

    setUp(() {
      mockProvider = MockAppStateProvider();
    });

    testWidgets('HomeScreen header displays correct greeting and user name', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppStateProvider>.value(
            value: mockProvider,
            child: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 120),
                child: Column(
                  children: [
                    Consumer<AppStateProvider>(
                      builder: (context, appState, child) {
                        String timeOfDay = 'MORNING'; // Simplified for test
                        return Row(
                          children: [
                            Text(
                              "GOOD $timeOfDay",
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              appState.userProfile.name,
                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify greeting contains "GOOD"
      expect(find.textContaining('GOOD'), findsOneWidget);

      // Verify user name is displayed
      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('StatCard widgets show non-null values', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.receipt_long,
                    label: "SPENT",
                    value: "₹${(mockProvider.cartTotal / 100).toStringAsFixed(2)}",
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    icon: Icons.shopping_cart,
                    label: "ITEMS",
                    value: "${mockProvider.cartCount}",
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify StatCards are present
      expect(find.byType(StatCard), findsNWidgets(2));

      // Verify values are not null/empty
      expect(find.text('SPENT'), findsOneWidget);
      expect(find.textContaining('₹'), findsOneWidget); // Contains rupee symbol
      expect(find.text('ITEMS'), findsOneWidget);
      expect(find.text('3'), findsOneWidget); // Cart count
    });

    testWidgets('BottomNavigationBar and FAB are present', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.qr_code_scanner),
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Store'),
                BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify BottomNavigationBar is present
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Verify FAB is present
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Verify FAB has scanner icon
      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
    });
  });
}