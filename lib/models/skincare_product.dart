import 'package:flutter/material.dart';

class SkinCareProduct {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category;
  final double rate;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Additional fields for skincare products
  final String? brand;
  final String? skinType; // e.g., "Oily", "Dry", "Combination", "Sensitive"
  final String? ingredients; // Ingredients list or description
  final DateTime? expiryDate;
  final int? stock; // Inventory quantity
  final String? volume; // e.g., "50ml", "100ml"

  SkinCareProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    required this.rate,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.brand,
    this.skinType,
    this.ingredients,
    this.expiryDate,
    this.stock,
    this.volume,
  });

  // Factory constructor to create SkinCareProduct from JSON
  factory SkinCareProduct.fromJson(Map<String, dynamic> json) {
    try {
      return SkinCareProduct(
        id: json['id']?.toInt() ?? 0,
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        price: _parseDouble(json['price']), // Handle string or double
        image:
            json['image']?.toString() ??
            '', // Now expects full URL from database
        category: json['category']?.toString() ?? '',
        rate: _parseDouble(json['rate']), // Handle string or double
        isActive: json['is_active'] ?? true,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'].toString())
            : null,
        brand: json['brand']?.toString(),
        skinType: json['skin_type']?.toString() ?? json['skinType']?.toString(),
        ingredients: json['ingredients']?.toString(),
        expiryDate: json['expiry_date'] != null
            ? DateTime.tryParse(json['expiry_date'].toString())
            : (json['expiryDate'] != null
                  ? DateTime.tryParse(json['expiryDate'].toString())
                  : null),
        stock: json['stock']?.toInt() ?? json['quantity']?.toInt(),
        volume: json['volume']?.toString() ?? json['size']?.toString(),
      );
    } catch (e) {
      debugPrint('Error creating SkinCareProduct from JSON: $e');
      debugPrint('JSON data: $json');
      // Return a default product if parsing fails
      return SkinCareProduct(
        id: 0,
        name: 'Error Product',
        description: 'Failed to load product details',
        price: 0.0,
        image: '', // Empty string for network image
        category: 'Error',
        rate: 0.0,
        isActive: false,
        brand: null,
        skinType: null,
        ingredients: null,
        expiryDate: null,
        stock: 0,
        volume: null,
      );
    }
  }

  // Helper method to parse double values from various types
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        debugPrint('Failed to parse double from string: "$value"');
        return 0.0;
      }
    }
    return 0.0;
  }

  // Convert SkinCareProduct to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category': category,
      'rate': rate,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'brand': brand,
      'skin_type': skinType,
      'ingredients': ingredients,
      'expiry_date': expiryDate?.toIso8601String(),
      'stock': stock,
      'volume': volume,
    };
  }
}
