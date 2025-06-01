import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendor_store_ap/global_variables.dart';
import 'package:vendor_store_ap/models/product.dart';
import 'package:vendor_store_ap/services/manage_http_response.dart';

class ProductController {
  Future<void> uploadProduct({
    required String productName,
    required int productPrice,
    required int quantity,
    required String description,
    required String category,
    required String vendorId,
    required String fullName,
    required String subCategory,
    required List<File>? pickedImages,
    required context,
  }) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('auth_token');
    if (pickedImages != null) {
      final cloudinary = CloudinaryPublic("dlfpyd3ro", 'back_api');
      List<String> images = [];
      for (var i = 0; i < pickedImages.length; i++) {
        CloudinaryResponse cloudinaryResponse = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(pickedImages[i].path, folder: productName),
        );

        images.add(cloudinaryResponse.secureUrl);
      }
      if (category.isNotEmpty && subCategory.isNotEmpty) {
        final Product product = Product(
          id: '',
          productName: productName,
          productPrice: productPrice,
          quantity: quantity,
          description: description,
          category: category,
          vendorId: vendorId,
          fullName: fullName,
          subCategory: subCategory,
          images: images,
        );
        print('Product JSON: ${product.toJson()}'); // Log dữ liệu trước khi gửi
        http.Response response = await http.post(
          Uri.parse('$uri/api/add-product'),
          body: product.toJson(),
          headers: <String, String>{
            "Content-Type": 'application/json; charset=UTF-8',
            'x-auth-token': token!,
          },
        );
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        manageHttpResponse(
          response: response,
          context: context,
          onSuccess: () {
            showSnackBar(context, 'Product uploaded');
          },
        );
      } else {
        showSnackBar(context, 'Select Category');
      }
      print(images);
    } else {
      showSnackBar(context, 'Select Image');
    }
  }

  Future<List<Product>> loadProductByVendor(String vendorId) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? token = preferences.getString("auth_token");
      http.Response response = await http.get(
        Uri.parse('$uri/api/products/vendor/$vendorId'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
          'x-auth-token': token!,
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        List<Product> product =
            data
                .map(
                  (product) => Product.fromMap(product as Map<String, dynamic>),
                )
                .toList();
        return product;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed To Load Products');
      }
    } catch (e) {
      throw Exception('Error Loading Products: $e');
    }
  }

  Future<List<String>> uploadImagesToCloudinary(
    List<File>? pickedImages,
    Product product,
  ) async {
    final cloudinary = CloudinaryPublic("dlfpyd3ro", 'back_api');
    List<String> uploadedImages = [];
    for (var image in pickedImages!) {
      CloudinaryResponse cloudinaryResponse = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, folder: product.productName),
      );
      uploadedImages.add(cloudinaryResponse.secureUrl);
    }
    return uploadedImages;
  }

  Future<void> updateProduct({
    required Product product,
    required List<File>? pickedImages,
    required BuildContext context,
  }) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString("auth_token");

    if (pickedImages != null) {
      await uploadImagesToCloudinary(pickedImages, product);
    }

    final updatedData = product.toMap();

    http.Response response = await http.put(
      Uri.parse('$uri/api/edit-product/${product.id}'),
      body: jsonEncode(updatedData),
      headers: <String, String>{
        "Content-Type": 'application/json; charset=UTF-8',
        'x-auth-token': token!,
      },
    );
    manageHttpResponse(
      response: response,
      context: context,
      onSuccess: () {
        showSnackBar(context, "Product updated successfully");
      },
    );
  }
}
