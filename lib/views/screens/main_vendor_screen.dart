import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vendor_store_ap/views/screens/nav_screens/earning_screen.dart';
import 'package:vendor_store_ap/views/screens/nav_screens/edit_screen.dart';
import 'package:vendor_store_ap/views/screens/nav_screens/order_screen.dart';
import 'package:vendor_store_ap/views/screens/nav_screens/upload_screen.dart';
import 'package:vendor_store_ap/views/screens/nav_screens/vendor_profile_screen.dart';

class MainVendorScreen extends StatefulWidget {
  const MainVendorScreen({super.key});

  @override
  State<MainVendorScreen> createState() => _MainVendorScreenState();
}

class _MainVendorScreenState extends State<MainVendorScreen> {
  int _pageIndex = 0;
  List<Widget> _pages = [
    EarningScreen(),
    UploadScreen(),
    EditScreen(),
    OrderScreen(),
    VendorProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: (value) {
          setState(() {
            _pageIndex = value;
          });
        },
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.blue,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.money_dollar),
            label: "Ernings",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.upload_circle),
            label: "Upload",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: "Edit"),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.shopping_cart),
            label: "Orders",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      body: _pages[_pageIndex],
    );
  }
}
