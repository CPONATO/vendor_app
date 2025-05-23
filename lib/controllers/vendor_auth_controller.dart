import 'dart:convert';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as providerContainer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendor_store_ap/global_variables.dart';
import 'package:vendor_store_ap/models/vendor.dart';
import 'package:http/http.dart' as http;
import 'package:vendor_store_ap/provider/vendor_provider.dart';
import 'package:vendor_store_ap/services/manage_http_response.dart';
import 'package:vendor_store_ap/views/screens/auth/login_screen.dart';
import 'package:vendor_store_ap/views/screens/main_vendor_screen.dart';

// Remove the global providerContainer
// final providerContainer = ProviderContainer();

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
        Uri.parse("$uri/api/v2/vendor/signup"),
        body: vendor.toJson(),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Vendor account created successfully');
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
        Uri.parse('$uri/api/v2/vendor/signin'),
        body: jsonEncode({"email": email, "password": password}),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          final responseData = jsonDecode(response.body);

          // Save token to SharedPreferences
          if (responseData['token'] != null) {
            String token = responseData['token'];
            await preferences.setString('auth_token', token);
          }

          // Check and process user data
          if (responseData['user'] != null) {
            final userData = responseData['user'];

            // Debug user info
            print('User data: $userData');

            // Store original user data in SharedPreferences
            await preferences.setString('vendor', jsonEncode(userData));

            // Update provider using the ProviderContainer from the widget tree
            final container = ProviderScope.containerOf(context);
            container
                .read(vendorProvider.notifier)
                .setVendor(jsonEncode(userData));

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainVendorScreen()),
              (route) => false,
            );

            showSnackBar(context, 'Sign in successful');
          } else {
            print('Error: User data not found in response');
            showSnackBar(context, 'Error: User data not found');
          }
        } catch (e) {
          print('Error processing response: $e');
          showSnackBar(context, 'Error processing response: $e');
        }
      } else {
        showSnackBar(
          context,
          'Sign in failed. Error code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Connection error: $e');
      showSnackBar(context, 'Connection error: $e');
    }
  }

  Future<void> signOutUSer({required BuildContext context}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      // Clear the token and user from SharedPreferences
      await preferences.remove('auth_token');
      await preferences.remove('vendor');

      // Clear the user state using the container from the widget tree
      final container = ProviderScope.containerOf(context);
      container.read(vendorProvider.notifier).signOut();

      // Navigate the user back to the login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) {
            return LoginScreen();
          },
        ),
        (route) => false,
      );

      showSnackBar(context, 'Signed out successfully');
    } catch (e) {
      showSnackBar(context, "Error signing out");
    }
  }

  Future<void> updateVendorData({
    required BuildContext context,
    required String id,
    required File? storeImage,
    required String storeDescription,
    required WidgetRef ref,
  }) async {
    try {
      final cloudinary = CloudinaryPublic("dlfpyd3ro", 'back_api');
      CloudinaryResponse imageResponse = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          storeImage!.path,
          identifier: 'pickedImage',
          folder: 'storeImage',
        ),
      );
      String image = imageResponse.secureUrl;
      print("Đang cập nhật data cho ID: $id");

      final http.Response response = await http.put(
        Uri.parse('$uri/api/vendor/$id'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'storeImage': image,
          'storeDescription': storeDescription,
        }),
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          final updatedUser = jsonDecode(response.body);
          final userJson = jsonEncode(updatedUser);
          ref.read(vendorProvider.notifier).setVendor(userJson);

          showSnackBar(context, 'Data updated');
        },
      );
    } catch (e) {
      print("Lỗi cập nhật địa chỉ: $e");
      showSnackBar(context, 'Failed updarting data');
    }
  }

  //delete   account
  Future<void> deleteAccoumt({
    required BuildContext context,
    required String id,
    required WidgetRef ref,
  }) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? token = preferences.getString('auth_token');
      if (token == null) {
        showSnackBar(context, "You need to login to perform this action");
        return;
      }

      http.Response response = await http.delete(
        Uri.parse('$uri/api/user/delete-account/$id'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          await preferences.remove(('auth_token'));

          await preferences.remove('user');

          ref.read(vendorProvider.notifier).signOut();

          showSnackBar(context, 'Account deleted');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        },
      );
    } catch (e) {
      showSnackBar(context, 'Error deleting account: $e');
    }
  }
}
