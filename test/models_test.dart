import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartcart/models/models.dart';

void main() {
  group('UserModel Tests', () {
    test('should correctly parse from map', () {
      final data = {
        'email': 'test@example.com',
        'name': 'Test User',
        'role': 'admin',
      };
      
      final user = UserModel.fromMap(data, 'uid123');
      
      expect(user.uid, 'uid123');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.role, UserRole.admin);
    });

    test('should default to customer role if unknown or missing', () {
      final data = {
        'email': 'test@example.com',
        'name': 'Test User',
        'role': 'unknown_role',
      };
      
      final user = UserModel.fromMap(data, 'uid123');
      
      expect(user.role, UserRole.customer);
    });

    test('should serialize to map correctly', () {
      final user = UserModel(
        uid: 'uid123',
        email: 'test@example.com',
        name: 'Test User',
        role: UserRole.counter,
      );
      
      final map = user.toMap();
      
      expect(map['email'], 'test@example.com');
      expect(map['name'], 'Test User');
      expect(map['role'], 'counter');
    });
  });

  group('CartItem Tests', () {
    test('should initialize with quantity 1 by default', () {
      final product = Product(
        id: 'p1',
        name: 'Test Product',
        category: 'Test',
        brand: 'Brand',
        description: 'Desc',
        price: 100,
        color: const Color(0xFF000000),
        imageEmoji: '🍎',
      );
      
      final item = CartItem(product: product);
      
      expect(item.quantity, 1);
      expect(item.product.name, 'Test Product');
    });
    
    test('should initialize with specific quantity', () {
      final product = Product(
        id: 'p1',
        name: 'Test Product',
        category: 'Test',
        brand: 'Brand',
        description: 'Desc',
        price: 100,
        color: const Color(0xFF000000),
        imageEmoji: '🍎',
      );
      
      final item = CartItem(product: product, quantity: 5);
      
      expect(item.quantity, 5);
    });
  });
}
