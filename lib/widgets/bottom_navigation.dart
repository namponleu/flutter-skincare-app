import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skincare/providers/cart_provider.dart';
import 'package:skincare/providers/favorite_provider.dart';
import '../lang/index.dart';
import '../constants/app_colors.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Watch bot providers so badge couts auto-update
    final cartCount = context.watch<CartProvider>().itemCount;
    final favoriteCount = context.watch<FavoriteProvider>().favoriteCount;

    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            // borderRadius: const BorderRadius.only(
            //   topLeft: Radius.circular(20),
            //   topRight: Radius.circular(20),
            // ),
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.15),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: T.get(TranslationKeys.home),
                ),
                _buildNavItem(
                  context,
                  index: 1,
                  icon: Icons.favorite_outline,
                  activeIcon: Icons.favorite,
                  label: T.get(TranslationKeys.favorites),
                  badgeCount: favoriteCount,
                ),
                _buildNavItem(
                  context,
                  index: 2,
                  icon: Icons.shopping_cart_outlined,
                  activeIcon: Icons.shopping_cart,
                  label: T.get(TranslationKeys.cart),
                  badgeCount: cartCount,
                ),
                _buildNavItem(
                  context,
                  index: 3,
                  icon: Icons.history_outlined,
                  activeIcon: Icons.history,
                  label: T.get(TranslationKeys.history),
                ),
                _buildNavItem(
                  context,
                  index: 4,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: T.get(TranslationKeys.profile),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    int badgeCount = 0,
  }) {
    final isSelected = currentIndex == index;

    // if (isSelected) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(microseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: isSelected
            ?
              // Active: pill style with icon + label side by side
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIconWithBadge(
                    icon: activeIcon,
                    badgeCount: badgeCount,
                    iconColor: AppColors.brandDark,
                  ),
                  if (label.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.brandDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              )
            // Inactive: column style with icon + label stacked
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIconWithBadge(
                    icon: icon,
                    badgeCount: badgeCount,
                    iconColor: AppColors.brandDark,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.brandDark,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildIconWithBadge({
    required IconData icon,
    required int badgeCount,
    required Color iconColor,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, color: iconColor),
        if (badgeCount > 0)
          Positioned(
            right: -5,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1),
              ),
              // constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                badgeCount > 99 ? '99+' : badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
