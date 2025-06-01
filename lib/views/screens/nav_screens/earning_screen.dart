import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendor_store_ap/controllers/order_controller.dart';
import 'package:vendor_store_ap/provider/order_provider.dart';
import 'package:vendor_store_ap/provider/total_earning_provider.dart';
import 'package:vendor_store_ap/provider/vendor_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:vendor_store_ap/views/screens/nav_screens/upload_screen.dart';

class EarningScreen extends ConsumerStatefulWidget {
  const EarningScreen({super.key});

  @override
  _EarningScreenState createState() => _EarningScreenState();
}

class _EarningScreenState extends ConsumerState<EarningScreen> {
  bool _isLoading = true;
  int _selectedPeriod = 30;

  @override
  void initState() {
    super.initState();
    // Clear old data trước khi fetch mới
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearOldDataAndFetch();
    });
  }

  // Method mới để clear data cũ và fetch data mới
  void _clearOldDataAndFetch() {
    if (mounted) {
      // Clear tất cả providers trước
      ref.read(orderProvider.notifier).setOrders([]);
      ref.read(totalEarningProvider.notifier).calculateEarning([]);

      // Sau đó fetch data mới
      _fetchOrders();
    }
  }

  // Helper method để safely call setState
  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  Future<void> _fetchOrders() async {
    if (!mounted) return; // Early return nếu widget đã unmounted

    _safeSetState(() {
      _isLoading = true;
    });

    final user = ref.read(vendorProvider);

    // ===== THÊM CHECK USER VALIDITY =====
    if (user == null || user.id.isEmpty) {
      print('No valid user found, skipping fetch');
      _safeSetState(() {
        _isLoading = false;
      });
      return;
    }

    print('=== FETCH ORDERS DEBUG ===');
    print('Current user: ${user.fullName}');
    print('Current user ID: ${user.id}');
    print('========================');

    final OrderController orderController = OrderController();
    try {
      final orders = await orderController.loadOrders(vendorId: user.id);

      // Check if widget is still mounted before updating providers
      if (mounted) {
        if (orders.isEmpty) {
          print('=== NO ORDERS RESULT ===');
          print('User ${user.fullName} has no orders');
          print('=======================');
        } else {
          print('=== SETTING NEW ORDERS ===');
          print('Orders count: ${orders.length}');
          print('=========================');
        }

        ref.read(orderProvider.notifier).setOrders(orders);
        ref.read(totalEarningProvider.notifier).calculateEarning(orders);
      }
    } catch (e) {
      print('=== ERROR FETCHING ORDERS ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('============================');

      // Kiểm tra loại lỗi và xử lý phù hợp
      if (mounted) {
        String errorMessage;

        if (e.toString().contains('Network Error')) {
          errorMessage = 'Network error. Please check your connection.';
        } else if (e.toString().contains('Data Format Error')) {
          errorMessage = 'Data error. Please try again.';
        } else if (e.toString().contains('No orders') ||
            e.toString().contains('404')) {
          // Trường hợp này nên set empty orders thay vì show error
          print('=== TREATING ERROR AS NO ORDERS ===');
          ref.read(orderProvider.notifier).setOrders([]);
          ref.read(totalEarningProvider.notifier).calculateEarning([]);
          _safeSetState(() {
            _isLoading = false;
          });
          return; // Early return, không show error message
        } else {
          errorMessage = 'Failed to load orders. Please try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      _safeSetState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendor = ref.watch(vendorProvider);

    // ===== THÊM VALIDATION CHO VENDOR =====
    if (vendor == null || vendor.id.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          title: Text('Loading...', style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading user data...'),
            ],
          ),
        ),
      );
    }

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
              backgroundImage:
                  vendor.storeImage != ""
                      ? NetworkImage(vendor.storeImage!)
                      : NetworkImage('https://picsum.photos/200'),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Welcome, ${vendor.fullName}!",
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
              if (recentOrders.isNotEmpty)
                TextButton(
                  onPressed: () {
                    // Safe navigation - check mounted before navigation
                    if (!mounted) return;

                    // Chuyển đến trang Orders
                    try {
                      final parent =
                          context
                              .findAncestorStateOfType<State<StatefulWidget>>();
                      if (parent != null && mounted) {
                        final parentState = parent as dynamic;
                        if (parentState.mounted) {
                          parentState.setState(() {
                            parentState._pageIndex = 3; // Orders tab
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
              ? _buildNoOrdersMessage()
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

  Widget _buildNoOrdersMessage() {
    final vendor = ref.watch(vendorProvider);

    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 40,
              color: Colors.blue[300],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'No Orders Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            vendor?.fullName != null
                ? 'Hello ${vendor!.fullName}! You haven\'t received any orders yet.'
                : 'You haven\'t received any orders yet.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
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
                  'Qty: ${order.quantity} • ${order.productPrice.toStringAsFixed(0)} VND',
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
                '${(order.productPrice * order.quantity).toStringAsFixed(0)} VND',
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
