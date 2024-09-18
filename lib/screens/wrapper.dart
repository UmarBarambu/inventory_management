import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/screens/authenticate/authenticate.dart';
import 'package:inventory_management/screens/home/adminDashboard.dart';
import 'package:inventory_management/screens/home/managerDashboard.dart';
import 'package:inventory_management/screens/home/staffDashboard.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool _isMounted = true;
  bool _isAdminRegistered = false;

  @override
  void initState() {
    super.initState();
    _checkAdminRegistration();
  }

  @override
  void dispose() {
    _isMounted = false; // Set the flag to false when the widget is disposed
    super.dispose();
  }

  // Check if an admin is registered
  Future<void> _checkAdminRegistration() async {
    try {
      var usersCollection = await FirebaseFirestore.instance.collection('users').get();
      bool foundAdmin = usersCollection.docs.any((doc) => doc['role'] == 'admin');
      if (mounted) {
        setState(() {
          _isAdminRegistered = foundAdmin;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error checking admin registration: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user == null) {
      // User is not authenticated, show the Authenticate screen
      if (_isAdminRegistered) {
        // If admin is registered, always show SignIn page
        return const Authenticate();
      } else {
        // If no admin is registered, show the Register page
        return const Authenticate(); // Modify Authenticate to show Register if needed
      }
    } else {
      // User is authenticated, fetch user role from Firestore
      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while fetching user data
            return const Scaffold(
              body:Center(
              child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
           ),
          )

            );
          } else if (snapshot.hasError) {
            // Handle errors
            return Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.exists) {
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            String role = userData['role'] ?? '';

            // Check if widget is still mounted before calling setState or returning UI
            if (!_isMounted) return Container();

            // Proceed with showing dashboard based on the user role
            switch (role) {
              case 'admin':
                return const Admindashboard();
              case 'manager':
                return const Managerdashboard();
              case 'staff':
                return const Staffdashboard();
              default:
                return const Scaffold(
                  body: Center(
                    child: Text('Role not recognized'),
                  ),
                );
            }
          } else if (!snapshot.data!.exists) {
            // If no Firestore data exists, sign the user out
            FirebaseAuth.instance.signOut();
            return const Authenticate();
          } else {
            // Handle case where no user data is found
            return const Scaffold(
              body: Center(
                child: Text('No user data found'),
              ),
            );
          }
        },
      );
    }
  }
}
