import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../lang/index.dart';
import '../constants/app_colors.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const CartScreen({super.key, this.onBackPressed});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isProcessingOrder = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F1F1),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF7F7F7F)),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.grey,
                          ),
                          onPressed: widget.onBackPressed,
                          iconSize: 20,
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          T.get(TranslationKeys.myCart),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 56),
                    ],
                  ),
                ),

                // Cart items or empty state
                Expanded(
                  child: cart.cartItems.isEmpty
                      ? _buildEmptyCart()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: cart.cartItems.length,
                          itemBuilder: (context, index) {
                            return _buildCartItem(
                              context,
                              cart,
                              cart.cartItems[index],
                            );
                          },
                        ),
                ),

                // Order summary
                if (cart.cartItems.isNotEmpty)
                  _buildOrderSummary(context, cart),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            T.get(TranslationKeys.yourCartIsEmpty),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            T.get(TranslationKeys.addCoffeeToCart),
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.onBackPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(
              T.get(TranslationKeys.browseCoffee),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartProvider cart, item) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.4),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.brown[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.image.isNotEmpty
                      ? Image.network(
                          item.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.spa,
                                color: AppColors.brandDark,
                                size: 40,
                              ),
                        )
                      : const Icon(
                          Icons.coffee,
                          color: AppColors.brandDark,
                          size: 40,
                        ),
                ),
              ),
              const SizedBox(width: 16),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name.split(' ').first,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item.name.split(' ').skip(1).join(' '),
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandDark,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${item.category} | ${T.get(TranslationKeys.qty)}: ${item.quantity}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        // Quantity controls
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _quantityButton(
                              color: const Color(0xFFE0E0E0),
                              icon: Icons.remove,
                              iconColor: Colors.black87,
                              onTap: () => cart.decrementQauntity(item),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _quantityButton(
                              color: AppColors.brandDark,
                              icon: Icons.add,
                              iconColor: Colors.white,
                              onTap: () => cart.incrementQauntity(item),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Delete button
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: () => cart.removeItem(item),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ),
      ],
    );
  }

  Widget _quantityButton({
    required Color color,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 12, color: iconColor),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          _summaryRow(
            T.get(TranslationKeys.cart),
            '\$${cart.subtotal.toStringAsFixed(2)}',
          ),
          _summaryRow(
            T.get(TranslationKeys.discount),
            '\$${cart.discount.toStringAsFixed(2)}',
          ),
          _summaryRow(
            T.get(TranslationKeys.shipping),
            '\$${cart.shipping.toStringAsFixed(2)}',
          ),
          const Divider(height: 24),
          _summaryRow(
            T.get(TranslationKeys.total),
            '\$${cart.total.toStringAsFixed(2)}',
            isTotal: true,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isProcessingOrder
                  ? null
                  : () => _showPaymentMethodDialog(context, cart),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isProcessingOrder
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      T.get(TranslationKeys.orderNow),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.brandDark : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodDialog(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(T.get(TranslationKeys.selectPaymentMethod)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              T.get(TranslationKeys.paymentMethods),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _paymentTile(
              context,
              cart,
              Icons.account_balance,
              Colors.blue,
              T.get(TranslationKeys.abaPay),
              T.get(TranslationKeys.abaPayDesc),
              'ABA Pay',
            ),
            _paymentTile(
              context,
              cart,
              Icons.flutter_dash,
              Colors.orange,
              T.get(TranslationKeys.wing),
              T.get(TranslationKeys.wingDesc),
              'WING',
            ),
            _paymentTile(
              context,
              cart,
              Icons.credit_card,
              Colors.green,
              T.get(TranslationKeys.creditCard),
              T.get(TranslationKeys.creditCardDesc),
              'Credit Card',
            ),
            _paymentTile(
              context,
              cart,
              Icons.payment,
              Colors.purple,
              T.get(TranslationKeys.bankTransfer),
              T.get(TranslationKeys.bankTransferDesc),
              'Bank Transfer',
            ),
            _paymentTile(
              context,
              cart,
              Icons.wallet,
              Colors.brown,
              T.get(TranslationKeys.cashOnDelivery),
              T.get(TranslationKeys.cashOnDeliveryDesc),
              'Cash on Delivery',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(T.get(TranslationKeys.cancel)),
          ),
        ],
      ),
    );
  }

  ListTile _paymentTile(
    BuildContext context,
    CartProvider cart,
    IconData icon,
    Color color,
    String title,
    String subtitle,
    String method,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () {
        Navigator.of(context).pop();
        _showPaymentTimingDialog(context, cart, method);
      },
    );
  }

  void _showPaymentTimingDialog(
    BuildContext context,
    CartProvider cart,
    String paymentMethod,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(T.get(TranslationKeys.selectPaymentTiming)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${T.get(TranslationKeys.selectedPaymentMethod)}: $paymentMethod',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.payment, color: Colors.green),
              title: Text(T.get(TranslationKeys.payNow)),
              subtitle: Text(T.get(TranslationKeys.payNowDesc)),
              onTap: () {
                Navigator.of(context).pop();
                _processOrder(context, cart, paymentMethod, 'pay_now');
              },
            ),
            ListTile(
              leading: const Icon(Icons.store, color: Colors.blue),
              title: Text(T.get(TranslationKeys.payInShop)),
              subtitle: Text(T.get(TranslationKeys.payInShopDesc)),
              onTap: () {
                Navigator.of(context).pop();
                _processOrder(context, cart, paymentMethod, 'pay_in_shop');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showPaymentMethodDialog(context, cart);
            },
            child: Text(T.get(TranslationKeys.back)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(T.get(TranslationKeys.cancel)),
          ),
        ],
      ),
    );
  }

  Future<void> _processOrder(
    BuildContext context,
    CartProvider cart,
    String paymentMethod,
    String paymentTiming,
  ) async {
    setState(() => _isProcessingOrder = true);

    final result = await OrderService.processOrder(
      cartItems: cart.cartItems.toList(),
      paymentMehod: paymentMethod,
      paymentTimimng: paymentTiming,
    );

    setState(() => _isProcessingOrder = false);

    if (!mounted) return;

    if (result.suceess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                T.get(TranslationKeys.orderPlacedSuccessfully),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${T.get(TranslationKeys.orderNumber)}: #${result.orderId}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          backgroundColor: AppColors.brand,
          duration: const Duration(seconds: 4),
        ),
      );

      // Clear cart via provider
      cart.clearCart();

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) widget.onBackPressed?.call();
      });
    } else {
      _showErrorDialog(context, result.errorMessage ?? 'Unknown error');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            Text(
              T.get(TranslationKeys.error),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              T.get(TranslationKeys.ok),
              style: const TextStyle(
                color: AppColors.brand,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
