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

      print('=== ORDER CONTROLLER DEBUG ===');
      print('Vendor ID: $vendorId');
      print('Token exists: ${token != null}');
      print('=============================');

      http.Response response = await http.get(
        Uri.parse('$uri/api/orders/vendors/$vendorId'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
          'x-auth-token': token!,
        },
      );

      print('=== API RESPONSE DEBUG ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=========================');

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        if (data.isEmpty) {
          print('=== NO ORDERS FOUND ===');
          print('API returned empty array');
          print('======================');
          return []; // Return empty list thay vì throw exception
        }

        List<Order> orders =
            data.map((order) => Order.fromJson(order)).toList();
        print('=== ORDERS LOADED SUCCESSFULLY ===');
        print('Orders count: ${orders.length}');
        print('================================');
        return orders;
      } else if (response.statusCode == 404) {
        // 404 thường có nghĩa là không tìm thấy orders cho vendor này
        print('=== NO ORDERS FOR VENDOR ===');
        print('404 - No orders found for this vendor');
        print('==============================');
        return []; // Return empty list thay vì throw exception
      } else {
        // Chỉ throw exception cho các lỗi thực sự (500, 401, etc.)
        print('=== REAL API ERROR ===');
        print('Status: ${response.statusCode}');
        print('Response: ${response.body}');
        print('====================');
        throw Exception(
          'Failed to load Orders - Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('=== CATCH BLOCK DEBUG ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('=======================');

      // Kiểm tra xem có phải lỗi network không
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection') ||
          e.toString().contains('Network')) {
        throw Exception('Network Error: Please check your connection');
      }

      // Kiểm tra xem có phải lỗi parsing không
      if (e.toString().contains('FormatException') ||
          e.toString().contains('JSON')) {
        throw Exception('Data Format Error: Please try again');
      }

      // Với các lỗi khác, có thể là không có orders
      if (e.toString().contains('404') ||
          e.toString().contains('Not Found') ||
          e.toString().contains('No orders')) {
        print('=== TREATING AS NO ORDERS ===');
        return []; // Return empty list cho trường hợp này
      }

      // Các lỗi thực sự khác
      throw Exception('Error Loading Orders: ${e.toString()}');
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
