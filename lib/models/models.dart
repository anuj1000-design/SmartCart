import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// 📦 DATA & MODELS
// ---------------------------------------------------------------------------

enum UserRole { customer, admin, counter }

enum DietaryBadge { vegan, glutenFree, organic, keto, lowSodium }

class Product {
  final String id;
  final String name;
  final String category;
  final String brand;
  final String description;
  final int price;
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
}

class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => UserRole.customer,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {'email': email, 'name': name, 'role': role.name};
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class Review {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final double rating; // 1-5
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      rating: (map['rating'] ?? 0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}

// Mock Data
final List<Product> products = [
  // Products are loaded from Firestore
];

// Mock Active Users for Counter
class ActiveUser {
  final String id;
  final String name;
  final int itemCount;
  final int totalAmount;
  final bool isSuspicious;

  ActiveUser({
    required this.id,
    required this.name,
    required this.itemCount,
    required this.totalAmount,
    this.isSuspicious = false,
  });
}

final List<ActiveUser> activeUsers = [
  ActiveUser(
    id: '1',
    name: 'Ravi K.',
    itemCount: 5,
    totalAmount: 450,
    isSuspicious: false,
  ),
  ActiveUser(
    id: '2',
    name: 'Priya S.',
    itemCount: 3,
    totalAmount: 280,
    isSuspicious: false,
  ),
  ActiveUser(
    id: '3',
    name: 'Amit R.',
    itemCount: 7,
    totalAmount: 620,
    isSuspicious: true,
  ),
  ActiveUser(
    id: '4',
    name: 'Sneha M.',
    itemCount: 2,
    totalAmount: 150,
    isSuspicious: false,
  ),
];

// Mock Sales Data for Admin
class SalesData {
  final String day;
  final int sales;

  SalesData({required this.day, required this.sales});
}

final List<SalesData> weeklySales = [
  SalesData(day: 'Mon', sales: 1200),
  SalesData(day: 'Tue', sales: 1500),
  SalesData(day: 'Wed', sales: 1800),
  SalesData(day: 'Thu', sales: 1400),
  SalesData(day: 'Fri', sales: 2000),
  SalesData(day: 'Sat', sales: 2200),
  SalesData(day: 'Sun', sales: 1900),
];

// Mock Recent Activities
final List<String> recentActivities = [
  'Staff_01 verified User_A',
  'Milk added to inventory',
  'Low stock alert: Bread',
  'New user registered: John D.',
  'Payment processed: ₹450',
];

// ---------------------------------------------------------------------------
// 🧠 STATE MANAGEMENT MODELS
// ---------------------------------------------------------------------------

class Order {
  final String id;
  final DateTime date;
  final List<CartItem> items;
  final int total;
  final String status;
  final String paymentMethod; // 'UPI' or 'COD'
  final String paymentStatus; // 'Paid', 'Pending Payment', 'Failed'

  Order({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.status,
    this.paymentMethod = 'UPI',
    this.paymentStatus = 'Pending Payment',
  });
}

class PaymentMethod {
  final String id;
  final String cardNumber;
  final String cardHolder;
  final String expiryDate;

  PaymentMethod({
    required this.id,
    required this.cardNumber,
    required this.cardHolder,
    required this.expiryDate,
  });
}

class Address {
  final String id;
  final String name;
  final String street;
  final String city;
  final String zipCode;
  final String phone;

  Address({
    required this.id,
    required this.name,
    required this.street,
    required this.city,
    required this.zipCode,
    required this.phone,
  });
}

class UserProfile {
  String name;
  String email;
  String phone;
  String avatarEmoji;
  String? photoURL; // Google profile picture URL
  String membershipTier;

  UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarEmoji,
    this.photoURL,
    this.membershipTier = "User",
  });
}
