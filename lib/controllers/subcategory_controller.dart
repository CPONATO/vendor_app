import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vendor_store_ap/global_variables.dart';
import 'package:vendor_store_ap/models/subcategory.dart';

class SubcategoryController {
  Future<List<Subcategory>> getSubCategoryByCategoryName(
    String categoryName,
  ) async {
    try {
      http.Response response = await http.get(
        Uri.parse("$uri/api/category/$categoryName/subcategory"),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return data
              .map((subcategory) => Subcategory.fromJson(subcategory))
              .toList();
        } else {
          print("Suncategories not found");
          return [];
        }
      } else if (response.statusCode == 404) {
        print("Suncategories not found");
        return [];
      } else {
        print("Failed to fetch categories");
        return [];
      }
    } catch (e) {
      print("error fetching categories $e");
      return [];
    }
  }
}
