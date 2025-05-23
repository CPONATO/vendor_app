import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendor_store_ap/models/product.dart';

class VendorProductProvider extends StateNotifier<List<Product>> {
  VendorProductProvider() : super([]);

  void setProduct(List<Product> products) {
    state = products;
  }
}

final vendorProductProvider =
    StateNotifierProvider<VendorProductProvider, List<Product>>((ref) {
      return VendorProductProvider();
    });
