import 'package:flutter/material.dart';
import 'package:inventory_management/screens/authenticate/register.dart';
import 'package:inventory_management/screens/authenticate/sign_in.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => AuthenticateState();
}

class AuthenticateState extends State<Authenticate> {
  bool showSignIn = true; // Track which screen to show

  // Toggle between Register and SignIn screens
  void toggleView() {
    setState(() {
      showSignIn = !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: showSignIn
          ? SignIn(toggleView: toggleView) // Pass the toggleView function to SignIn
          : Register(toggleView: toggleView), // Pass the toggleView function to Register
    );
  }
}
