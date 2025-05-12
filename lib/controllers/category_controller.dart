import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vendor_store_ap/global_variables.dart';
import 'package:vendor_store_ap/models/category.dart';

class CategoryController {
  Future<List<Category>> loadCategories() async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/categories'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );
      print(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<Category> categories =
            data.map((category) => Category.fromJson(category)).toList();
        return categories;
      } else {
        throw Exception('failed to load categories');
      }
    } catch (e) {
      throw Exception('Error loading categories: $e');
    }
  }
}
