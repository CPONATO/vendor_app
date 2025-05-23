import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendor_store_ap/models/order.dart';

class OrderProvider extends StateNotifier<List<Order>> {
  OrderProvider() : super([]);

  // Thiết lập toàn bộ danh sách đơn hàng
  void setOrders(List<Order> orders) {
    state = orders;
  }

  // Cập nhật trạng thái của một đơn hàng cụ thể
  void updateOrderStatus({
    required String orderId,
    required bool processing,
    required bool delivered,
  }) {
    // Tạo danh sách mới với đơn hàng được cập nhật
    state =
        state.map((order) {
          if (order.id == orderId) {
            // Tạo đơn hàng mới với trạng thái đã cập nhật
            return Order(
              id: order.id,
              fullName: order.fullName,
              email: order.email,
              state: order.state,
              city: order.city,
              locality: order.locality,
              productName: order.productName,
              productPrice: order.productPrice,
              quantity: order.quantity,
              category: order.category,
              image: order.image,
              buyerId: order.buyerId,
              vendorId: order.vendorId,
              processing: processing,
              delivered: delivered,
            );
          }
          return order;
        }).toList();
  }

  // Đánh dấu đơn hàng đã giao - đặt processing = false, delivered = true
  void markOrderAsDelivered(String orderId) {
    updateOrderStatus(
      orderId: orderId,
      processing: false, // Đặt processing = false khi đơn hàng đã giao
      delivered: true,
    );
  }

  // Hủy đơn hàng - đặt processing = false, delivered = false
  void cancelOrder(String orderId) {
    updateOrderStatus(orderId: orderId, processing: false, delivered: false);
  }

  // Đánh dấu đơn hàng đang xử lý - đặt processing = true, delivered = false
  void markOrderAsProcessing(String orderId) {
    updateOrderStatus(orderId: orderId, processing: true, delivered: false);
  }

  // Tìm một đơn hàng theo ID
  Order? getOrderById(String orderId) {
    try {
      return state.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null; // Trả về null nếu không tìm thấy
    }
  }
}

final orderProvider = StateNotifierProvider<OrderProvider, List<Order>>((ref) {
  return OrderProvider();
});
