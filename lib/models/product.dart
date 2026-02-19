import 'package:flutter/material.dart';

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
  final List<String> tags;
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
    this.tags = const [],
    this.stockQuantity = 0,
  });

  factory Product.fromMap(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? 'other',
      brand: data['brand'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble().toInt(),
      // Default color handling since it was hardcoded before
      color: data['color'] != null
          ? Color(data['color'])
          : Colors.grey.shade800,
      imageEmoji: data['imageEmoji'] ?? '📦',
      barcode: data['barcode'],
      stockQuantity: (data['stockQuantity'] ?? 0).toInt(),
      tags: (data['tags'] ?? data['dietaryBadges'] ?? []).cast<String>(),
      isFavorite: data['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'brand': brand,
      'description': description,
      'price': price,
      // ignore: deprecated_member_use
      'color': color.value,
      'imageEmoji': imageEmoji,
      'barcode': barcode,
      'stockQuantity': stockQuantity,
      'tags': tags,
      'isFavorite': isFavorite,
    };
  }
}
