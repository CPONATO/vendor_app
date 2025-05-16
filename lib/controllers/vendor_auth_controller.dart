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
          showSnackBar(context, 'Tài khoản người bán đã được tạo');
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

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          final responseData = jsonDecode(response.body);

          // Lưu token vào SharedPreferences
          if (responseData['token'] != null) {
            String token = responseData['token'];
            await preferences.setString('auth_token', token);
          }

          // Kiểm tra và xử lý dữ liệu người dùng
          if (responseData['user'] != null) {
            final userData = responseData['user'];

            // In ra thông tin người dùng để debug
            print('User data: $userData');

            // Lưu trữ dữ liệu người dùng gốc vào SharedPreferences
            await preferences.setString('vendor', jsonEncode(userData));

            // Cập nhật nhà cung cấp bằng cách sử dụng dữ liệu người dùng
            providerContainer
                .read(vendorProvider.notifier)
                .setVendor(jsonEncode(userData));

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainVendorScreen()),
              (route) => false,
            );

            showSnackBar(context, 'Đăng nhập thành công');
          } else {
            print('Lỗi: Không tìm thấy dữ liệu người dùng trong phản hồi');
            showSnackBar(context, 'Lỗi: Không tìm thấy dữ liệu người dùng');
          }
        } catch (e) {
          print('Lỗi xử lý phản hồi: $e');
          showSnackBar(context, 'Lỗi xử lý phản hồi: $e');
        }
      } else {
        showSnackBar(
          context,
          'Đăng nhập thất bại. Mã lỗi: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Lỗi kết nối: $e');
      showSnackBar(context, 'Lỗi kết nối: $e');
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

      showSnackBar(context, 'Đăng xuất thành công');
    } catch (e) {
      showSnackBar(context, "Lỗi khi đăng xuất");
    }
  }
}
