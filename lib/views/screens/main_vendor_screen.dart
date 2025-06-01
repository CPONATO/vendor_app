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

  // ===== THÊM KEY ĐỂ FORCE REBUILD =====
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _buildPages();
  }

  void _buildPages() {
    _pages = [
      EarningScreen(
        key: ValueKey('earning_${DateTime.now().millisecondsSinceEpoch}'),
      ),
      UploadScreen(),
      EditScreen(),
      OrderScreen(
        key: ValueKey('order_${DateTime.now().millisecondsSinceEpoch}'),
      ),
      VendorProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: (value) {
          setState(() {
            _pageIndex = value;
          });

          // ===== REBUILD PAGES KHI CHUYỂN TAB =====
          if (value == 0 || value == 3) {
            // EarningScreen or OrderScreen
            _buildPages();
          }
        },
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.blue,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.money_dollar),
            label: "Earnings",
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
