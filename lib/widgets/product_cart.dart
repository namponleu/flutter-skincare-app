import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/skincare_product.dart';
import '../constants/app_colors.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import '../lang/index.dart';

class ProductCard extends StatelessWidget {
  final SkinCareProduct product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Watch only what this card needs — efficient rebuilds
    final isFavorite = context.watch<FavoriteProvider>().isFavorite(product);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.brandDark, width: 1),
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with rating and favorite
              Expanded(
                flex: 4,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: product.image.isNotEmpty
                          ? Image.network(
                              product.image,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.brown[100],
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                          strokeWidth: 2,
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                Color
                                              >(AppColors.brandDark),
                                        ),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.brown[100],
                                  child: const Icon(
                                    Icons.spa,
                                    size: 40,
                                    color: AppColors.brandDark,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.brown[100],
                              child: const Icon(
                                Icons.coffee,
                                size: 40,
                                color: AppColors.brandDark,
                              ),
                            ),
                    ),

                    // Rating badge
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 10,
                              color: Colors.amber[400],
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${product.rate}',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Favorite button
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () {
                          final wasAdded = context
                              .read<FavoriteProvider>()
                              .toggleFavorite(product);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                wasAdded
                                    ? '${product.name} ${T.get(TranslationKeys.addedToFavorites)}'
                                    : '${product.name} ${T.get(TranslationKeys.removedFromFavorites)}',
                              ),
                              backgroundColor: wasAdded
                                  ? Colors.red[400]
                                  : Colors.grey[600],
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Product info
              Container(
                height: 85,
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      product.description,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brandDark,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            final added = context
                                .read<CartProvider>()
                                .addToCart(product);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  added
                                      ? '${product.name} ${T.get(TranslationKeys.addedToCart)}'
                                      : '${product.name} ${T.get(TranslationKeys.alreadyInCart)}',
                                ),
                                backgroundColor: added
                                    ? AppColors.brandDark
                                    : Colors.orange[700],
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.brandDark,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
