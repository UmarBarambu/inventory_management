import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/screens/authenticate/authenticate.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create user object based on FirebaseUser
  User? _userFromFirebaseUser(User? user) {
    return user;
  }

  Stream<User?> get user {
    return _auth.authStateChanges().map<User?>((User? user) => _userFromFirebaseUser(user));
  }

  // Sign in with email and password
  Future<dynamic> signInWithEmailAndPassword(String email, String password) async {
  try {
    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    User? user = result.user;

    if (user != null) {
      // Check if the email is verified
      if (!user.emailVerified) {
        return 'Email not verified'; // Inform the user to verify their email
      }

      // Fetch user data from Firestore
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          return 'User document does not exist'; // Handle the case where document is missing
        }
        String role = userDoc.get('role') ?? '';

        if (role.isEmpty) {
          return 'User role not found'; // Handle the case where role is not set
        }

        // Return user information including role
        return {
          'user': user,
          'role': role,
        };
      } catch (e) {
        if (kDebugMode) {
          print('Firestore Read Error: ${e.toString()}');
        }
        return 'Failed to retrieve user data'; // Error retrieving user data from Firestore
      }
    } else {
      return 'User not found'; // User was not found in FirebaseAuth
    }
  } catch (e) {
    if (kDebugMode) {
      print('Sign In Error: ${e.toString()}'); // Debugging error
    }
    return 'Failed to sign in: ${e.toString()}'; // Return an error message to display to the user
  }
}

  // Register with email and password
  Future<dynamic> registerWithEmailAndPassword(String email, String password, String role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Optionally, you can add additional user data to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': email,
          'role': role, // Default role; you can change it based on your needs
          // Add other user fields if needed
        });

        return user; // Return the user object
      } else {
        return 'User registration failed'; // Handle registration failure
      }
    } catch (e) {
      print(e.toString());
      return e.toString(); // Return the error message
    }
  }

   //sign out 
Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Authenticate()),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Sign Out Error: ${e.toString()}');
      }
    }
  }
}