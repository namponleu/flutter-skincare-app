class Order {
  final int id;
  final String status;
  final String paymentMethod;
  final double totalAmount;
  final DateTime createdAt;
  final int itemsCount;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.status,
    required this.paymentMethod,
    required this.totalAmount,
    required this.createdAt,
    required this.itemsCount,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Helper to parse string or number to double
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    return Order(
      id: json['id'] ?? 0,
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'] ?? '',
      totalAmount: parseDouble(json['total_amount']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      itemsCount:
          json['items_count'] ??
          (json['items'] != null ? (json['items'] as List).length : 0),
      items: json['items'] != null
          ? (json['items'] as List)
                .map((item) => OrderItem.fromJson(item))
                .toList()
          : [],
    );
  }

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get formattedTime {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}

class OrderItem {
  final int id;
  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final double totalPrice;
  final String? size;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    this.size,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Helper to parse string or number to double
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    final price = parseDouble(json['price']);
    final qty = json['qty'] ?? 0;
    final totalPrice = json['total_price'] != null
        ? parseDouble(json['total_price'])
        : price * qty;

    return OrderItem(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      quantity: qty,
      price: price,
      totalPrice: totalPrice,
      size: json['size'],
    );
  }
}
