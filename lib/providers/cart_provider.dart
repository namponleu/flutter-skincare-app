import 'package:flutter/material.dart';
import 'package:skincare/models/cart_item.dart';
import 'package:skincare/models/skincare_product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  int get itemCount => _cartItems.length;

  double get subtotal =>
      _cartItems.fold(0, (sum, item) => sum + (item.price) * (item.quantity));

  double get discount => _cartItems.isNotEmpty ? 0.00 : 0.00;
  double get shipping => _cartItems.isNotEmpty ? 0.00 : 0.00;
  double get total => subtotal - discount + shipping;

  /// Return true if product was newly added, false if already in cart
  bool addToCart(SkinCareProduct product) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.id == product.name,
    );

    if (existingIndex == -1) {
      _cartItems.add(
        CartItem(
          id: product.name,
          productId: product.id,
          name: product.name,
          price: product.price,
          quantity: 1,
          image: product.image,
          category: product.category,
          size: 'regular',
        ),
      );
      notifyListeners();
      return true;
    }

    return false; // already in cart
  }

  void incrementQauntity(CartItem item) {
    final index = _cartItems.indexOf(item);
    if (index != -1) {
      _cartItems[index].quantity++;
      notifyListeners();
    }
  }

  void decrementQauntity(CartItem item) {
    final index = _cartItems.indexOf(item);
    if (index != -1) {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      } else {
        _cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeItem(CartItem item) {
    _cartItems.remove(item);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
