import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/services/auth.dart';

class Admindashboard extends StatefulWidget {
  const Admindashboard({super.key});

  @override
  State<Admindashboard> createState() => _AdmindashboardState();
}

class _AdmindashboardState extends State<Admindashboard> {
  final AuthService _authService = AuthService(); // Instance of AuthService

  // Method to sign out
  Future<void> _signOut() async {
    try {
      await _authService.signOut(context); // Pass context here
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Method to add a new user
  Future<void> _addUser() async {
    String firstName = '';
    String lastName = '';
    String phoneNumber = '';
    String email = '';
    String password = '';
    String role = ''; // No default role

    // Show dialog to enter user details
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add User'),
              content: SingleChildScrollView( 
               child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: 'First Name'),
                    onChanged: (val) => firstName = val,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    onChanged: (val) => lastName = val,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                    onChanged: (val) => phoneNumber = val,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    onChanged: (val) => email = val,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    onChanged: (val) => password = val,
                  ),
                  DropdownButton<String>(
                    value: role.isEmpty ? null : role,
                    items: <String>['staff', 'manager']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        role = newValue ?? ''; // Update role
                      });
                    },
                    hint: const Text('Select Role'),
                  ),
                
                ],
              ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (email.isNotEmpty &&
                        password.isNotEmpty &&
                        firstName.isNotEmpty &&
                        lastName.isNotEmpty &&
                        phoneNumber.isNotEmpty &&
                        role.isNotEmpty) {
                      // Register the user with Firebase authentication
                      dynamic result = await _authService
                          .registerWithEmailAndPassword(email, password, role);
                      if (result is String) {
                        print('Error registering user: $result');
                      } else {
                        // Save additional user info to Firestore
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(result.uid)
                            .set({
                          'firstName': firstName,
                          'lastName': lastName,
                          'phoneNumber': phoneNumber,
                          'email': email,
                          'role': role,
                        });
                        Navigator.of(context).pop(); // Close the dialog
                      }
                    } else {
                      print('Please fill all fields');
                    }
                  },
                  child: const Text('Add User'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add User', style: TextStyle(color: Colors.white)),
            onPressed: _addUser,
          ),
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Logout', style: TextStyle(color: Colors.white)),
            onPressed: _signOut,
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to the Admin Dashboard',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
