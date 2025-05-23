// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Product {
  final String id;
  final String productName;
  final int productPrice;
  final int quantity;
  final String description;
  final String category;
  final String vendorId;
  final String fullName;
  final String subCategory;
  final List<String> images;
  final double? averageRating;
  final int? totalRating;

  Product({
    required this.id,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.description,
    required this.category,
    required this.vendorId,
    required this.fullName,
    required this.subCategory,
    required this.images,
    this.averageRating,
    this.totalRating,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'productName': productName,
      'productPrice': productPrice,
      'quantity': quantity,
      'description': description,
      'category': category,
      'vendorId': vendorId,
      'fullName': fullName,
      'subCategory': subCategory,
      'images': images,
      'averageRating': averageRating,
      'totalRating': totalRating,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    try {
      print("Raw map data: $map");
      return Product(
        id: map['_id'] ?? '', // Xử lý null
        productName: map['productName'] ?? '', // Xử lý null
        productPrice: map['productPrice'] ?? 0, // Xử lý null
        quantity: map['quantity'] ?? 0, // Xử lý null
        description: map['description'] ?? '', // Xử lý null
        category: map['category'] ?? '', // Xử lý null
        vendorId: map['vendorId'] ?? '', // Xử lý null
        fullName: map['fullName'] ?? '', // Xử lý null
        subCategory: map['subCategory'] ?? '', // Xử lý null
        images: List<String>.from(
          (map['images'] ?? []).map((e) => e.toString()),
        ), // Xử lý null và ép kiểu đúng
        averageRating:
            (map['averageRating'] == null)
                ? 0.0
                : (map['averageRating'] is int
                    ? (map['averageRating'] as int).toDouble()
                    : map['averageRating'] as double),
        totalRating: map['totalRating'] ?? 0, // Xử lý null
      );
    } catch (e, stackTrace) {
      print("Error parsing product: $e");
      print("Stack trace: $stackTrace");
      print("Problematic data: $map");
      rethrow; // Ném lại lỗi để xử lý ở tầng trên
    }
  }
  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source) as Map<String, dynamic>);
}
