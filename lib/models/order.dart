import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'cart_item.dart';
import 'product.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  packed,
  outForDelivery,
  delivered,
  cancelled
}

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

  factory Order.fromMap(Map<String, dynamic> data, String id) {
    return Order(
      id: id,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      items: (data['items'] as List<dynamic>?)?.map((itemData) {
        // Reconstruct a partial Product from the order item data
        final product = Product(
          id: itemData['productId'] ?? 'unknown',
          name: itemData['productName'] ?? 'Unknown Product',
          category: 'Order Item', // Default
          brand: '', // Default
          description: '', // Default
          price: (itemData['price'] ?? 0).toInt(),
          color: Colors.grey.shade800, // Default color used in app
          imageEmoji: '📦', // Default
          stockQuantity: 0, // Not relevant for order history
        );
        return CartItem(
          product: product,
          quantity: (itemData['quantity'] ?? 1).toInt(),
        );
      }).toList() ?? [],
      total: (data['total'] ?? 0).toInt(),
      status: data['status'] ?? 'Pending',
      paymentMethod: data['paymentMethod'] ?? 'UPI',
      paymentStatus: data['paymentStatus'] ?? 'Pending Payment',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': Timestamp.fromDate(date),
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
    };
  }
}
