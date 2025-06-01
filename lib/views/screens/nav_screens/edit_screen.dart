import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendor_store_ap/controllers/product_controller.dart';
import 'package:vendor_store_ap/provider/vendor_product_provider.dart';
import 'package:vendor_store_ap/provider/vendor_provider.dart';
import 'package:vendor_store_ap/views/screens/detail/screens/edit_product_detail_screen.dart';

class EditScreen extends ConsumerStatefulWidget {
  const EditScreen({super.key});

  @override
  ConsumerState<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends ConsumerState<EditScreen> {
  bool _isLoading = false; // ===== THÊM LOADING STATE =====

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

  Future<void> _fetchProduct() async {
    setState(() {
      _isLoading = true; // ===== BẮT ĐẦU LOADING =====
    });

    final vendor = ref.read(vendorProvider);
    final ProductController productController = ProductController();
    try {
      final products = await productController.loadProductByVendor(vendor!.id);
      ref.read(vendorProductProvider.notifier).setProduct(products);
    } catch (e) {
      print('$e');
    } finally {
      setState(() {
        _isLoading = false; // ===== KẾT THÚC LOADING =====
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(vendorProductProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.purple[700],
        title: const Text(
          'My Products',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: IconButton(
                icon: Icon(
                  _isLoading
                      ? CupertinoIcons.hourglass
                      : Icons.refresh, // ===== ICON THAY ĐỔI =====
                  color: Colors.white,
                  size: 20,
                ),
                onPressed:
                    _isLoading
                        ? null
                        : _fetchProduct, // ===== DISABLE KHI LOADING =====
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            height: 4.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple[300]!, Colors.purple[500]!],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
      body:
          _isLoading
              ? _buildLoadingWidget() // ===== HIỂN THỊ LOADING =====
              : products.isEmpty
              ? _buildEmptyState()
              : _buildProductList(products),
    );
  }

  // ===== WIDGET LOADING ĐỚN GIẢN =====
  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.purple[700], strokeWidth: 3),
          const SizedBox(height: 16),
          Text(
            'Loading products...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.purple[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.cube_box,
              size: 60,
              color: Colors.purple[300],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Products Found',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'You haven\'t uploaded any products yet. Start by uploading your first product!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to Upload screen
            },
            icon: const Icon(Icons.add_business_outlined),
            label: const Text('Upload Products'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<dynamic> products) {
    return Column(
      children: [
        // Header with product count
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.cube_box_fill,
                  color: Colors.purple[700],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${products.length} product${products.length > 1 ? 's' : ''} available',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Product list với RefreshIndicator
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchProduct, // ===== PULL TO REFRESH =====
            color: Colors.purple[700],
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductCard(product, index);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(dynamic product, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return EditProductDetailScreen(product: product);
                },
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                Hero(
                  tag: 'product_${product.id}',
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[100],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        product.images[0],
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey[400],
                                size: 30,
                              ),
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
                      // Product name
                      Text(
                        product.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Category with icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.category,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.purple[700],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Price and quantity row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Price
                          Text(
                            '${product.productPrice.toStringAsFixed(0)} VND',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),

                          // Quantity
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  product.quantity > 0
                                      ? Colors.green[50]
                                      : Colors.red[50],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    product.quantity > 0
                                        ? Colors.green[200]!
                                        : Colors.red[200]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  product.quantity > 0
                                      ? Icons.inventory
                                      : Icons.warning_outlined,
                                  size: 14,
                                  color:
                                      product.quantity > 0
                                          ? Colors.green[700]
                                          : Colors.red[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Qty: ${product.quantity}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        product.quantity > 0
                                            ? Colors.green[700]
                                            : Colors.red[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Edit icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: Colors.purple[700],
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
