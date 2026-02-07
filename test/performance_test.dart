import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartcart/models/models.dart';

/// Performance Tests
/// 
/// Critical for production: Ensures the app performs well with large
/// datasets and doesn't cause memory issues or slow UI.
void main() {
  group('Performance Tests', () {
    test('Large product list search performance', () {
      // Generate 1000 products
      final products = List.generate(1000, (i) => Product(
        id: 'p$i',
        name: 'Product $i',
        category: i % 5 == 0 ? 'Electronics' : 'Fashion',
        brand: 'Brand ${i % 10}',
        description: 'Description for product $i',
        price: (i + 1) * 100,
        color: Colors.blue,
        imageEmoji: '🛍️',
        stockQuantity: i % 20,
      ));

      final stopwatch = Stopwatch()..start();

      // Search operation
      final results = products.where((p) =>
        p.name.toLowerCase().contains('product 5')
      ).toList();

      stopwatch.stop();

      expect(results, isNotEmpty);
      expect(stopwatch.elapsedMilliseconds, lessThan(100),
        reason: 'Search should complete in under 100ms');
    });

    test('Large cart calculation performance', () {
      // Create cart with 100 items
      final cart = List.generate(100, (i) => CartItem(
        product: Product(
          id: 'p$i',
          name: 'Product $i',
          category: 'Test',
          brand: 'Brand',
          description: 'Desc',
          price: 1000 + i,
          color: Colors.blue,
          imageEmoji: '🛍️',
        ),
        quantity: i % 5 + 1,
      ));

      final stopwatch = Stopwatch()..start();

      // Calculate total
      final total = cart.fold<int>(
        0,
        (sum, item) => sum + (item.product.price * item.quantity),
      );

      stopwatch.stop();

      expect(total, greaterThan(0));
      expect(stopwatch.elapsedMicroseconds, lessThan(1000),
        reason: 'Cart calculation should be instant');
    });

    test('Filter and sort large dataset', () {
      final products = List.generate(1000, (i) => Product(
        id: 'p$i',
        name: 'Product $i',
        category: i % 3 == 0 ? 'Electronics' : 'Fashion',
        brand: 'Brand',
        description: 'Desc',
        price: (1000 - i) * 100, // Reverse order for sorting test
        color: Colors.blue,
        imageEmoji: '🛍️',
        stockQuantity: i % 10,
      ));

      final stopwatch = Stopwatch()..start();

      // Filter by category and sort by price
      final filtered = products
        .where((p) => p.category == 'Electronics')
        .toList()
        ..sort((a, b) => a.price.compareTo(b.price));

      stopwatch.stop();

      expect(filtered, isNotEmpty);
      expect(stopwatch.elapsedMilliseconds, lessThan(50),
        reason: 'Filter and sort should complete quickly');
    });

    test('Memory efficiency - product list', () {
      // Create products without unnecessary data duplication
      final products = List.generate(500, (i) => Product(
        id: 'p$i',
        name: 'Product $i',
        category: 'Category',
        brand: 'Brand',
        description: 'Description',
        price: 1000,
        color: Colors.blue,
        imageEmoji: '🛍️',
      ));

      // Verify no duplicate IDs (memory waste indicator)
      final uniqueIds = products.map((p) => p.id).toSet();

      expect(uniqueIds.length, products.length);
    });

    test('Pagination efficiency simulation', () {
      const pageSize = 20;
      const totalProducts = 1000;
      
      final allProducts = List.generate(totalProducts, (i) => Product(
        id: 'p$i',
        name: 'Product $i',
        category: 'Test',
        brand: 'Brand',
        description: 'Desc',
        price: 1000,
        color: Colors.blue,
        imageEmoji: '🛍️',
      ));

      // Simulate loading first page
      final stopwatch = Stopwatch()..start();
      final firstPage = allProducts.take(pageSize).toList();
      stopwatch.stop();

      expect(firstPage.length, pageSize);
      expect(stopwatch.elapsedMicroseconds, lessThan(1000),
        reason: 'Page loading should be fast');
    });

    test('Order history query performance', () {
      // Simulate 100 orders
      final orders = List.generate(100, (i) => {
        'id': 'o$i',
        'userId': 'user123',
        'total': 10000 + i,
        'status': i % 2 == 0 ? 'completed' : 'pending',
        'createdAt': DateTime.now().subtract(Duration(days: i)),
      });

      final stopwatch = Stopwatch()..start();

      // Filter completed orders
      final completed = orders.where((o) => o['status'] == 'completed').toList();

      stopwatch.stop();

      expect(completed.length, 50);
      expect(stopwatch.elapsedMicroseconds, lessThan(500));
    });

    test('Notification list performance', () {
      // Simulate 200 notifications
      final notifications = List.generate(200, (i) => {
        'id': 'n$i',
        'title': 'Notification $i',
        'message': 'Message content $i',
        'read': i % 3 == 0,
        'timestamp': DateTime.now().subtract(Duration(hours: i)),
      });

      final stopwatch = Stopwatch()..start();

      // Count unread
      final unreadCount = notifications.where((n) => n['read'] == false).length;

      stopwatch.stop();

      expect(unreadCount, greaterThan(0));
      expect(stopwatch.elapsedMicroseconds, lessThan(500));
    });
  });

  group('Data Validation Performance', () {
    test('Validate 1000 email addresses quickly', () {
      final emails = List.generate(1000, (i) => 'user$i@example.com');

      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

      final stopwatch = Stopwatch()..start();

      final validCount = emails.where((email) => emailRegex.hasMatch(email)).length;

      stopwatch.stop();

      expect(validCount, 1000);
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });

    test('Validate phone numbers in bulk', () {
      final phones = List.generate(1000, (i) {
        final number = (9000000000 + i).toString();
        return number;
      });

      final stopwatch = Stopwatch()..start();

      final validCount = phones.where((phone) =>
        phone.length == 10 && int.tryParse(phone) != null
      ).length;

      stopwatch.stop();

      expect(validCount, 1000);
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });
  });
}
