import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inventory_management/screens/authenticate/authenticate.dart';
import 'package:inventory_management/shared/constant.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Convert Firebase User to a custom User object
  User? _userFromFirebaseUser(User? user) {
    return user;
  }

  // Stream to detect auth state changes
  Stream<User?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  Future<dynamic> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      // Attempt to sign in the user with email and password
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Fetch the user document from Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // If the user document does not exist, sign out and return a message
          await _auth.signOut();
          return 'User does not exist';
        }

        String role = userDoc.get('role') ?? '';
        bool isActive =
            userDoc.get('isActive') ?? false; // Default to false if not found

        if (role.isEmpty) {
          // If the user role is not found, sign out and return a message
          await _auth.signOut();
          return 'User role not found';
        }

        if (!isActive) {
          // If the user is inactive, sign out and return a message
          await _auth.signOut();
          return 'User is inactive';
        }

        // User is active and has a role
        return {'user': user, 'role': role};
      } else {
        // If the user is null, return a message
        return 'User not found';
      }
    } catch (e) {
      // Handle any errors that occur during the sign-in process
      return 'Failed to sign in';
    }
  }

  Future<Map<String, dynamic>> registerWithEmailAndPasswordV2(
      String email, String password) async {
    const url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$kFirebaseKey';

    final response = await http.post(
      Uri.parse(url),
      body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );

    final responseData = json.decode(response.body);
    if (responseData['error'] != null) {
      throw Exception(responseData['error']['message']);
    }

    return responseData;
  }

  Future<dynamic> registerWithEmailAndPassword(
      String email, String password, String role) async {
    try {
      // Create user with email and password
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // Check if this is the first user (admin) or subsequent users (inactive by default)
        bool isFirstUser = await _isFirstUser();

        // Store user info in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'role': role,
          'isActive':
              isFirstUser, // First user (admin) is active, others are inactive
        });

        return user;
      } else {
        // Return an error message if user is null
        return 'User registration failed. Please try again.';
      }
    } catch (e) {
      // Print debug info and return a user-friendly error message
      if (kDebugMode) {
        print('Registration Error: ${e.toString()}');
      }
      return 'Registration failed: ${e.toString()}';
    }
  }

  // Method to check if the current user is the first user in the system
  Future<bool> _isFirstUser() async {
    try {
      // Check if there are any users in the collection
      QuerySnapshot userDocs = await _firestore.collection('users').get();
      return userDocs
          .docs.isEmpty; // Returns true if no users exist, false otherwise
    } catch (e) {
      if (kDebugMode) {
        print('Error checking first user: ${e.toString()}');
      }
      return false; // Default to false in case of an error
    }
  }

  // Fetch user details based on the signed-in user's email
  Future<Map<String, dynamic>?> getUserDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      }
    }
    return null;
  }

  // Sign out
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      // Navigate to Authenticate screen
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Authenticate()),
        (route) => false, // Remove all previous routes
      );
    } catch (e) {
      // Print debug info and show a snackbar for the error
      if (kDebugMode) {
        print('Sign Out Error: ${e.toString()}');
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign Out Error: ${e.toString()}')),
      );
    }
  }
}
