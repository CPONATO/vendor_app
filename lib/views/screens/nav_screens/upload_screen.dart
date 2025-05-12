import 'dart:io';

import 'package:flutter/material.dart';
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
  Subcategory? selectedSubcategory;
  late String name;
  Category? selectedCategory;
  late String productName = '';
  late int productPrice = 0;
  late int quantity = 0;
  late String description = '';

  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureCategories = CategoryController().loadCategories();
    selectedSubcategory = null;
  }

  List<File> images = [];

  chooseImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      print('No Imagine Picked');
    } else {
      setState(() {
        images.add(File(pickedFile.path));
      });
    }
  }

  getSubcategoryByCategory(value) {
    futureSubcategories = SubcategoryController().getSubCategoryByCategoryName(
      value.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formkey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.builder(
              shrinkWrap: true,
              itemCount: images.length + 1,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                return index == 0
                    ? Center(
                      child: IconButton(
                        onPressed: () {
                          chooseImage();
                        },
                        icon: Icon(Icons.add),
                      ),
                    )
                    : SizedBox(
                      width: 50,
                      height: 40,
                      child: Image.file(images[index - 1]),
                    );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      onChanged: (value) {
                        productName = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Product Name";
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Enter Product Name',
                        hintText: 'Enter Product Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        productPrice = int.parse(value);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Product Price";
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Enter Product Price',
                        hintText: 'Enter Product Price',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        quantity = int.parse(value);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Product Quantity";
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Enter Product Quantity',
                        hintText: 'Enter Product Quantity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  SizedBox(
                    width: 200,
                    child: FutureBuilder<List<Category>>(
                      future: futureCategories,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text('No Category'));
                        } else {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButton<Category>(
                              value: selectedCategory,
                              hint: Text('Select Category'),
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
                                });
                                getSubcategoryByCategory(selectedCategory);
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ),

                  SizedBox(
                    width: 200,
                    child: FutureBuilder<List<Subcategory>>(
                      future: futureSubcategories,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text('No Subcategory'));
                        } else {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButton<Subcategory>(
                              value: selectedSubcategory,
                              hint: Text('Select Subcategory'),
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
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: 400,
                    child: TextFormField(
                      onChanged: (value) {
                        description = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Product Description";
                        } else {
                          return null;
                        }
                      },
                      maxLines: 3,
                      maxLength: 500,
                      decoration: InputDecoration(
                        labelText: 'Enter Product Description',
                        hintText: 'Enter Product Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(15.0),
              child: InkWell(
                onTap: () async {
                  final vendor = ref.read(vendorProvider);
                  if (vendor == null) {
                    showSnackBar(
                      context,
                      'Bạn cần đăng nhập để upload sản phẩm',
                    );
                    return;
                  }
                  final fullName = vendor.fullName;
                  final vendorId = vendor.id;

                  // Kiểm tra tất cả các trường
                  if (_formkey.currentState!.validate()) {
                    if (images.isEmpty) {
                      showSnackBar(
                        context,
                        'Vui lòng chọn ít nhất một hình ảnh',
                      );
                      return;
                    }
                    if (selectedCategory == null) {
                      showSnackBar(context, 'Vui lòng chọn danh mục');
                      return;
                    }
                    if (selectedSubcategory == null) {
                      showSnackBar(context, 'Vui lòng chọn danh mục con');
                      return;
                    }

                    setState(() {
                      isLoading = true;
                    });
                    await _productController
                        .uploadProduct(
                          productName: productName,
                          productPrice: productPrice,
                          quantity: quantity,
                          description: description,
                          category: selectedCategory!.name,
                          vendorId: vendorId,
                          fullName: fullName,
                          subCategory: selectedSubcategory!.subCategoryName,
                          pickedImages: images,
                          context: context,
                        )
                        .whenComplete(() {
                          setState(() {
                            isLoading = false;
                          });
                          print('Data to upload:');
                          print('Product Name: $productName');
                          print('Product Price: $productPrice');
                          print('Quantity: $quantity');
                          print('Description: $description');
                          print('Category: ${selectedCategory?.name}');
                          print(
                            'Subcategory: ${selectedSubcategory?.subCategoryName}',
                          );
                          print('Images: $images');
                          print('Vendor ID: $vendorId');
                          print('Full Name: $fullName');
                          selectedCategory = null;
                          selectedSubcategory = null;
                          images.clear();
                          _formkey.currentState!
                              .reset(); // Reset form sau khi upload
                        });
                  } else {
                    showSnackBar(context, 'Vui lòng điền đầy đủ thông tin');
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child:
                        isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                              'Upload Product',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.7,
                              ),
                            ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
