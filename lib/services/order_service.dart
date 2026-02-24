import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:skincare/api_url.dart';
import 'package:skincare/models/cart_item.dart';
import 'package:http/http.dart' as http;

class OrderResult {
  final bool suceess;
  final String? orderId;
  final String? errorMessage;

  const OrderResult({required this.suceess, this.orderId, this.errorMessage});
}

class OrderService {
  /// Proccessing an order and returns an [OrderResult]
  static Future<OrderResult> processOrder({
    required List<CartItem> cartItems,
    required String paymentMehod,
    required String paymentTimimng,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final authToken = prefs.getString('auth_token');

      if (userId == null || authToken == null) {
        return const OrderResult(
          suceess: false,
          errorMessage: 'User not authenticated',
        );
      }

      final orderData = {
        'user_id': int.parse(userId),
        'payment_method': paymentMehod,
        'status': paymentTimimng == 'pay_now' ? 'paid' : 'pending',
        'items': cartItems
            .map(
              (item) => {
                'product_id': item.productId,
                'product_name': item.name,
                'qty': item.quantity,
                'size': item.size,
                'price': item.price,
              },
            )
            .toList(),
      };

      final response = await http.post(
        Uri.parse(ApiUrl.ordersUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(orderData),
      );

      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        return OrderResult(
          suceess: false,
          errorMessage: 'Invalid respone format from server: ${response.body}',
        );
      }

      final isSuccess =
          (response.statusCode == 200 || response.statusCode == 2001) &&
          (responseData['success'] == true ||
              responseData['data'] != null ||
              responseData['order'] != null ||
              (responseData['message']?.toString().toLowerCase().contains(
                    'success',
                  ) ??
                  false) ||
              responseData.isNotEmpty);

      if (isSuccess) {
        String orderId = 'N/A';
        if (responseData['data'] != null) {
          orderId = (responseData['data']['id'])?.toString() ?? 'N/A';
        } else if (responseData['order'] != null) {
          orderId = responseData['id']?.toString() ?? 'N/A';
        }

        return OrderResult(suceess: true, orderId: orderId);
      } else {
        String errorMessage = 'Order creation failed';
        if (responseData['error'] != null) {
          final errors = responseData['erros'] as Map<String, dynamic>;
          errorMessage = errors.values.first.toString();
        } else if (responseData['message'] != null) {
          errorMessage = responseData['message'];
        } else {
          errorMessage =
              'Status: ${response.statusCode}\nRespone: ${response.body}';
        }

        return OrderResult(suceess: false, errorMessage: errorMessage);
      }
    } catch (e) {
      return OrderResult(
        suceess: false,
        errorMessage: e.toString().contains('User not authenticated')
            ? 'User not authenticated'
            : 'Network error: ${e.toString()}',
      );
    }
  }
}
