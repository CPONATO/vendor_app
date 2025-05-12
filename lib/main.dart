import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendor_store_ap/provider/vendor_provider.dart';
import 'package:vendor_store_ap/views/screens/auth/login_screen.dart';
import 'package:vendor_store_ap/views/screens/main_vendor_screen.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> checktokenAndSetUser(WidgetRef ref) async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? token = preferences.getString('auth_token');
      String? vendorJson = preferences.getString('vendor');

      if (token != null && vendorJson != null) {
        ref.read(vendorProvider.notifier).setVendor(vendorJson);
      } else {
        ref.read(vendorProvider.notifier).signOut();
      }
    }

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: FutureBuilder(
        future: checktokenAndSetUser(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final vendor = ref.watch(vendorProvider);
          return vendor != null ? MainVendorScreen() : LoginScreen();
        },
      ),
    );
  }
}
