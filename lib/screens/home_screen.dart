import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:skincare/widgets/product_cart.dart';
import '../widgets/bottom_navigation.dart';
import '../constants/app_colors.dart';
import '../models/skincare_product.dart';
import '../models/banner.dart';
import '../item/array_item.dart';
import '../lang/index.dart';
import '../api_url.dart';
import '../providers/favorite_provider.dart';
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

  // Categories from API
  List<String> _categories = ['All'];
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

  // Unread message count
  int _unreadMessageCount = 0;
  Timer? _messageCountTimer;

  List<SkinCareProduct> get products {
    if (_products.isNotEmpty) return _products;
    if (ArrayItem.products.isNotEmpty) return ArrayItem.products;
    return [];
  }

  List<String> get bannerImages {
    if (_banners.isNotEmpty) {
      return _banners.map((banner) => banner.imageUrl).toList();
    }
    return ArrayItem.bannerImages;
  }

  List<String> get categories => _categories.isNotEmpty ? _categories : ['All'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCategories();
    _loadProducts();
    _loadBanners();
    _loadMessageCount();
    _startMessageCountTimer();
  }

  void _validateCategoryIndex() {
    if (_selectedCategoryIndex >= categories.length) {
      setState(() => _selectedCategoryIndex = 0);
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
        _startMessageCountTimer();
        _loadMessageCount();
        break;
      default:
        _messageCountTimer?.cancel();
        break;
    }
  }

  static const bool _useArrayItemCategories = true;

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categories = ['All'];
      _categoriesError = null;
    });

    if (_useArrayItemCategories) {
      _useFallbackCategories();
      setState(() => _isLoadingCategories = false);
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
            _validateCategoryIndex();
          } else {
            _useFallbackCategories();
          }
        } else {
          _useFallbackCategories();
        }
      } else {
        _useFallbackCategories();
      }
    } catch (e) {
      _useFallbackCategories();
    } finally {
      setState(() => _isLoadingCategories = false);
    }
  }

  void _useFallbackCategories() {
    setState(() {
      if (ArrayItem.categories.isNotEmpty) {
        final firstItem = ArrayItem.categories.first.toLowerCase();
        _categories = (firstItem == 'all' || firstItem == 'all products')
            ? ArrayItem.categories
            : ['All', ...ArrayItem.categories];
      } else {
        _categories = ['All'];
      }
      _categoriesError = null;
    });
    _validateCategoryIndex();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _products = [];
      _productsError = null;
    });

    try {
      final response = await http.get(Uri.parse(ApiUrl.productsUrl));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> productsData = responseData['data'];
          if (productsData.isNotEmpty) {
            final List<SkinCareProduct> loadedProducts = [];
            for (int i = 0; i < productsData.length; i++) {
              try {
                final product = SkinCareProduct.fromJson(productsData[i]);
                if (product.isActive) loadedProducts.add(product);
              } catch (e) {
                debugPrint('Error processing product $i: $e');
              }
            }
            if (loadedProducts.isNotEmpty) {
              setState(() {
                _products = loadedProducts;
                _isLoadingProducts = false;
              });
              return;
            }
          }
          _useFallbackProducts();
        } else {
          _useFallbackProducts();
        }
      } else {
        _useFallbackProducts();
      }
    } catch (e) {
      _useFallbackProducts();
    } finally {
      setState(() => _isLoadingProducts = false);
    }
  }

  void _useFallbackProducts() {
    setState(() {
      _products = ArrayItem.products.isNotEmpty ? ArrayItem.products : [];
      _productsError = null;
    });
  }

  Future<void> _loadBanners() async {
    setState(() {
      _isLoadingBanners = true;
      _banners = [];
      _bannersError = null;
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
              final banner = BannerModel.fromJson(bannersData[i]);
              if (banner.status && banner.imageUrl.isNotEmpty) {
                loadedBanners.add(banner);
              }
            } catch (e) {
              debugPrint('Error processing banner $i: $e');
            }
          }
          setState(() => _banners = loadedBanners);
        } else {
          setState(
            () => _bannersError =
                'Invalid response: ${responseData['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        setState(
          () =>
              _bannersError = 'Failed to load banners: ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() => _bannersError = 'Error loading banners: $e');
    } finally {
      setState(() => _isLoadingBanners = false);
    }
  }

  Future<void> _loadMessageCount() async {
    try {
      final unreadCount = await MessageService.getUnreadCount();
      if (mounted) setState(() => _unreadMessageCount = unreadCount);
    } catch (e) {
      if (mounted) setState(() => _unreadMessageCount = 0);
    }
  }

  void _startMessageCountTimer() {
    _messageCountTimer?.cancel();
    _messageCountTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _loadMessageCount();
    });
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _loadCategories(),
      _loadProducts(),
      _loadBanners(),
      _loadMessageCount(),
    ]);
  }

  void _navigateToMessages() async {
    try {
      final messages = await MessageService.getAllMessages();
      if (messages.isNotEmpty) {
        await MessageService.markMessagesAsRead(messages.first.senderId);
      }
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }

    setState(() => _unreadMessageCount = 0);

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MessagesScreen()),
    );
    _loadMessageCount();
    _startMessageCountTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(children: [Expanded(child: _buildCurrentScreen())]),
          ),
          bottomNavigationBar: BottomNavigation(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            // No need to pass favoriteCount or addToCartCount —
            // BottomNavigation reads them from providers directly ✅
          ),
        );
      },
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
                _buildTopBar(),
                _buildSearchBar(),
                _buildSpecialOffersSection(),
                const SizedBox(height: 10),
                _buildCategoriesSection(),
                const SizedBox(height: 12),
                _buildProductsGrid(),
              ],
            ),
          ),
        );
      case 1:
        // FavoritesScreen reads from FavoriteProvider directly
        return FavoritesScreen(
          favoriteProducts: products
              .where(
                (p) => context
                    .read<FavoriteProvider>()
                    .favoriteProductIds
                    .contains(p.name),
              )
              .toList(),
        );
      case 2:
        return CartScreen(
          onBackPressed: () => setState(() => _currentIndex = 0),
        );
      case 3:
        return const HistoryScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  // UI builders below are unchanged from the previous version

  Widget _buildTopBar() {
    return Container(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, color: AppColors.brandDark, size: 18),
                SizedBox(width: 8),
                Text(
                  'Phnom Penh, Cambodia',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.brandDark,
                  size: 16,
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F1),
              shape: BoxShape.circle,
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
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: T.get(TranslationKeys.searchCoffee),
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 17),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () => setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        }),
                      )
                    : null,
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
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
              onTap: () {},
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
        if (_isLoadingBanners)
          const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (_bannersError != null && _banners.isEmpty)
          SizedBox(
            height: 160,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadBanners,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandDark,
                    ),
                    child: Text(
                      T.get(TranslationKeys.retry),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (bannerImages.isNotEmpty)
          SizedBox(
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
                onPageChanged: (index, _) =>
                    setState(() => _currentOfferIndex = index),
              ),
              items: bannerImages.asMap().entries.map((entry) {
                final isNetworkImage = entry.value.startsWith('http');
                return Builder(
                  builder: (context) => Container(
                    width: MediaQuery.of(context).size.width,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: isNetworkImage
                          ? Image.network(entry.value, fit: BoxFit.cover)
                          : Image.asset(entry.value, fit: BoxFit.cover),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 10),
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
        if (_isLoadingCategories)
          const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (categories.isNotEmpty)
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) => Container(
                margin: const EdgeInsets.only(right: 12),
                child: FilterChip(
                  label: Text(categories[index]),
                  selected: _selectedCategoryIndex == index,
                  selectedColor: AppColors.brandDark,
                  backgroundColor: Colors.white,
                  showCheckmark: false,
                  side: const BorderSide(color: AppColors.brandDark, width: 1),
                  labelStyle: TextStyle(
                    color: _selectedCategoryIndex == index
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onSelected: (_) =>
                      setState(() => _selectedCategoryIndex = index),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductsGrid() {
    if (_isLoadingProducts) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_productsError != null) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProducts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandDark,
                ),
                child: Text(
                  T.get(TranslationKeys.retry),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (products.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No products available',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
      );
    }

    List<SkinCareProduct> filtered = _selectedCategoryIndex == 0
        ? products
        : products
              .where(
                (p) =>
                    p.category ==
                    (categories.length > _selectedCategoryIndex
                        ? categories[_selectedCategoryIndex]
                        : ''),
              )
              .toList();

    filtered = filtered
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    if (filtered.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            _searchQuery.isNotEmpty
                ? 'No products found for "$_searchQuery"'
                : T.get(TranslationKeys.noProductsAvailable),
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
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
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: filtered[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SkinCareDetailScreen(
                  product: filtered[index],
                  // SkinCareDetailScreen can now also use
                  // context.read<CartProvider>().addToCart() directly
                  onAddToCart: () {},
                  onToggleFavorite: () {},
                ),
              ),
            );
          },
        );
      },
    );
  }
}
