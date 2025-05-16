import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vendor_store_ap/global_variables.dart';
import 'package:vendor_store_ap/models/order.dart';

class OrderController {
  Future<List<Order>> loadOrders({required String vendorId}) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/orders/$vendorId'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
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
}
