import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendor_store_ap/models/vendor.dart';

class VendorProvider extends StateNotifier<Vendor?> {
  VendorProvider()
    : super(
        Vendor(
          id: '',
          fullName: '',
          email: '',
          state: '',
          city: '',
          locality: '',
          role: '',
          password: '',
          storeImage: '',
          storeDescription: '',
        ),
      );

  void setVendor(String vendorJson) {
    print("=== PROVIDER SET VENDOR ===");
    print("Input JSON: $vendorJson");

    state = Vendor.fromJson(vendorJson);

    print("=== STATE AFTER SET ===");
    print("ID: ${state?.id}");
    print("FullName: ${state?.fullName}");
    print("StoreImage: '${state?.storeImage}'");
    print("StoreImage length: ${state?.storeImage?.length ?? 0}");
    print("StoreDescription: '${state?.storeDescription}'");
    print("=====================");
  }

  void signOut() {
    state = null;
  }
}

final vendorProvider = StateNotifierProvider<VendorProvider, Vendor?>((ref) {
  return VendorProvider();
});
