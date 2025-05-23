import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendor_store_ap/controllers/order_controller.dart';
import 'package:vendor_store_ap/provider/order_provider.dart';
import 'package:vendor_store_ap/provider/total_earning_provider.dart';
import 'package:vendor_store_ap/provider/vendor_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class EarningScreen extends ConsumerStatefulWidget {
  const EarningScreen({super.key});

  @override
  _EarningScreenState createState() => _EarningScreenState();
}

class _EarningScreenState extends ConsumerState<EarningScreen> {
  bool _isLoading = true;
  int _selectedPeriod = 30; // Mặc định hiển thị dữ liệu 30 ngày

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // Helper method để safely call setState
  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  Future<void> _fetchOrders() async {
    _safeSetState(() {
      _isLoading = true;
    });

    final user = ref.read(vendorProvider);
    if (user != null) {
      final OrderController orderController = OrderController();
      try {
        final orders = await orderController.loadOrders(vendorId: user.id);

        // Check if widget is still mounted before updating providers
        if (mounted) {
          ref.read(orderProvider.notifier).setOrders(orders);
          ref.read(totalEarningProvider.notifier).calculateEarning(orders);
        }
      } catch (e) {
        print('Error fetching order: $e');
        // Có thể show snackbar nếu cần
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error fetching orders: $e')));
        }
      } finally {
        _safeSetState(() {
          _isLoading = false;
        });
      }
    } else {
      _safeSetState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendor = ref.watch(vendorProvider);
    final totalEarnings = ref.watch(totalEarningProvider);
    final orders = ref.watch(orderProvider);
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    // Tính toán số liệu bổ sung
    final deliveredOrders = orders.where((order) => order.delivered).length;
    final processingOrders = orders.where((order) => order.processing).length;
    final cancelledOrders =
        orders.where((order) => !order.processing && !order.delivered).length;

    // Tính toán các giá trị phụ từ dữ liệu hiện có
    final double avgOrderValue =
        totalEarnings['totalOrders'] > 0
            ? totalEarnings['totalEarnings'] / totalEarnings['totalOrders']
            : 0.0;

    // Đếm tổng số sản phẩm đã bán (chỉ từ các đơn hàng đã giao)
    int productsSold = 0;
    for (var order in orders) {
      if (order.delivered) {
        productsSold += order.quantity;
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue[800],
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                vendor?.fullName[0].toUpperCase() ?? 'V',
                style: TextStyle(
                  color: Colors.blue[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Welcome, ${vendor?.fullName ?? 'Vendor'}!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchOrders,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
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
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _fetchOrders,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEarningsSummary(
                        totalEarnings,
                        currencyFormat,
                        avgOrderValue,
                        productsSold,
                      ),
                      SizedBox(height: 24),
                      _buildOrderStatusCards(
                        deliveredOrders,
                        processingOrders,
                        cancelledOrders,
                      ),

                      SizedBox(height: 16),

                      _buildRecentOrdersList(orders),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildEarningsSummary(
    Map<String, dynamic> totalEarnings,
    NumberFormat currencyFormat,
    double avgOrderValue,
    int productsSold,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 4),
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
                'Total Earnings',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'All Time',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            currencyFormat.format(totalEarnings['totalEarnings'] ?? 0),
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildEarningInfoBox(
                icon: Icons.shopping_bag_outlined,
                title: 'Orders',
                value: '${totalEarnings['totalOrders'] ?? 0}',
              ),
              _buildEarningInfoBox(
                icon: Icons.shopping_cart_outlined,
                title: 'Products',
                value: productsSold.toString(),
              ),
              _buildEarningInfoBox(
                icon: Icons.person_outline,
                title: 'Avg. Order',
                value: currencyFormat.format(avgOrderValue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningInfoBox({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusCards(int delivered, int processing, int cancelled) {
    return Row(
      children: [
        _buildStatusCard(
          title: 'Delivered',
          count: delivered,
          icon: Icons.check_circle_outline,
          color: Colors.green,
        ),
        SizedBox(width: 12),
        _buildStatusCard(
          title: 'Processing',
          count: processing,
          icon: Icons.hourglass_top,
          color: Colors.blue,
        ),
        SizedBox(width: 12),
        _buildStatusCard(
          title: 'Cancelled',
          count: cancelled,
          icon: Icons.cancel_outlined,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 12),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(int days, String label) {
    final isSelected = _selectedPeriod == days;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _safeSetState(() {
            _selectedPeriod = days;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[700] : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrdersList(List<dynamic> orders) {
    // Lọc 5 đơn hàng gần đây nhất
    final recentOrders = orders.take(5).toList();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 2),
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
                'Recent Orders',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              TextButton(
                onPressed: () {
                  // Safe navigation - check mounted before navigation
                  if (!mounted) return;

                  // Chuyển đến trang Orders - có thể cần điều chỉnh logic này
                  final int orderTabIndex =
                      3; // Index của tab Orders trong bottom navigation

                  // Safer way to handle tab switching
                  try {
                    final parent =
                        context
                            .findAncestorStateOfType<State<StatefulWidget>>();
                    if (parent != null && mounted) {
                      // Nếu sử dụng navigation bar với index
                      final parentState =
                          parent as dynamic; // Danger: dynamic cast
                      if (parentState.mounted) {
                        parentState.setState(() {
                          parentState._pageIndex = orderTabIndex;
                        });
                      }
                    }
                  } catch (e) {
                    print('Cannot switch tab: $e');
                  }
                },
                child: Text('View All'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue[700],
                  padding: EdgeInsets.zero,
                  minimumSize: Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          recentOrders.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No recent orders',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
              : Column(
                children:
                    recentOrders
                        .map((order) => _buildOrderItem(order))
                        .toList(),
              ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(dynamic order) {
    // Xác định màu sắc và biểu tượng dựa trên trạng thái đơn hàng
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (order.delivered) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Delivered';
    } else if (order.processing) {
      statusColor = Colors.blue;
      statusIcon = Icons.hourglass_top;
      statusText = 'Processing';
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusText = 'Cancelled';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                order.image,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey[400],
                    ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.productName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  'Qty: ${order.quantity} • \$${order.productPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${(order.productPrice * order.quantity).toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 14),
                  SizedBox(width: 4),
                  Text(
                    statusText,
                    style: TextStyle(fontSize: 12, color: statusColor),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Cancel any ongoing operations here if needed
    super.dispose();
  }
}
