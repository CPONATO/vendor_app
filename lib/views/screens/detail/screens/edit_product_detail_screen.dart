import 'dart:io';

import 'package:flutter/material.dart';
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

  Future<void> _pickImages() async {
    final pickedFile = await ImagePicker().pickMultiImage();
    setState(() {
      pickedImages = pickedFile.map((file) => File(file.path)).toList();
    });
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      //upload images to cloundinary

      List<String> uploadedImages =
          pickedImages != null && pickedImages!.isNotEmpty
              ? await _productController.uploadImagesToCloudinary(
                pickedImages,
                widget.product,
              )
              : widget.product.images;
      //create an instance of the product  model object

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
    } else {
      print('fill in all fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.name,
                validator:
                    (value) => value!.isEmpty ? "Enter product name" : null,
                controller: productNameController,
                decoration: InputDecoration(labelText: 'Product Name'),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                validator:
                    (value) => value!.isEmpty ? "Enter product price" : null,
                controller: productPriceController,
                decoration: InputDecoration(labelText: 'Product Price'),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                validator:
                    (value) => value!.isEmpty ? "Enter product quantity" : null,
                controller: productQuantityController,
                decoration: InputDecoration(labelText: 'Product Quantity'),
              ),
              TextFormField(
                maxLength: 500,
                maxLines: 6,
                keyboardType: TextInputType.name,
                validator:
                    (value) =>
                        value!.isEmpty ? "Enter product description" : null,
                controller: productDescriptionController,
                decoration: InputDecoration(labelText: 'Product Description'),
              ),
              SizedBox(height: 15),
              //display current product image
              if (widget.product.images.isNotEmpty)
                Wrap(
                  spacing: 10,
                  children:
                      widget.product.images.map((imageUrl) {
                        return InkWell(
                          onTap: () {
                            _pickImages();
                          },
                          child: Image.network(
                            imageUrl,
                            width: 100,
                            height: 100,
                          ),
                        );
                      }).toList(),
                ),
              if (pickedImages != null)
                Wrap(
                  spacing: 10,
                  children:
                      pickedImages!.map((image) {
                        return Image.file(image, width: 100, height: 100);
                      }).toList(),
                ),
              ElevatedButton(
                onPressed: () async {
                  await _updateProduct();
                },
                child: Text('Update Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
