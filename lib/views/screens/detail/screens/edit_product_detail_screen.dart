import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor_store_ap/controllers/product_controller.dart';
import 'package:vendor_store_ap/models/product.dart';

class EditProductDetailScreen extends StatefulWidget {
  final Product product;

  const EditProductDetailScreen({super.key, required this.product});
  @override
  State<EditProductDetailScreen> createState() =>
      _EditProductDetailScreenState();
}

class _EditProductDetailScreenState extends State<EditProductDetailScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ProductController _productController = ProductController();
  late TextEditingController productNameController;
  late TextEditingController productPriceController;
  late TextEditingController productQuantityController;
  late TextEditingController productDescriptionController;
  List<File>? pickedImages;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    productNameController = TextEditingController(
      text: widget.product.productName,
    );
    productPriceController = TextEditingController(
      text: widget.product.productPrice.toString(),
    );
    productQuantityController = TextEditingController(
      text: widget.product.quantity.toString(),
    );
    productDescriptionController = TextEditingController(
      text: widget.product.description,
    );
  }

  @override
  void dispose() {
    productNameController.dispose();
    productPriceController.dispose();
    productQuantityController.dispose();
    productDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final pickedFile = await ImagePicker().pickMultiImage();
    setState(() {
      pickedImages = pickedFile.map((file) => File(file.path)).toList();
    });
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        //upload images to cloundinary
        List<String> uploadedImages =
            pickedImages != null && pickedImages!.isNotEmpty
                ? await _productController.uploadImagesToCloudinary(
                  pickedImages,
                  widget.product,
                )
                : widget.product.images;

        //create an instance of the product model object
        final updatedProduct = Product(
          id: widget.product.id,
          productName: productNameController.text,
          productPrice: int.parse(productPriceController.text),
          quantity: int.parse(productQuantityController.text),
          description: productDescriptionController.text,
          category: widget.product.category,
          vendorId: widget.product.vendorId,
          fullName: widget.product.fullName,
          subCategory: widget.product.subCategory,
          images:
              pickedImages != null && pickedImages!.isNotEmpty
                  ? uploadedImages
                  : widget.product.images,
          averageRating: widget.product.averageRating,
          totalRating: widget.product.totalRating,
        );

        await _productController.updateProduct(
          product: updatedProduct,
          pickedImages: pickedImages,
          context: context,
        );

        // ===== ĐƠN GIẢN: CHỈ CẦN NAVIGATE VỀ EARNING SCREEN =====
        if (mounted) {
          // Pop tất cả screens về MainVendorScreen với tab 0 (EarningScreen)
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating product: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.teal[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Product',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              onPressed: _updateProduct,
              icon: const Icon(Icons.check, color: Colors.white),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            height: 4.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal[300]!, Colors.teal[500]!],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Header
              _buildProductHeader(),

              const SizedBox(height: 20),

              // Product Images Section
              _buildSectionCard(
                title: 'Product Images',
                subtitle: 'Current images and upload new ones',
                icon: CupertinoIcons.photo_fill,
                child: _buildImageSection(),
              ),

              const SizedBox(height: 16),

              // Basic Information Section
              _buildSectionCard(
                title: 'Basic Information',
                subtitle: 'Product name and pricing details',
                icon: CupertinoIcons.info_circle_fill,
                child: _buildBasicInfoSection(),
              ),

              const SizedBox(height: 16),

              // Product Details Section
              _buildSectionCard(
                title: 'Product Details',
                subtitle: 'Category and description',
                icon: CupertinoIcons.doc_text_fill,
                child: _buildDetailsSection(),
              ),

              const SizedBox(height: 24),

              // Update Button
              _buildUpdateButton(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Container(
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
          // Product thumbnail
          Hero(
            tag: 'product_${widget.product.id}',
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
                  widget.product.images.isNotEmpty
                      ? widget.product.images[0]
                      : 'https://via.placeholder.com/150',
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

          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.productName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.product.category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal[700],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.product.productPrice.toStringAsFixed(0)} VND',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.teal[700], size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Section content
          Padding(padding: const EdgeInsets.all(20), child: child),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current images
        if (widget.product.images.isNotEmpty) ...[
          const Text(
            'Current Images',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.product.images.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[100],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.product.images[index],
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
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],

        // New images section
        Row(
          children: [
            const Text(
              'Upload New Images',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _pickImages,
              icon: Icon(
                CupertinoIcons.camera_fill,
                size: 16,
                color: Colors.teal[600],
              ),
              label: Text(
                'Choose Images',
                style: TextStyle(color: Colors.teal[600]),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (pickedImages != null && pickedImages!.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: pickedImages!.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 100,
                  height: 100,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          pickedImages![index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              pickedImages!.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red[600],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        else
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.photo, size: 24, color: Colors.grey[500]),
                const SizedBox(height: 4),
                Text(
                  'No new images selected',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        _buildTextField(
          label: 'Product Name',
          controller: productNameController,
          icon: CupertinoIcons.cube_box,
          validator: (value) => value!.isEmpty ? "Enter product name" : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Price (\$)',
                controller: productPriceController,
                icon: CupertinoIcons.money_dollar,
                keyboardType: TextInputType.number,
                validator:
                    (value) => value!.isEmpty ? "Enter product price" : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                label: 'Quantity',
                controller: productQuantityController,
                icon: CupertinoIcons.number,
                keyboardType: TextInputType.number,
                validator:
                    (value) => value!.isEmpty ? "Enter product quantity" : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category (read-only)
        _buildReadOnlyField(
          label: 'Category',
          value: widget.product.category,
          icon: CupertinoIcons.tag_fill,
        ),
        const SizedBox(height: 16),
        _buildReadOnlyField(
          label: 'Subcategory',
          value: widget.product.subCategory,
          icon: CupertinoIcons.tag_fill,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Description',
          controller: productDescriptionController,
          icon: CupertinoIcons.doc_text,
          maxLines: 4,
          maxLength: 500,
          validator:
              (value) => value!.isEmpty ? "Enter product description" : null,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.teal[600], size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.teal[600]!, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[400]!),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey[600], size: 20),
              const SizedBox(width: 12),
              Text(
                value,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _updateProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal[700],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: Container(
          height: 24,
          child:
              _isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_outlined, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Update Product',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
