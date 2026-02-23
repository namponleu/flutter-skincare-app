import '../models/skincare_product.dart';

class ArrayItem {
  // Categories for filtering - COMMENTED OUT TO TEST DATABASE ONLY
  static const List<String> categories = [
    'All Products',
    'Cleansers',
    'Toners',
    'Serums',
    'Moisturizers',
    'Masks',
    'Sun Protection',
  ];

  // Banner images for slider
  static const List<String> bannerImages = [
    'assets/images/banner/banner.png',
    'assets/images/banner/banner-1.png',
    'assets/images/banner/banner-2.png',
    'assets/images/banner/banner-3.png',
  ];

  // ###### Testing Data

  // Skin care products data - COMMENTED OUT TO TEST DATABASE ONLY
  static final List<SkinCareProduct> products = [
    SkinCareProduct(
      id: 1,
      name: 'Cleansers',
      price: 4.50,
      image: 'https://files.catbox.moe/ogaa9d.png', // Network image fallback
      category: 'Cleansers',
      description: 'Gentle cleanser for daily skincare routine',
      rate: 4.8,
    ),
    SkinCareProduct(
      id: 2,
      name: 'Toners',
      price: 4.99,
      image: 'https://files.catbox.moe/ogaa9d.png', // Network image fallback
      category: 'Toners',
      description: 'Refreshing serum for glowing skin',
      rate: 4.6,
    ),
    SkinCareProduct(
      id: 3,
      name: 'Serums',
      price: 3.99,
      image: 'https://files.catbox.moe/ogaa9d.png', // Network image fallback
      category: 'Serums',
      description: 'Hydrating moisturizer for smooth, soft skin',
      rate: 4.7,
    ),
    SkinCareProduct(
      id: 4,
      name: 'Moisturizers',
      price: 2.99,
      image: 'https://files.catbox.moe/ogaa9d.png', // Network image fallback
      category: 'Moisturizers',
      description: 'Deep cleansing mask for refreshed skin',
      rate: 4.9,
    ),
    SkinCareProduct(
      id: 5,
      name: 'Masks',
      price: 3.50,
      image: 'https://files.catbox.moe/ogaa9d.png', // Network image fallback
      category: 'Masks',
      description: 'Balancing toner for refreshed complexion',
      rate: 4.5,
    ),
    SkinCareProduct(
      id: 6,
      name: 'Sun Protection',
      price: 5.50,
      image: 'https://files.catbox.moe/ogaa9d.png', // Network image fallback
      category: 'Sun Protection',
      description: 'Rich face cream for deep hydration',
      rate: 4.8,
    ),
    SkinCareProduct(
      id: 7,
      name: 'Toners',
      price: 5.50,
      image: 'https://files.catbox.moe/ogaa9d.png', // Network image fallback
      category: 'Toners',
      description: 'Broad spectrum sun protection for daily use',
      rate: 4.8,
    ),
  ];
}
