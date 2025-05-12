import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_store_ap/controllers/vendor_auth_controller.dart';
import 'package:vendor_store_ap/views/screens/auth/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final VendorAuthController _vendorAuthController = VendorAuthController();
  late String email;
  late String fullName;
  late String password;
  bool _isLoading = false;
  registerUser() async {
    setState(() {
      _isLoading = true;
    });
    await _vendorAuthController
        .signupVendor(
          context: context,
          email: email,
          fullName: fullName,
          password: password,
        )
        .whenComplete(() {
          setState(() {
            _isLoading = false;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.95),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Create Your Account",
                  style: GoogleFonts.getFont(
                    'Lato',
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                    fontSize: 23,
                  ),
                ),
                Text(
                  "To Explore the world exclusives",
                  style: GoogleFonts.getFont(
                    'Lato',
                    color: Colors.black,
                    fontSize: 14,
                    letterSpacing: 0.2,
                  ),
                ),
                Image.asset(
                  'assets/images/illustration.png',
                  width: 200,
                  height: 200,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Email',
                    style: GoogleFonts.getFont(
                      'Nunito Sans',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                TextFormField(
                  onChanged: (value) {
                    email = value;
                  },
                  validator: (Value) {
                    if (Value!.isEmpty) {
                      return 'Enter your email';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    labelText: 'Enter your email',
                    labelStyle: GoogleFonts.getFont(
                      "Nunito Sans",
                      fontSize: 14,
                      letterSpacing: 0.1,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(
                        'assets/icons/email.png',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Full Name',
                    style: GoogleFonts.getFont(
                      'Nunito Sans',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                TextFormField(
                  onChanged: (value) {
                    fullName = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter your full name';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    labelText: 'Enter your full name',
                    labelStyle: GoogleFonts.getFont(
                      "Nunito Sans",
                      fontSize: 14,
                      letterSpacing: 0.1,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(
                        'assets/icons/user.jpeg',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Password',
                    style: GoogleFonts.getFont(
                      'Nunito Sans',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                TextFormField(
                  onChanged: (value) {
                    password = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter your password';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    labelText: 'Enter your password',
                    labelStyle: GoogleFonts.getFont(
                      "Nunito Sans",
                      fontSize: 14,
                      letterSpacing: 0.1,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(
                        'assets/icons/password.png',
                        width: 20,
                        height: 20,
                      ),
                    ),
                    suffixIcon: Icon(Icons.visibility),
                  ),
                ),
                SizedBox(height: 20),

                InkWell(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      registerUser();
                    }
                  },
                  child: Container(
                    width: 319,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromARGB(255, 50, 70, 252),
                          const Color.fromARGB(255, 10, 103, 252),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Sign up',
                        style: GoogleFonts.getFont(
                          'Lato',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already Have an Account?',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return LoginScreen();
                            },
                          ),
                        );
                      },
                      child:
                          _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                'Sign in',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  color: Colors.blue,
                                ),
                              ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
