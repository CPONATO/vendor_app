import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendor_store_ap/global_variables.dart';
import 'package:vendor_store_ap/models/order.dart';
import 'package:vendor_store_ap/services/manage_http_response.dart';

class OrderController {
  Future<List<Order>> loadOrders({required String vendorId}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? token = preferences.getString('auth_token');
      http.Response response = await http.get(
        Uri.parse('$uri/api/orders/vendors/$vendorId'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
          'x-auth-token': token!,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Order> orders =
            data.map((order) => Order.fromJson(order)).toList();
        return orders;
      } else {
        throw Exception('Failed to load Orders');
      }
    } catch (e) {
      throw Exception('Error Loading Orders');
    }
  }

  // Cập nhật để đặt processing = false và delivered = true
  Future<void> UpdateDeliveryStatus({
    required String id,
    required context,
  }) async {
    try {
      // Gọi API để cập nhật trạng thái đã giao
      http.Response deliveredResponse = await http.patch(
        Uri.parse("$uri/api/orders/$id/delivered"),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"delivered": true}),
      );

      // Nếu cập nhật delivered thành công, cập nhật processing = false
      if (deliveredResponse.statusCode == 200) {
        http.Response processingResponse = await http.patch(
          Uri.parse("$uri/api/orders/$id/processing"),
          headers: <String, String>{
            "Content-Type": 'application/json; charset=UTF-8',
          },
          body: jsonEncode({"processing": false}),
        );

        if (processingResponse.statusCode == 200) {
          showSnackBar(context, 'Order marked as delivered');
        } else {
          showSnackBar(
            context,
            'Warning: Order marked as delivered but processing status could not be updated',
          );
        }
      } else {
        showSnackBar(context, 'Failed to update order status');
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // Đã sửa để chỉ đặt processing = false
  Future<void> cancelOrder({required String id, required context}) async {
    try {
      http.Response response = await http.patch(
        Uri.parse("$uri/api/orders/$id/processing"),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"processing": false}),
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Order Canceled');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
