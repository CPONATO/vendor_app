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
        ),
      );

  void setVendor(String vendorJson) {
    state = Vendor.fromJson(vendorJson);
  }

  void signOut() {
    state = null;
  }
}

final vendorProvider = StateNotifierProvider<VendorProvider, Vendor?>((ref) {
  return VendorProvider();
});
