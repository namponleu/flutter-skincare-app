import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../lang/index.dart';
import '../constants/app_colors.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int favoriteCount;
  final int addToCartCount;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.favoriteCount = 0,
    this.addToCartCount = 0,
  });

  @override
  Widget build(BuildContext context) {
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
                color: Colors.grey.withValues(alpha: 0.1),
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
                  0,
                  Icons.home_outlined,
                  Icons.home,
                  T.get(TranslationKeys.home),
                ),
                _buildNavItem(
                  1,
                  Icons.favorite_outline,
                  Icons.favorite,
                  T.get(TranslationKeys.favorites),
                  showBadge: true,
                  badgeCount: favoriteCount,
                ),
                _buildNavItem(
                  2,
                  Icons.shopping_cart_outlined,
                  Icons.shopping_cart,
                  T.get(TranslationKeys.cart),
                  showBadge: true,
                  badgeCount: addToCartCount,
                ),
                _buildNavItem(
                  3,
                  Icons.history_outlined,
                  Icons.history,
                  T.get(TranslationKeys.history),
                ),
                _buildNavItem(
                  4,
                  Icons.person_outline,
                  Icons.person,
                  T.get(TranslationKeys.profile),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label, {
    bool showBadge = false,
    int badgeCount = 0,
  }) {
    final isSelected = currentIndex == index;

    // if (isSelected) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        // decoration: BoxDecoration(
        //   color: AppColors.brandDark,
        //   borderRadius: BorderRadius.circular(20),
        //   border: Border.all(color: Colors.white, width: 1),
        // ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                // Icon(activeIcon, color: Colors.white, size: 24),
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected
                      ? AppColors.brandDark
                      : Colors.grey.shade600,
                  size: 26,
                ),
                if (showBadge && badgeCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        // favoriteCount.toString(),
                        badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.brandDark : Colors.grey.shade600,
              ),
            ),
            // if (label.isNotEmpty) ...[
            //   const SizedBox(width: 8),
            //   Text(
            //     label,
            //     style: const TextStyle(
            //       color: Colors.white,
            //       fontWeight: FontWeight.w600,
            //       fontSize: 12,
            //     ),
            //   ),
            // ],
          ],
        ),
      ),
    );
    // } else {
    //   return GestureDetector(
    //     onTap: () => onTap(index),
    //     child: Container(
    //       padding: const EdgeInsets.all(12.0),
    //       child: Stack(
    //         children: [
    //           Icon(icon, color: AppColors.brandDark, size: 24),
    //           if (showBadge && favoriteCount > 0)
    //             Positioned(
    //               right: 0,
    //               top: 0,
    //               child: Container(
    //                 padding: const EdgeInsets.all(2),
    //                 decoration: BoxDecoration(
    //                   color: Colors.red,
    //                   borderRadius: BorderRadius.circular(10),
    //                 ),
    //                 constraints: const BoxConstraints(
    //                   minWidth: 16,
    //                   minHeight: 16,
    //                 ),
    //                 child: Text(
    //                   favoriteCount.toString(),
    //                   style: const TextStyle(
    //                     color: Colors.white,
    //                     fontSize: 10,
    //                     fontWeight: FontWeight.bold,
    //                   ),
    //                   textAlign: TextAlign.center,
    //                 ),
    //               ),
    //             ),
    //         ],
    //       ),
    //     ),
    //   );
    // // }
  }
}
