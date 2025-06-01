import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor_store_ap/controllers/category_controller.dart';
import 'package:vendor_store_ap/controllers/product_controller.dart';
import 'package:vendor_store_ap/controllers/subcategory_controller.dart';
import 'package:vendor_store_ap/models/category.dart';
import 'package:vendor_store_ap/models/subcategory.dart';
import 'package:vendor_store_ap/provider/vendor_provider.dart';
import 'package:vendor_store_ap/services/manage_http_response.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final ProductController _productController = ProductController();
  final ImagePicker picker = ImagePicker();

  late Future<List<Category>> futureCategories;
  Future<List<Subcategory>>? futureSubcategories;

  Category? selectedCategory;
  Subcategory? selectedSubcategory;

  String productName = '';
  int productPrice = 0;
  int quantity = 0;
  String description = '';
  bool isLoading = false;
  List<File> images = [];

  @override
  void initState() {
    super.initState();
    futureCategories = CategoryController().loadCategories();
  }

  chooseImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        images.add(File(pickedFile.path));
      });
    }
  }

  getSubcategoryByCategory(Category category) {
    futureSubcategories = SubcategoryController().getSubCategoryByCategoryName(
      category.name,
    );
  }

  void resetForm() {
    setState(() {
      productName = '';
      productPrice = 0;
      quantity = 0;
      description = '';
      images.clear();
      selectedCategory = null;
      selectedSubcategory = null;
      futureSubcategories = null;
      isLoading = false;
    });
    _formkey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigo[700],
        title: const Text(
          'Upload Product',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            height: 4.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo[300]!, Colors.indigo[500]!],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Container(
                width: double.infinity,
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
                        color: Colors.indigo[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.cloud_upload_fill,
                        color: Colors.indigo[700],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add New Product',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fill in the details below to upload your product',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Product Images Section
              _buildSectionCard(
                title: 'Product Images',
                subtitle: 'Add up to 5 images of your product',
                icon: CupertinoIcons.photo_fill,
                child: _buildImageSection(),
              ),

              const SizedBox(height: 16),

              // Basic Information Section
              _buildSectionCard(
                title: 'Basic Information',
                subtitle: 'Enter product name and pricing details',
                icon: CupertinoIcons.info_circle_fill,
                child: _buildBasicInfoSection(),
              ),

              const SizedBox(height: 16),

              // Category Section
              _buildSectionCard(
                title: 'Category & Classification',
                subtitle: 'Select the appropriate category for your product',
                icon: CupertinoIcons.tag_fill,
                child: _buildCategorySection(),
              ),

              const SizedBox(height: 16),

              // Description Section
              _buildSectionCard(
                title: 'Product Description',
                subtitle: 'Provide detailed information about your product',
                icon: CupertinoIcons.doc_text_fill,
                child: _buildDescriptionSection(),
              ),

              const SizedBox(height: 24),

              // Upload Button
              _buildUploadButton(),

              const SizedBox(height: 40),
            ],
          ),
        ),
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
                    color: Colors.indigo[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.indigo[700], size: 20),
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
          Padding(padding: const EdgeInsets.all(20), child: child),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (images.isEmpty) _buildImagePlaceholder() else _buildImageGrid(),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return GestureDetector(
      onTap: chooseImage,
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.camera_fill, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Tap to add product images',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add at least one image',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        return index == 0
            ? _buildAddImageButton()
            : _buildImageItem(images[index - 1], index - 1);
      },
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: chooseImage,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.indigo[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.indigo[200]!,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 28,
              color: Colors.indigo[600],
            ),
            const SizedBox(height: 4),
            Text(
              'Add',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.indigo[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(File image, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              image,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  images.removeAt(index);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red[600],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        _buildTextField(
          label: 'Product Name',
          hint: 'Enter product name',
          icon: CupertinoIcons.cube_box,
          onChanged: (value) => productName = value,
          validator: (value) => value!.isEmpty ? "Enter Product Name" : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Price (VND)',
                hint: '000',
                icon: CupertinoIcons.money_dollar,
                keyboardType: TextInputType.number,
                onChanged: (value) => productPrice = int.tryParse(value) ?? 0,
                validator:
                    (value) => value!.isEmpty ? "Enter Product Price" : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                label: 'Quantity',
                hint: '0',
                icon: CupertinoIcons.number,
                keyboardType: TextInputType.number,
                onChanged: (value) => quantity = int.tryParse(value) ?? 0,
                validator:
                    (value) => value!.isEmpty ? "Enter Product Quantity" : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      children: [
        _buildDropdownField(
          label: 'Category',
          child: FutureBuilder<List<Category>>(
            future: futureCategories,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No Category'));
              } else {
                return DropdownButton<Category>(
                  value: selectedCategory,
                  hint: const Text('Select Category'),
                  isExpanded: true,
                  underline: Container(),
                  items:
                      snapshot.data!.map((Category category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                      selectedSubcategory = null;
                      futureSubcategories = null;
                    });
                    if (value != null) {
                      getSubcategoryByCategory(value);
                    }
                  },
                );
              }
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'Subcategory',
          child:
              selectedCategory == null
                  ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Please select a category first',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  )
                  : FutureBuilder<List<Subcategory>>(
                    future: futureSubcategories,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'No subcategories available',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        );
                      } else {
                        return DropdownButton<Subcategory>(
                          value: selectedSubcategory,
                          hint: const Text('Select Subcategory'),
                          isExpanded: true,
                          underline: Container(),
                          items:
                              snapshot.data!.map((Subcategory subcategory) {
                                return DropdownMenuItem(
                                  value: subcategory,
                                  child: Text(subcategory.subCategoryName),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedSubcategory = value;
                            });
                          },
                        );
                      }
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return _buildTextField(
      label: 'Description',
      hint: 'Describe your product in detail...',
      icon: CupertinoIcons.doc_text,
      maxLines: 4,
      maxLength: 500,
      onChanged: (value) => description = value,
      validator: (value) => value!.isEmpty ? "Enter Product Description" : null,
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
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
          onChanged: onChanged,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.indigo[600], size: 20),
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
              borderSide: BorderSide(color: Colors.indigo[600]!, width: 2),
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
            hintStyle: TextStyle(color: Colors.grey[500]),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({required String label, required Widget child}) {
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildUploadButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            isLoading
                ? null
                : () async {
                  final vendor = ref.read(vendorProvider);
                  if (vendor == null) {
                    showSnackBar(context, 'Please login to upload product');
                    return;
                  }

                  // Check all validations
                  if (!_formkey.currentState!.validate()) {
                    showSnackBar(
                      context,
                      'Please fill in all required information',
                    );
                    return;
                  }

                  if (images.isEmpty) {
                    showSnackBar(context, 'Please select at least one image');
                    return;
                  }

                  if (selectedCategory == null) {
                    showSnackBar(context, 'Please select a category');
                    return;
                  }

                  if (selectedSubcategory == null) {
                    showSnackBar(context, 'Please select a subcategory');
                    return;
                  }

                  setState(() {
                    isLoading = true;
                  });

                  try {
                    await _productController.uploadProduct(
                      productName: productName,
                      productPrice: productPrice,
                      quantity: quantity,
                      description: description,
                      category: selectedCategory!.name,
                      vendorId: vendor.id,
                      fullName: vendor.fullName,
                      subCategory: selectedSubcategory!.subCategoryName,
                      pickedImages: images,
                      context: context,
                    );

                    resetForm();
                  } catch (e) {
                    setState(() {
                      isLoading = false;
                    });
                    showSnackBar(context, 'Failed to upload product');
                  }
                },
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading ? Colors.grey[400] : Colors.indigo[700],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: isLoading ? 0 : 2,
        ),
        child: Container(
          height: 24,
          child:
              isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.cloud_upload_fill, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Upload Product',
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
