import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendor_store_ap/models/order.dart';

class TotalEarningProvider extends StateNotifier<Map<String, dynamic>> {
  TotalEarningProvider() : super({'totalEarnings': 0.0, 'totalOrders': 0});

  void calculateEarning(List<Order> orders) {
    double earnings = 0.0;
    int orderCount = 0;

    for (Order order in orders) {
      if (order.delivered) {
        orderCount++;
        earnings += order.productPrice * order.quantity;
      }
    }
    state = {'totalEarnings': earnings, 'totalOrders': orderCount};
  }
}

final totalEarningProvider =
    StateNotifierProvider<TotalEarningProvider, Map<String, dynamic>>((ref) {
      return TotalEarningProvider();
    });
