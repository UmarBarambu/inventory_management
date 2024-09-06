import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/screens/authenticate/register.dart';
import 'package:inventory_management/screens/authenticate/sign_in.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => AuthenticateState();
}

class AuthenticateState extends State<Authenticate> {
  bool isLoading = true;
  bool isFirstTime = false;
  bool adminExists = false;
  String errorMessage = ''; // Added error message variable

  @override
  void initState() {
    super.initState();
    _checkFirstTimeRegistration();
  }

  // Check if any users exist and if an admin is registered
  Future<void> _checkFirstTimeRegistration() async {
    try {
      // Get the users collection
      var usersCollection = await FirebaseFirestore.instance.collection('users').get();
      if (usersCollection.docs.isEmpty) {
        // No users exist, allow first-time registration
        setState(() {
          isFirstTime = true;
          isLoading = false;
        });
      } else {
        // Check if there is at least one admin
        bool foundAdmin = usersCollection.docs.any((doc) => doc['role'] == 'admin');
        setState(() {
          isFirstTime = false;
          adminExists = foundAdmin;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error checking registration status. Please try again.';
        isLoading = false; // Stop loading on error
      });
      print("Error checking Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(), // Display a loading indicator
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Text(errorMessage, style: TextStyle(color: Colors.red, fontSize: 16)),
        ),
      );
    }

    // Show registration page if it's the first time or if no admin exists
    if (isFirstTime || !adminExists) {
      return  Register();
    } else {
      return SignIn();
    }
  }
}
