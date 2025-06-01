import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendor_store_ap/controllers/order_controller.dart';
import 'package:vendor_store_ap/models/order.dart';
import 'package:vendor_store_ap/provider/order_provider.dart';
import 'package:vendor_store_ap/services/manage_http_response.dart';
import 'package:vendor_store_ap/views/screens/nav_screens/order_screen.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  final OrderController _orderController = OrderController();
  bool isUpdating = false;

  // Tạo biến order trong state để có thể cập nhật
  late Order _order;

  @override
  void initState() {
    super.initState();
    // Khởi tạo _order từ widget.order
    _order = widget.order;
  }

  // Phương thức cập nhật UI sau khi order được cập nhật
  void _refreshOrderStatus(bool delivered, bool processing) {
    setState(() {
      // Tạo một Order mới với trạng thái đã cập nhật
      _order = Order(
        id: _order.id,
        fullName: _order.fullName,
        email: _order.email,
        state: _order.state,
        city: _order.city,
        locality: _order.locality,
        productName: _order.productName,
        productPrice: _order.productPrice,
        quantity: _order.quantity,
        category: _order.category,
        image: _order.image,
        buyerId: _order.buyerId,
        vendorId: _order.vendorId,
        processing: processing,
        delivered: delivered,
      );

      isUpdating = false;
    });
  }

  Future<void> _updateDeliveryStatus() async {
    setState(() {
      isUpdating = true;
    });

    try {
      await _orderController.UpdateDeliveryStatus(
        id: _order.id,
        context: context,
      );

      // Cập nhật UI sau khi API thành công
      _refreshOrderStatus(true, false);

      // Cập nhật trạng thái trong provider
      ref.read(orderProvider.notifier).markOrderAsDelivered(_order.id);

      // Trả về kết quả true để thông báo OrderScreen rằng đã có cập nhật
      Navigator.pop(context, true);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return OrderScreen();
          },
        ),
      );
    } catch (e) {
      setState(() {
        isUpdating = false;
      });
      showSnackBar(context, 'Failed to update order: $e');
    }
  }

  Future<void> _cancelOrder() async {
    setState(() {
      isUpdating = true;
    });

    try {
      await _orderController.cancelOrder(id: _order.id, context: context);

      // Cập nhật UI sau khi API thành công
      _refreshOrderStatus(false, false);

      // Cập nhật trạng thái trong provider
      ref.read(orderProvider.notifier).cancelOrder(_order.id);

      // Trả về kết quả true để thông báo OrderScreen rằng đã có cập nhật
      Navigator.pop(context, true);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return OrderScreen();
          },
        ),
      );
    } catch (e) {
      setState(() {
        isUpdating = false;
      });
      showSnackBar(context, 'Failed to cancel order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed:
              () => Navigator.pop(
                context,
                false,
              ), // Trả về false nếu không có thay đổi
        ),
        title: const Text(
          'Order Management',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined, color: Colors.white),
            onPressed: () {
              // Print invoice functionality
              showSnackBar(context, 'Printing invoice...');
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            height: 4.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[300]!, Colors.blue[500]!],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderStatusBar(),
            _buildOrderInfo(),
            _buildProductDetails(),
            _buildShippingDetails(),
            _buildPaymentDetails(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildOrderStatusBar() {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (_order.delivered) {
      statusColor = Colors.green[600]!;
      statusText = 'Delivered';
      statusIcon = CupertinoIcons.checkmark_circle_fill;
    } else if (_order.processing) {
      statusColor = Colors.blue[600]!;
      statusText = 'Processing';
      statusIcon = CupertinoIcons.time_solid;
    } else {
      statusColor = Colors.red[600]!;
      statusText = 'Cancelled';
      statusIcon = CupertinoIcons.xmark_circle_fill;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusDescription(),
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusDescription() {
    if (_order.delivered) {
      return 'This order has been delivered to the customer';
    } else if (_order.processing) {
      return 'This order is currently being processed';
    } else {
      return 'This order has been cancelled';
    }
  }

  Widget _buildOrderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ID: ${_order.id.substring(0, 8)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Order Date', _formatDate(DateTime.now())),
          const SizedBox(height: 8),
          _buildInfoRow('Customer', _order.fullName),
          const SizedBox(height: 8),
          _buildInfoRow('Email', _order.email),
          const SizedBox(height: 8),
          _buildInfoRow('Phone', '+84 *** *** ***'), // Placeholder for phone
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetails() {
    // Calculate commission and vendor earnings
    final subtotal = _order.productPrice * _order.quantity;
    final platformFee = subtotal * 0.05; // Example: 5% platform fee
    final vendorEarnings = subtotal - platformFee;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: Image.network(
                    _order.image,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (ctx, error, _) => Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey[400],
                            size: 30,
                          ),
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _order.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Category: ${_order.category}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quantity: ${_order.quantity}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_order.productPrice.toStringAsFixed(0)} VND / item',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          // Order summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Customer Paid', style: TextStyle(fontSize: 14)),
              Text(
                '${subtotal.toStringAsFixed(0)} VND',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Platform Fee (5%)',
                style: TextStyle(fontSize: 14, color: Colors.red),
              ),
              Text(
                '-${platformFee.toStringAsFixed(0)} VND',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Earnings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${vendorEarnings.toStringAsFixed(0)} VND',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShippingDetails() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.location_solid,
                  color: Colors.blue[700],
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Address:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _order.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_order.locality}, ${_order.city}, ${_order.state}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _order.delivered ? _buildDeliveryConfirmation() : Container(),
        ],
      ),
    );
  }

  Widget _buildDeliveryConfirmation() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Confirmed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                Text(
                  'This order was delivered on ${_formatDate(DateTime.now())}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.money_dollar_circle,
                  color: Colors.green[700],
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cash on Delivery',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _order.delivered
                        ? 'Payment has been collected from the customer'
                        : 'Payment will be collected upon delivery',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _order.delivered
              ? Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: Colors.green[700],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Your earnings have been added to your balance',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : Container(),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    if (isUpdating) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_order.delivered) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Contact buyer functionality
                    showSnackBar(context, 'Contacting buyer...');
                  },
                  icon: const Icon(CupertinoIcons.chat_bubble_text),
                  label: const Text('Contact Buyer'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_order.processing && !_order.delivered) {
      // Đơn hàng đã bị hủy
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Contact buyer functionality
                    showSnackBar(context, 'Contacting buyer...');
                  },
                  icon: const Icon(CupertinoIcons.chat_bubble_text),
                  label: const Text('Contact Buyer'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Nút Mark as Delivered
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _updateDeliveryStatus,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Mark as Delivered'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Nút Cancel Order
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Hiển thị dialog xác nhận trước khi hủy
                  showDialog(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
                          title: const Text('Cancel Order'),
                          content: const Text(
                            'Are you sure you want to cancel this order? This action cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: Text(
                                'No, Keep It',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                _cancelOrder();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[600],
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Yes, Cancel Order'),
                            ),
                          ],
                        ),
                  );
                },
                icon: const Icon(CupertinoIcons.trash),
                label: const Text('Cancel Order'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red[700],
                  side: BorderSide(color: Colors.red[700]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
