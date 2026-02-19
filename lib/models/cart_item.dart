class CartItem {
  final String id;
  final int productId; // Added for API
  final String name;
  final double price;
  int quantity;
  final String image;
  final String category;
  final String? size; // Added for API

  CartItem({
    required this.id,
    required this.productId, // Added for API
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
    required this.category,
    this.size, // Added for API
  });
}
