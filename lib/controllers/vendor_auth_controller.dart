import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendor_store_ap/global_variables.dart';
import 'package:vendor_store_ap/models/vendor.dart';
import 'package:http/http.dart' as http;
import 'package:vendor_store_ap/provider/vendor_provider.dart';
import 'package:vendor_store_ap/services/manage_http_response.dart';
import 'package:vendor_store_ap/views/screens/auth/login_screen.dart';
import 'package:vendor_store_ap/views/screens/main_vendor_screen.dart';

final providerContainer = ProviderContainer();

class VendorAuthController {
  Future<void> signupVendor({
    required String fullName,
    required String email,
    required String password,
    required context,
  }) async {
    try {
      Vendor vendor = Vendor(
        id: '',
        fullName: fullName,
        email: email,
        state: '',
        city: '',
        locality: '',
        role: '',
        password: password,
      );
      http.Response response = await http.post(
        Uri.parse("$uri/api/vendor/signup"),
        body: vendor.toJson(),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Vendor account created');
        },
      );
    } catch (e) {
      showSnackBar(context, '$e');
    }
  }

  Future<void> signInVendor({
    required String email,
    required String password,
    required context,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$uri/api/vendor/signin'),
        body: jsonEncode({"email": email, "password": password}),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          String token = jsonDecode(response.body)['token'];
          await preferences.setString('auth_token', token);

          // Sử dụng 'user' thay vì 'vendor'
          final vendorData = jsonDecode(response.body)['user'];
          if (vendorData == null) {
            showSnackBar(context, 'Error: Vendor data not found in response');
            return;
          }

          final vendorJson = jsonEncode(vendorData);
          providerContainer.read(vendorProvider.notifier).setVendor(vendorJson);

          await preferences.setString('vendor', vendorJson);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) {
                return MainVendorScreen();
              },
            ),
            (route) => false,
          );
          showSnackBar(context, 'Login successfully');
        },
      );
    } catch (e) {
      showSnackBar(context, '$e');
    }
  }

  Future<void> signOutUSer({required BuildContext context}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      //clear the token and user from SharedPreferenace
      await preferences.remove('auth_token');
      await preferences.remove('vendor');
      //clear the user state
      providerContainer.read(vendorProvider.notifier).signOut();

      //navigate the user back to the login screen

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) {
            return LoginScreen();
          },
        ),
        (route) => false,
      );

      showSnackBar(context, 'signout successfully');
    } catch (e) {
      showSnackBar(context, "error signing out");
    }
  }
}
