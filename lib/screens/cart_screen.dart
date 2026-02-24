import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import '../widgets/bottom_navigation.dart';
import '../models/cart_item.dart';
import '../lang/index.dart';
import '../api_url.dart';
import '../constants/app_colors.dart';

class CartScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final VoidCallback? onBackPressed;
  final VoidCallback? onCartCleared; // Added callback for cart clearing
  final VoidCallback? onCartChanged;

  const CartScreen({
    super.key,
    required this.cartItems,
    this.onBackPressed,
    this.onCartCleared, // Added callback parameter
    this.onCartChanged,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double get subtotal => widget.cartItems.fold(
    0,
    (sum, item) => sum + (item.price * item.quantity),
  );
  double get discount => widget.cartItems.isNotEmpty ? 0.00 : 0.00;
  double get shipping => widget.cartItems.isNotEmpty ? 0.00 : 0.00;
  double get total => subtotal - discount + shipping;
  bool _isProcessingOrder = false; // Added for loading state

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Column(
          children: [
            // Cart Header with back button and centered title
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Back button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      shape: BoxShape.circle,
                      // border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () {
                        // Call the callback to navigate back to home
                        if (widget.onBackPressed != null) {
                          widget.onBackPressed!();
                        }
                      },
                      iconSize: 20,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Centered title
                  Expanded(
                    child: Text(
                      T.get(TranslationKeys.myCart),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 56), // Balance the back button
                ],
              ),
            ),

            // Cart Items List or Empty State
            Expanded(
              child: widget.cartItems.isEmpty
                  ? _buildEmptyCart()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: widget.cartItems.length,
                      itemBuilder: (context, index) {
                        return _buildCartItem(widget.cartItems[index]);
                      },
                    ),
            ),

            // Order Summary and Checkout (only show if cart has items)
            if (widget.cartItems.isNotEmpty) _buildOrderSummary(),
          ],
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
            onPressed: () {
              // Navigate back to home screen
            },
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

  Widget _buildCartItem(CartItem item) {
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
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.brandDark,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.spa,
                              color: AppColors.brandDark,
                              size: 40,
                            );
                          },
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
                      item.name
                          .split(' ')
                          .first, // Main name (e.g., "Cappuccino")
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    // const SizedBox(height: 4),
                    Text(
                      item.name
                          .split(' ')
                          .skip(1)
                          .join(' '), // Description (e.g., "with Chocolate")
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    // const SizedBox(height: 2),
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandDark,
                      ),
                    ),
                    // const SizedBox(height: 4),
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
                        // Quantity Controls
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Minus button with light gray background
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0E0E0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  size: 12,
                                  color: Colors.black87,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (item.quantity > 1) {
                                      item.quantity--;
                                    } else {
                                      widget.cartItems.remove(item);
                                    }
                                  });
                                  widget.onCartChanged?.call(); // notify parent
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Quantity text (no background)
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Plus button with dark brown background
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.brandDark,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    item.quantity++;
                                  });
                                  widget.onCartChanged?.call();
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                              ),
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
        // Delete Button - positioned at absolute top right
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                widget.cartItems.remove(item);
              });
              widget.onCartChanged?.call();
            },
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
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
          // Order Summary
          Column(
            children: [
              _buildSummaryRow(
                T.get(TranslationKeys.cart),
                '\$${subtotal.toStringAsFixed(2)}',
              ),
              _buildSummaryRow(
                T.get(TranslationKeys.discount),
                '\$${discount.toStringAsFixed(2)}',
              ),
              _buildSummaryRow(
                T.get(TranslationKeys.shipping),
                '\$${shipping.toStringAsFixed(2)}',
              ),
              const Divider(height: 24),
              _buildSummaryRow(
                T.get(TranslationKeys.total),
                '\$${total.toStringAsFixed(2)}',
                isTotal: true,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Checkout Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isProcessingOrder
                  ? null
                  : () {
                      // Show payment method selection dialog
                      _showPaymentMethodDialog();
                    },
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

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
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

  void _showPaymentMethodDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(T.get(TranslationKeys.selectPaymentMethod)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Payment Methods Section
              Text(
                T.get(TranslationKeys.paymentMethods),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),

              // ABA Pay
              ListTile(
                leading: const Icon(Icons.account_balance, color: Colors.blue),
                title: Text(T.get(TranslationKeys.abaPay)),
                subtitle: Text(T.get(TranslationKeys.abaPayDesc)),
                onTap: () {
                  Navigator.of(context).pop(); // Close dialog
                  _showPaymentTimingDialog('ABA Pay');
                },
              ),

              // WING
              ListTile(
                leading: const Icon(Icons.flutter_dash, color: Colors.orange),
                title: Text(T.get(TranslationKeys.wing)),
                subtitle: Text(T.get(TranslationKeys.wingDesc)),
                onTap: () {
                  Navigator.of(context).pop(); // Close dialog
                  _showPaymentTimingDialog('WING');
                },
              ),

              // Credit Card
              ListTile(
                leading: const Icon(Icons.credit_card, color: Colors.green),
                title: Text(T.get(TranslationKeys.creditCard)),
                subtitle: Text(T.get(TranslationKeys.creditCardDesc)),
                onTap: () {
                  Navigator.of(context).pop(); // Close dialog
                  _showPaymentTimingDialog('Credit Card');
                },
              ),

              // Bank Transfer
              ListTile(
                leading: const Icon(Icons.payment, color: Colors.purple),
                title: Text(T.get(TranslationKeys.bankTransfer)),
                subtitle: Text(T.get(TranslationKeys.bankTransferDesc)),
                onTap: () {
                  Navigator.of(context).pop(); // Close dialog
                  _showPaymentTimingDialog('Bank Transfer');
                },
              ),

              // Cash on Delivery
              ListTile(
                leading: const Icon(Icons.wallet, color: Colors.brown),
                title: Text(T.get(TranslationKeys.cashOnDelivery)),
                subtitle: Text(T.get(TranslationKeys.cashOnDeliveryDesc)),
                onTap: () {
                  Navigator.of(context).pop(); // Close dialog
                  _showPaymentTimingDialog('Cash on Delivery');
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(T.get(TranslationKeys.cancel)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPaymentTimingDialog(String paymentMethod) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(T.get(TranslationKeys.selectPaymentTiming)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${T.get(TranslationKeys.selectedPaymentMethod)}: $paymentMethod',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Pay Now Option
              ListTile(
                leading: const Icon(Icons.payment, color: Colors.green),
                title: Text(T.get(TranslationKeys.payNow)),
                subtitle: Text(T.get(TranslationKeys.payNowDesc)),
                onTap: () {
                  Navigator.of(context).pop(); // Close timing dialog
                  _processOrder(paymentMethod, 'pay_now');
                },
              ),

              // Pay in Shop Option
              ListTile(
                leading: const Icon(Icons.store, color: Colors.blue),
                title: Text(T.get(TranslationKeys.payInShop)),
                subtitle: Text(T.get(TranslationKeys.payInShopDesc)),
                onTap: () {
                  Navigator.of(context).pop(); // Close timing dialog
                  _processOrder(paymentMethod, 'pay_in_shop');
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(T.get(TranslationKeys.back)),
              onPressed: () {
                Navigator.of(context).pop();
                _showPaymentMethodDialog(); // Show payment method dialog again
              },
            ),
            TextButton(
              child: Text(T.get(TranslationKeys.cancel)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _processOrder(String paymentMethod, String paymentTiming) async {
    // Show loading state
    setState(() {
      _isProcessingOrder = true;
    });

    try {
      // Get user data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final authToken = prefs.getString('auth_token');

      if (userId == null || authToken == null) {
        throw Exception('User not authenticated');
      }

      // Prepare order data according to API specification
      final orderData = {
        'user_id': int.parse(userId),
        'payment_method': paymentMethod,
        'status': paymentTiming == 'pay_now' ? 'paid' : 'pending',
        'items': widget.cartItems
            .map(
              (item) => {
                'product_id': item.productId,
                'product_name':
                    item.name, // Add product name - this was missing!
                'qty': item.quantity,
                'size': item.size ?? 'regular',
                'price': item.price,
              },
            )
            .toList(),
      };

      // print('Order data being sent: $orderData');

      // Make API call
      final response = await http.post(
        Uri.parse(ApiUrl.ordersUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(orderData),
      );

      // print('Order API Response Status: ${response.statusCode}');
      // print('Order API Response Body: ${response.body}');
      // print('Order API Headers: ${response.headers}');

      // Check if response body is valid JSON
      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
        // print('Parsed JSON successfully: $responseData');
      } catch (e) {
        // print('JSON parsing failed: $e');
        _showErrorDialog(
          'Invalid response format from server: ${response.body}',
        );
        return;
      }

      // Check for success in multiple ways
      bool isSuccess = false;
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['success'] == true) {
          isSuccess = true;
        } else if (responseData['data'] != null) {
          isSuccess = true;
        } else if (responseData['order'] != null) {
          isSuccess = true;
        } else if (responseData['message'] != null &&
            responseData['message'].toString().toLowerCase().contains(
              'success',
            )) {
          isSuccess = true;
        } else if (responseData.isNotEmpty) {
          // If we get any data back with 200/201, treat as success for now
          isSuccess = true;
          // print('Treating as success because we got data with status ${response.statusCode}');
        }
      }

      // print('Order success check: status=${response.statusCode}, success=$isSuccess');

      if (isSuccess) {
        // Order created successfully
        String orderId = 'N/A';

        // Try to extract order ID from various possible structures
        if (responseData['data'] != null) {
          if (responseData['data']['order'] != null) {
            orderId = responseData['data']['order']['id']?.toString() ?? 'N/A';
          } else if (responseData['data']['id'] != null) {
            orderId = responseData['data']['id']?.toString() ?? 'N/A';
          }
        } else if (responseData['order'] != null) {
          orderId = responseData['order']['id']?.toString() ?? 'N/A';
        } else if (responseData['id'] != null) {
          orderId = responseData['id']?.toString() ?? 'N/A';
        }

        // print('Extracted order ID: $orderId');

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
                  '${T.get(TranslationKeys.orderNumber)}: #$orderId',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  '${T.get(TranslationKeys.cartCleared)}',
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
            backgroundColor: AppColors.brand,
            duration: const Duration(seconds: 4),
          ),
        );

        // Clear cart after successful order
        if (widget.onCartCleared != null) {
          widget.onCartCleared!();
        }

        // Navigate back to home screen after successful order
        Future.delayed(const Duration(seconds: 2), () {
          if (widget.onBackPressed != null) {
            widget.onBackPressed!();
          }
        });

        // Show success message with order details
      } else {
        // API error
        // print('Order failed - Status: ${response.statusCode}, Response: $responseData');
        String errorMessage = T.get(TranslationKeys.orderCreationFailed);

        if (responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          errorMessage = errors.values.first.toString();
        } else if (responseData['message'] != null) {
          errorMessage = responseData['message'];
        } else {
          // Show more detailed error information
          errorMessage =
              'Status: ${response.statusCode}\nResponse: ${response.body}';
        }

        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      // Network or other error
      String errorMessage = T.get(TranslationKeys.networkError);
      if (e.toString().contains('User not authenticated')) {
        errorMessage = T.get(TranslationKeys.userNotAuthenticated);
      } else {
        errorMessage =
            '${T.get(TranslationKeys.networkError)}: ${e.toString()}';
      }

      _showErrorDialog(errorMessage);
    } finally {
      // Hide loading state
      setState(() {
        _isProcessingOrder = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
              onPressed: () {
                Navigator.of(context).pop();
              },
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
        );
      },
    );
  }
}
