import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/skincare_product.dart';
import '../lang/index.dart';
import '../constants/app_colors.dart';

class SkinCareDetailScreen extends StatefulWidget {
  final SkinCareProduct product;
  final VoidCallback? onAddToCart;
  final VoidCallback? onToggleFavorite;

  const SkinCareDetailScreen({
    super.key,
    required this.product,
    this.onAddToCart,
    this.onToggleFavorite,
  });

  @override
  State<SkinCareDetailScreen> createState() => _SkinCareDetailScreenState();
}

class _SkinCareDetailScreenState extends State<SkinCareDetailScreen> {
  bool isFavorite = false;

  static const String _favoritesKey = 'favorite_products';

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  // Check if this product is in favorites
  Future<void> _checkFavoriteStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesList = prefs.getStringList(_favoritesKey) ?? [];
      setState(() {
        isFavorite = favoritesList.contains(widget.product.name);
      });
    } catch (e) {
      print('Error checking favorite status: $e');
    }
  }

  // Toggle favorite status
  Future<void> _toggleFavorite() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesList = prefs.getStringList(_favoritesKey) ?? [];

      setState(() {
        if (isFavorite) {
          favoritesList.remove(widget.product.name);
          isFavorite = false;
        } else {
          favoritesList.add(widget.product.name);
          isFavorite = true;
        }
      });

      await prefs.setStringList(_favoritesKey, favoritesList);

      // Call the callback if provided
      if (widget.onToggleFavorite != null) {
        widget.onToggleFavorite!();
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite
                ? '${widget.product.name} ${T.get(TranslationKeys.addedToFavorites)}'
                : '${widget.product.name} ${T.get(TranslationKeys.removedFromFavorites)}',
          ),
          backgroundColor: isFavorite ? Colors.red[400] : Colors.grey[600],
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  void _handleAddToCart() {
    if (widget.onAddToCart != null) {
      widget.onAddToCart!();
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.product.name} ${T.get(TranslationKeys.addedToCart)}',
        ),
        backgroundColor: AppColors.brandDark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F1),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF7F7F7F)),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
                iconSize: 20,
                padding: const EdgeInsets.all(8),
              ),
            ),
            title: Text(
              T.get(TranslationKeys.coffeeDetail),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image with Rating
                      _buildProductImage(),
                      const SizedBox(height: 16),

                      // Product Name and Price
                      _buildProductInfo(),
                      const SizedBox(height: 16),

                      // Description
                      _buildDescription(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              // Fixed Add to Cart Button at bottom
              Container(
                padding: const EdgeInsets.all(16.0),
                child: _buildAddToCartButton(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductImage() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[200],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.brown[100],
              child: widget.product.image.isNotEmpty
                  ? Image.network(
                      widget.product.image,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.brown[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.brandDark,
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.brown[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.spa,
                            size: 80,
                            color: AppColors.brandDark,
                          ),
                        );
                      },
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.brown[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.spa,
                        size: 80,
                        color: AppColors.brandDark,
                      ),
                    ),
            ),
          ),
          // Rating overlay
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.brandDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.product.rate}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Favorite icon - now interactive
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: _toggleFavorite,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : AppColors.brandDark,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.name.split(' ').first,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                widget.product.name.split(' ').skip(1).join(' '),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
        Text(
          '\$${widget.product.price.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.brandDark,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          T.get(TranslationKeys.description),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        ReadMoreText(
          widget.product.description,
          trimMode: TrimMode.Line,
          trimLines: 2,
          colorClickableText: AppColors.brandDark,
          trimCollapsedText: T.get(TranslationKeys.readMore),
          trimExpandedText: T.get(TranslationKeys.readLess),
          moreStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.brandDark,
          ),
          lessStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.brandDark,
          ),
          style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton() {
    return SizedBox(
      width: 200,
      height: 56,
      child: ElevatedButton(
        onPressed: _handleAddToCart,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          T.get(TranslationKeys.addToCart),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
