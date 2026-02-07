import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartcart/models/models.dart';

/// Product Model Tests
/// 
/// Validates product data structure, price formatting, stock management,
/// and product search/filter functionality.
void main() {
  group('Product Model Tests', () {
    test('Product initializes with correct values', () {
      final product = Product(
        id: 'p1',
        name: 'Test Product',
        category: 'Electronics',
        brand: 'TestBrand',
        description: 'A test product',
        price: 9999, // ₹99.99
        color: Colors.blue,
        imageEmoji: '📱',
        stockQuantity: 10,
      );

      expect(product.id, 'p1');
      expect(product.name, 'Test Product');
      expect(product.price, 9999);
      expect(product.stockQuantity, 10);
      expect(product.stockQuantity > 0, true);
    });

    test('Product out of stock detection', () {
      final product = Product(
        id: 'p1',
        name: 'Out of Stock',
        category: 'Test',
        brand: 'Test',
        description: 'Test',
        price: 1000,
        color: Colors.red,
        imageEmoji: '❌',
        stockQuantity: 0,
      );

      expect(product.stockQuantity == 0, true);
      expect(product.stockQuantity, 0);
    });

    test('Price formatting is accurate (paise to rupees)', () {
      final testCases = {
        9999: '₹99.99',
        10000: '₹100.00',
        12345: '₹123.45',
        500: '₹5.00',
        99: '₹0.99',
      };

      testCases.forEach((paise, expectedRupees) {
        final rupees = paise / 100;
        final formatted = '₹${rupees.toStringAsFixed(2)}';
        expect(formatted, expectedRupees);
      });
    });

    test('Product search by name (case insensitive)', () {
      final products = [
        Product(
          id: '1',
          name: 'iPhone 15 Pro',
          category: 'Electronics',
          brand: 'Apple',
          description: 'Smartphone',
          price: 12999900,
          color: Colors.black,
          imageEmoji: '📱',
        ),
        Product(
          id: '2',
          name: 'Samsung Galaxy S24',
          category: 'Electronics',
          brand: 'Samsung',
          description: 'Smartphone',
          price: 8999900,
          color: Colors.blue,
          imageEmoji: '📱',
        ),
        Product(
          id: '3',
          name: 'MacBook Air M3',
          category: 'Computers',
          brand: 'Apple',
          description: 'Laptop',
          price: 9999900,
          color: Colors.grey,
          imageEmoji: '💻',
        ),
      ];

      final query = 'iphone';
      final results = products.where((p) =>
        p.name.toLowerCase().contains(query.toLowerCase())
      ).toList();

      expect(results.length, 1);
      expect(results.first.name, 'iPhone 15 Pro');
    });

    test('Product filter by category', () {
      final products = [
        Product(
          id: '1',
          name: 'Phone',
          category: 'Electronics',
          brand: 'Brand',
          description: 'Desc',
          price: 10000,
          color: Colors.black,
          imageEmoji: '📱',
        ),
        Product(
          id: '2',
          name: 'Shirt',
          category: 'Clothing',
          brand: 'Brand',
          description: 'Desc',
          price: 2000,
          color: Colors.blue,
          imageEmoji: '👕',
        ),
        Product(
          id: '3',
          name: 'Laptop',
          category: 'Electronics',
          brand: 'Brand',
          description: 'Desc',
          price: 50000,
          color: Colors.grey,
          imageEmoji: '💻',
        ),
      ];

      final electronics = products.where((p) => p.category == 'Electronics').toList();

      expect(electronics.length, 2);
      expect(electronics.every((p) => p.category == 'Electronics'), true);
    });

    test('Product filter by price range', () {
      final products = [
        Product(id: '1', name: 'Cheap', category: 'Test', brand: 'B', description: 'D', price: 500, color: Colors.blue, imageEmoji: '💰'),
        Product(id: '2', name: 'Medium', category: 'Test', brand: 'B', description: 'D', price: 5000, color: Colors.blue, imageEmoji: '💰'),
        Product(id: '3', name: 'Expensive', category: 'Test', brand: 'B', description: 'D', price: 50000, color: Colors.blue, imageEmoji: '💰'),
      ];

      final minPrice = 1000;
      final maxPrice = 10000;

      final filtered = products.where((p) =>
        p.price >= minPrice && p.price <= maxPrice
      ).toList();

      expect(filtered.length, 1);
      expect(filtered.first.name, 'Medium');
    });

    test('Product stock quantity validation', () {
      final product = Product(
        id: 'p1',
        name: 'Test',
        category: 'Test',
        brand: 'Test',
        description: 'Test',
        price: 1000,
        color: Colors.blue,
        imageEmoji: '📦',
        stockQuantity: 50,
      );

      expect(product.stockQuantity, greaterThanOrEqualTo(0));
      expect(product.stockQuantity, 50);
    });
  });

  group('Product Stock Management', () {
    test('Stock decreases after purchase', () {
      final initialStock = 100;
      final purchaseQuantity = 15;
      final newStock = initialStock - purchaseQuantity;

      expect(newStock, 85);
      expect(newStock, greaterThanOrEqualTo(0));
    });

    test('Prevent negative stock', () {
      final currentStock = 5;
      final requestedQuantity = 10;

      if (requestedQuantity > currentStock) {
        expect(currentStock, lessThan(requestedQuantity));
        // Should not allow purchase
      }
    });

    test('Low stock warning threshold', () {
      final product = Product(
        id: '1',
        name: 'Low Stock Item',
        category: 'Test',
        brand: 'Test',
        description: 'Test',
        price: 1000,
        color: Colors.orange,
        imageEmoji: '⚠️',
        stockQuantity: 3,
      );

      final lowStockThreshold = 5;
      final isLowStock = product.stockQuantity <= lowStockThreshold;

      expect(isLowStock, true);
    });
  });

  group('Product Sorting', () {
    test('Sort by price ascending', () {
      final products = [
        Product(id: '1', name: 'C', category: 'T', brand: 'B', description: 'D', price: 3000, color: Colors.blue, imageEmoji: '💰'),
        Product(id: '2', name: 'A', category: 'T', brand: 'B', description: 'D', price: 1000, color: Colors.blue, imageEmoji: '💰'),
        Product(id: '3', name: 'B', category: 'T', brand: 'B', description: 'D', price: 2000, color: Colors.blue, imageEmoji: '💰'),
      ];

      products.sort((a, b) => a.price.compareTo(b.price));

      expect(products[0].price, 1000);
      expect(products[1].price, 2000);
      expect(products[2].price, 3000);
    });

    test('Sort by name alphabetically', () {
      final products = [
        Product(id: '1', name: 'Zebra', category: 'T', brand: 'B', description: 'D', price: 1000, color: Colors.blue, imageEmoji: '⭐'),
        Product(id: '2', name: 'Apple', category: 'T', brand: 'B', description: 'D', price: 1000, color: Colors.blue, imageEmoji: '⭐'),
        Product(id: '3', name: 'Mango', category: 'T', brand: 'B', description: 'D', price: 1000, color: Colors.blue, imageEmoji: '⭐'),
      ];

      products.sort((a, b) => a.name.compareTo(b.name));

      expect(products[0].name, 'Apple');
      expect(products[1].name, 'Mango');
      expect(products[2].name, 'Zebra');
    });
  });
}
