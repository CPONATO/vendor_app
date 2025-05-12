import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloudinary_public/cloudinary_public.dart';
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
}
