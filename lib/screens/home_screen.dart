import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../widgets/bottom_navigation.dart';
import '../widgets/product_cart.dart';
import '../constants/app_colors.dart';
import '../models/skincare_product.dart';
import '../models/cart_item.dart';
import '../models/banner.dart';
import '../item/array_item.dart';
import '../lang/index.dart';
import '../api_url.dart';
import 'skin_care_detail_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'favorites_screen.dart';
import 'messages_screen.dart';
import 'history_screen.dart';
import '../services/message_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedCategoryIndex = 0;
  int _currentIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  int _currentOfferIndex = 0;

  // Cart functionality
  final List<CartItem> cartItems = [];

  // Favorites functionality
  final Set<String> favoriteProductIds = <String>{};
  static const String _favoritesKey = 'favorite_products';

  // Categories from API
  List<String> _categories = ['All']; // Default with 'All' option
  bool _isLoadingCategories = false;
  String? _categoriesError;

  // Products from API
  List<SkinCareProduct> _products = [];
  bool _isLoadingProducts = false;
  String? _productsError;

  // Banners from API
  List<BannerModel> _banners = [];
  bool _isLoadingBanners = false;
  String? _bannersError;

  // Unread message count for notification badge
  int _unreadMessageCount = 0;

  // Timer for auto-refreshing message count
  Timer? _messageCountTimer;

  // Get products: Admin products from API first, then ArrayItem fallback
  List<SkinCareProduct> get products {
    // If admin has added products via API, use those
    if (_products.isNotEmpty) return _products;
    // If admin hasn't added products, use ArrayItem fallback
    if (ArrayItem.products.isNotEmpty) return ArrayItem.products;
    return []; // Return empty list if no products available anywhere
  }

  // Get banners with fallback to static images
  List<String> get bannerImages {
    if (_banners.isNotEmpty) {
      return _banners.map((banner) => banner.imageUrl).toList();
    }
    return ArrayItem.bannerImages; // Fallback to static images
  }

  // Get categories with 'All' option first
  List<String> get categories => _categories.isNotEmpty ? _categories : ['All'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadFavorites();
    _loadCategories();
    _loadProducts();
    _loadBanners();
    _loadMessageCount();
    _startMessageCountTimer();
  }

  // Safety check for selected category index
  void _validateCategoryIndex() {
    if (_selectedCategoryIndex >= categories.length) {
      setState(() {
        _selectedCategoryIndex = 0; // Reset to 'All' if out of bounds
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _messageCountTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        // App is in foreground, restart timer and refresh message count
        _startMessageCountTimer();
        _loadMessageCount();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App is in background, pause timer to save battery
        _messageCountTimer?.cancel();
        break;
    }
  }

  // Load favorites from persistent storage
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesList = prefs.getStringList(_favoritesKey) ?? [];
      setState(() {
        favoriteProductIds.addAll(favoritesList);
      });
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  // Save favorites to persistent storage
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, favoriteProductIds.toList());
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  // Set to true to force use ArrayItem categories instead of API
  static const bool _useArrayItemCategories =
      true; // Set to true to use ArrayItem categories directly

  // Note: Products are now loaded from API first (admin products)
  // ArrayItem is used as fallback only if admin has no products
  // This flag is kept for reference but no longer used
  @Deprecated('Products now always check API first, then fallback to ArrayItem')
  static const bool _useArrayItemProducts = false;

  // Load categories from API
  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categories = ['All']; // Reset categories to default
      _categoriesError = null; // Clear any previous errors
    });

    // If flag is set, use ArrayItem categories directly
    if (_useArrayItemCategories) {
      _useFallbackCategories();
      setState(() {
        _isLoadingCategories = false;
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse(ApiUrl.productCategoriesUrl));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> categoriesData = responseData['data'];
          if (categoriesData.isNotEmpty) {
            setState(() {
              _categories = [
                'All',
                ...categoriesData.map((cat) => cat.toString()),
              ];
            });
            _validateCategoryIndex(); // Validate category index after loading
          } else {
            // Database returned empty data, use fallback
            _useFallbackCategories();
          }
        } else {
          // Database returned null or invalid format, use fallback
          _useFallbackCategories();
        }
      } else {
        // API request failed, use fallback
        _useFallbackCategories();
      }
    } catch (e) {
      // Network error or other exception, use fallback
      _useFallbackCategories();
    } finally {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  // Use fallback categories from ArrayItem
  void _useFallbackCategories() {
    setState(() {
      if (ArrayItem.categories.isNotEmpty) {
        // Check if ArrayItem already has 'All' or 'All Products'
        final firstItem = ArrayItem.categories.first.toLowerCase();
        if (firstItem == 'all' || firstItem == 'all products') {
          // Use ArrayItem categories as-is
          _categories = ArrayItem.categories;
        } else {
          // Add 'All' at the beginning
          _categories = ['All', ...ArrayItem.categories];
        }
      } else {
        _categories = ['All']; // Ultimate fallback
      }
      _categoriesError = null; // Clear error since we have fallback data
    });
    _validateCategoryIndex();
  }

  // Load products from API
  // Priority: Admin products from API > ArrayItem fallback
  Future<void> _loadProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _products = [];
      _productsError = null; // Clear any previous errors
    });

    try {
      // Always try API first to check if admin has added products
      final response = await http.get(Uri.parse(ApiUrl.productsUrl));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> productsData = responseData['data'];

          if (productsData.isNotEmpty) {
            // Admin has added products - parse and use them
            final List<SkinCareProduct> loadedProducts = [];

            for (int i = 0; i < productsData.length; i++) {
              try {
                final productJson = productsData[i];
                final product = SkinCareProduct.fromJson(productJson);
                if (product.isActive) {
                  loadedProducts.add(product);
                }
              } catch (e) {
                print('Error processing product $i: $e');
                // Continue with other products instead of failing completely
              }
            }

            if (loadedProducts.isNotEmpty) {
              // Admin has products - use them
              setState(() {
                _products = loadedProducts;
                _isLoadingProducts = false;
              });
              print('✅ Using ${loadedProducts.length} products from admin API');
              return;
            }
          }

          // API returned empty array - admin hasn't added products yet
          // Use ArrayItem fallback
          print('ℹ️ Admin has no products, using ArrayItem fallback');
          _useFallbackProducts();
        } else {
          // API response format invalid - use fallback
          print('⚠️ Invalid API response format, using ArrayItem fallback');
          _useFallbackProducts();
        }
      } else {
        // API request failed - use fallback
        print(
          '⚠️ API request failed (${response.statusCode}), using ArrayItem fallback',
        );
        _useFallbackProducts();
      }
    } catch (e) {
      // Network error or other exception - use fallback
      print('⚠️ Network error: $e, using ArrayItem fallback');
      _useFallbackProducts();
    } finally {
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  // Use fallback products from ArrayItem
  void _useFallbackProducts() {
    setState(() {
      _products = ArrayItem.products.isNotEmpty
          ? ArrayItem.products
          : []; // Ultimate fallback
      _productsError = null; // Clear error since we have fallback data
    });
  }

  // Load banners from API
  Future<void> _loadBanners() async {
    setState(() {
      _isLoadingBanners = true;
      _banners = [];
      _bannersError = null; // Clear any previous errors
    });

    try {
      final response = await http.get(Uri.parse(ApiUrl.bannersUrl));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> bannersData = responseData['data'];

          final List<BannerModel> loadedBanners = [];

          for (int i = 0; i < bannersData.length; i++) {
            try {
              final bannerJson = bannersData[i];

              final banner = BannerModel.fromJson(bannerJson);
              if (banner.status && banner.imageUrl.isNotEmpty) {
                loadedBanners.add(banner);
              }
            } catch (e) {
              print('Error processing banner $i: $e'); // Debug log
              // Continue with other banners instead of failing completely
            }
          }

          setState(() {
            _banners = loadedBanners;
          });
        } else {
          setState(() {
            _bannersError =
                'Invalid response format: ${responseData['message'] ?? 'Unknown error'}';
          });
        }
      } else {
        setState(() {
          _bannersError =
              'Failed to load banners: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _bannersError = 'Error loading banners: $e';
      });
    } finally {
      setState(() {
        _isLoadingBanners = false;
      });
    }
  }

  // Retry loading products
  void _retryLoadProducts() {
    _loadProducts();
  }

  // Retry loading banners
  void _retryLoadBanners() {
    _loadBanners();
  }

  // Load message count for notification badge (only unread messages)
  Future<void> _loadMessageCount() async {
    try {
      // Use the dedicated unread count API endpoint
      final unreadCount = await MessageService.getUnreadCount();
      if (mounted) {
        setState(() {
          _unreadMessageCount = unreadCount;
        });
      }
    } catch (e) {
      // Silently fail - don't show error for message count
      if (mounted) {
        setState(() {
          _unreadMessageCount = 0;
        });
      }
    }
  }

  // Start timer to auto-refresh message count every 1 minute
  void _startMessageCountTimer() {
    _messageCountTimer?.cancel(); // Cancel any existing timer
    _messageCountTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      // print('Auto-refreshing message count...');
      _loadMessageCount();
    });
  }

  // Refresh all data (categories, products, banners, and message count)
  Future<void> _refreshData() async {
    await Future.wait([
      _loadCategories(),
      _loadProducts(),
      _loadBanners(),
      _loadMessageCount(),
    ]);
  }

  void _addToCart(SkinCareProduct product) {
    setState(() {
      // Check if item already exists in cart
      final existingItemIndex = cartItems.indexWhere(
        (item) => item.id == product.name,
      );

      if (existingItemIndex == -1) {
        // Add new item
        cartItems.add(
          CartItem(
            id: product.name,
            productId: product.id, // Product ID is now int
            name: product.name,
            price: product.price,
            quantity: 1,
            image: product.image,
            category: product.category,
            size: 'regular', // Default size
          ),
        );

        // Show success message for new item
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${product.name} ${T.get(TranslationKeys.addedToCart)}',
            ),
            backgroundColor: AppColors.brandDark,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Item already exists - show "already added" message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${product.name} ${T.get(TranslationKeys.alreadyInCart)}',
            ),
            backgroundColor: Colors.orange[700],
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _toggleFavorite(SkinCareProduct product, bool isFavorite) {
    setState(() {
      if (isFavorite) {
        favoriteProductIds.add(product.name);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${product.name} ${T.get(TranslationKeys.addedToFavorites)}',
            ),
            backgroundColor: Colors.red[400],
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        favoriteProductIds.remove(product.name);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${product.name} ${T.get(TranslationKeys.removedFromFavorites)}',
            ),
            backgroundColor: Colors.grey[600],
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });

    // Save favorites to persistent storage
    _saveFavorites();
  }

  bool _isFavorite(SkinCareProduct product) {
    return favoriteProductIds.contains(product.name);
  }

  // Navigate to messages screen
  void _navigateToMessages() async {
    // Mark messages as read when notification is clicked
    try {
      final messages = await MessageService.getAllMessages();
      if (messages.isNotEmpty) {
        // Get the sender ID from the first message (assuming all messages are from the same sender - admin)
        final senderId = messages.first.senderId;
        await MessageService.markMessagesAsRead(senderId);
        print('Marked messages as read from sender: $senderId');
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }

    // Clear unread message count badge immediately when clicked
    setState(() {
      _unreadMessageCount = 0;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MessagesScreen()),
    );
    // Refresh message count when returning from messages screen
    _loadMessageCount();
    // Restart timer to ensure it continues running
    _startMessageCountTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Content
                Expanded(child: _buildCurrentScreen()),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigation(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            favoriteCount: favoriteProductIds.length,
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Container(
      // padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
      child: Row(
        children: [
          // Location Selector with shadow and border
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(25),
              // border: Border.all(color: const Color(0xFF7F7F7F)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppColors.brandDark,
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Phnom Penh, Cambodia',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.brandDark,
                  size: 16,
                ),
              ],
            ),
          ),
          const Spacer(),
          // Notification Bell with shadow and border
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F1),
              shape: BoxShape.circle,
              // border: Border.all(color: const Color(0xFF7F7F7F)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.black87,
                    size: 22,
                  ),
                  onPressed: _navigateToMessages,
                  iconSize: 22,
                  padding: const EdgeInsets.all(8),
                ),
                // Unread message count badge
                if (_unreadMessageCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        _unreadMessageCount > 99
                            ? '99+'
                            : _unreadMessageCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // add height
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: const Color(0xFF7F7F7F)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: T.get(TranslationKeys.searchCoffee),
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 17),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
          // Filter button with dark brown background
          Container(
            decoration: BoxDecoration(
              color: AppColors.brandDark,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, color: Colors.white, size: 18),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(T.get(TranslationKeys.filterClicked)),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialOffersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              T.get(TranslationKeys.specialOffers),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                // Handle see all action
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(T.get(TranslationKeys.seeAllClicked)),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Text(
                T.get(TranslationKeys.seeAll),
                style: const TextStyle(
                  color: AppColors.brandDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Show loading state for banners
        if (_isLoadingBanners)
          Container(
            height: 160,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandDark),
              ),
            ),
          )
        // Show error state for banners
        else if (_bannersError != null && _banners.isEmpty)
          Container(
            height: 160,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load banners',
                    style: TextStyle(color: Colors.red[600], fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _retryLoadBanners,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandDark,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      T.get(TranslationKeys.retry),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          )
        // Show banners (either from API or fallback)
        else if (bannerImages.isNotEmpty)
          Container(
            height: 160,
            child: CarouselSlider(
              options: CarouselOptions(
                height: 160,
                viewportFraction: 0.9,
                enlargeCenterPage: true,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentOfferIndex = index;
                  });
                },
              ),
              items: bannerImages.asMap().entries.map((entry) {
                final index = entry.key;
                final imagePath = entry.value;
                final isNetworkImage = imagePath.startsWith('http');

                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            // Background image
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: isNetworkImage
                                    ? Image.network(
                                        imagePath,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color(
                                                    0xFF482F2B + (index * 100),
                                                  ),
                                                  Color(
                                                    0xFF5A3A35 + (index * 100),
                                                  ),
                                                ],
                                              ),
                                            ),
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
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      Color(
                                                        0xFF482F2B +
                                                            (index * 100),
                                                      ),
                                                      Color(
                                                        0xFF5A3A35 +
                                                            (index * 100),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.error_outline,
                                                        color: Colors.white,
                                                        size: 32,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        'Failed to load image',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                      )
                                    : Image.asset(
                                        imagePath,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      Color(
                                                        0xFF482F2B +
                                                            (index * 100),
                                                      ),
                                                      Color(
                                                        0xFF5A3A35 +
                                                            (index * 100),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          )
        // Show no banners message
        else
          Container(
            height: 160,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No banners available',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 10),
        // Page Indicator Dots (only show if we have banners)
        if (bannerImages.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              bannerImages.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentOfferIndex == index
                      ? AppColors.brandDark
                      : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          T.get(TranslationKeys.shopByCategories),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),

        // Show loading state
        if (_isLoadingCategories)
          Container(
            height: 40,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandDark),
              ),
            ),
          )
        // Show error state
        else if (_categoriesError != null)
          Container(
            height: 40,
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      _categoriesError!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _loadCategories,
                  child: Text(
                    T.get(TranslationKeys.retry),
                    style: TextStyle(
                      color: AppColors.brandDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )
        // Show categories
        else if (categories.isNotEmpty)
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(categories[index]),
                    selected: _selectedCategoryIndex == index,
                    selectedColor: AppColors.brandDark,
                    backgroundColor: Colors.white,
                    showCheckmark: false,
                    side: BorderSide(color: AppColors.brandDark, width: 1),
                    labelStyle: TextStyle(
                      color: _selectedCategoryIndex == index
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                    },
                  ),
                );
              },
            ),
          )
        // Show no categories message
        else
          Container(
            height: 40,
            child: Center(
              child: Text(
                'No categories available',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return RefreshIndicator(
          onRefresh: _refreshData,
          color: AppColors.brandDark,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar with Location and Notification
                _buildTopBar(),

                // Search Bar
                _buildSearchBar(),

                // Special Offers Section
                _buildSpecialOffersSection(),
                const SizedBox(height: 10),

                // Categories Section
                _buildCategoriesSection(),
                const SizedBox(height: 12),

                // Products Grid
                _buildProductsGrid(),
              ],
            ),
          ),
        );
      case 1:
        return FavoritesScreen(
          favoriteProducts: products
              .where((product) => favoriteProductIds.contains(product.name))
              .toList(),
        );
      case 2:
        return CartScreen(
          cartItems: cartItems,
          onBackPressed: () {
            setState(() {
              _currentIndex = 0; // Switch back to home tab
            });
          },
          onCartCleared: () {
            setState(() {
              cartItems.clear(); // Clear all cart items
            });
          },
        );
      case 3:
        // Order History Screen
        return const HistoryScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildProductsGrid() {
    // Show loading state
    if (_isLoadingProducts) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandDark),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: Text(
                  T.get(TranslationKeys.loadingProducts),
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show error state
    if (_productsError != null) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Flexible(
                child: Text(
                  _productsError!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _retryLoadProducts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandDark,
                ),
                child: Text(
                  T.get(TranslationKeys.retry),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Check if we have any products at all
    if (products.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Flexible(
                child: Text(
                  'No products available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red[600],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  'Please check your database connection',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // First filter by category
    List<SkinCareProduct> categoryFilteredProducts = _selectedCategoryIndex == 0
        ? products
        : (categories.length > _selectedCategoryIndex
              ? products
                    .where(
                      (product) =>
                          product.category ==
                          categories[_selectedCategoryIndex],
                    )
                    .toList()
              : products);

    // Then filter by search query
    List<SkinCareProduct> filteredProducts = categoryFilteredProducts
        .where(
          (product) =>
              product.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    if (filteredProducts.isEmpty && _searchQuery.isNotEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Flexible(
                child: Text(
                  'No products found for "${_searchQuery}"',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  'Try searching with different keywords',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredProducts.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.spa_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Flexible(
                child: Text(
                  T.get(TranslationKeys.noProductsAvailable),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  T.get(TranslationKeys.checkBackLater),
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: filteredProducts[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SkinCareDetailScreen(
                  product: filteredProducts[index],
                  onAddToCart: () => _addToCart(filteredProducts[index]),
                  onToggleFavorite: () {
                    // Refresh the home screen to update favorite status
                    setState(() {});
                  },
                ),
              ),
            );
          },
          onAddToCart: () => _addToCart(filteredProducts[index]),
          isFavorite: _isFavorite(filteredProducts[index]),
          onFavoriteChanged: (isFavorite) =>
              _toggleFavorite(filteredProducts[index], isFavorite),
        );
      },
    );
  }
}
