import 'dart:convert';

class Subcategory {
  final String id;
  final String categoryId; // Sửa từ categoryid thành categoryId
  final String categoryName;
  final String image;
  final String subCategoryName;

  Subcategory({
    required this.id,
    required this.categoryId, // Sửa tên parameter
    required this.categoryName,
    required this.image,
    required this.subCategoryName,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'categoryId': categoryId, // Sửa key trong map
      'categoryName': categoryName,
      'image': image,
      'subCategoryName': subCategoryName,
    };
  }

  String toJson() => json.encode(toMap());

  factory Subcategory.fromJson(Map<String, dynamic> map) {
    return Subcategory(
      id: map['_id'] as String,
      categoryId: map['categoryId'] as String, // Sửa key khi đọc từ JSON
      categoryName: map['categoryName'] as String,
      image: map['image'] as String,
      subCategoryName: map['subCategoryName'] as String,
    );
  }
}
