import 'package:flutter/material.dart';
import 'package:vendor_store_ap/controllers/vendor_auth_controller.dart';

class VendorProfileScreen extends StatelessWidget {
  VendorProfileScreen({super.key});
  final VendorAuthController _authController = VendorAuthController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          await _authController.signOutUSer(context: context);
        },
        child: Text('Sign Out'),
      ),
    );
  }
}
