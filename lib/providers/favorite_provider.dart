import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skincare/models/skincare_product.dart';

class FavoriteProvider extends ChangeNotifier {
  final Set<String> _favoriteProductIds = {};
  static const String _favoritesKey = 'favorite_products';

  Set<String> get favoriteProductIds => Set.unmodifiable(_favoriteProductIds);

  int get favoriteCount => _favoriteProductIds.length;

  bool isFavorite(SkinCareProduct product) {
    return _favoriteProductIds.contains(product.name);
  }

  /// Returns true if added, falase if removed
  bool toggleFavorite(SkinCareProduct product) {
    final wasAdded = !_favoriteProductIds.contains(product.name);

    if (wasAdded) {
      _favoriteProductIds.add(product.name);
    } else {
      _favoriteProductIds.remove(product.name);
    }

    notifyListeners();
    _saveFavorites();
    return wasAdded;
  }

  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesList = prefs.getStringList(_favoritesKey) ?? [];
      _favoriteProductIds.addAll(favoritesList);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, _favoriteProductIds.toList());
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }
}
