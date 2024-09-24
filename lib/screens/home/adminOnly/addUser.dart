import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/screens/home/admindashboard.dart';
import 'package:inventory_management/services/auth.dart';
import 'package:inventory_management/shared/constant.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>(); // Added form key
  final AuthService _authService = AuthService();
  String firstName = '';
  String lastName = '';
  String phoneNumber = '';
  String email = '';
  String password = '';
  String role = ''; // No default role
  bool isLoading = false; // Loading state

  Future<void> _addUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          firstName.isNotEmpty &&
          lastName.isNotEmpty &&
          phoneNumber.isNotEmpty &&
          role.isNotEmpty) {
        setState(() {
          isLoading = true; // Start loading state
        });

        try {
          // Register the user with Firebase Authentication
          final result = await _authService.registerWithEmailAndPasswordV2(
              email, password);

          if (result is String) {
          throw Exception('Registration failed: $result');
        }

          final userId = result['localId'];
          if (userId == null) {
            throw Exception('Registration failed: User ID is null');
          }

          // Save additional user info to Firestore
          await FirebaseFirestore.instance.collection('users').doc(userId).set({
            'firstName': firstName,
            'lastName': lastName,
            'phoneNumber': phoneNumber,
            'email': email,
            'role': role,
            'isActive': true,
          });

          if (kDebugMode) {
            print('User added successfully to Firestore');
          }

          // Navigate back to the AdminDashboard
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const Admindashboard(),
            ),
          );
        } catch (e) {
          // Handle any exceptions
          if (kDebugMode) {
            print('Error during user registration: $e');
          }
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration Error: ${e.toString()}')),
          );
        } finally {
          setState(() {
            isLoading = false; // Stop loading state
          });
        }
      } else {
        if (kDebugMode) {
          print('Please fill all fields');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New User',
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
            ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to AdminDashboard
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    const Admindashboard(), // Ensure AdminDashboard exists
              ),
            );
          },
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 50.0),
                child: Form(
                  key: _formKey, // Added form key
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: textInputDecoration.copyWith(
                            hintText: 'First Name'),
                        onChanged: (val) => setState(() {
                          firstName = val;
                        }),
                        validator: (val) =>
                            val!.isEmpty ? 'Enter first name' : null,
                      ),
                      const SizedBox(height: 5.0),
                      TextFormField(
                        decoration:
                            textInputDecoration.copyWith(hintText: 'Last Name'),
                        onChanged: (val) => setState(() {
                          lastName = val;
                        }),
                        validator: (val) =>
                            val!.isEmpty ? 'Enter last name' : null,
                      ),
                      const SizedBox(height: 5.0),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(
                            hintText: 'Phone Number'),
                        keyboardType: TextInputType.phone,
                        onChanged: (val) => setState(() {
                          phoneNumber = val;
                        }),
                        validator: (val) =>
                            val!.isEmpty ? 'Enter phone number' : null,
                      ),
                      const SizedBox(height: 5.0),
                      TextFormField(
                        decoration:
                            textInputDecoration.copyWith(hintText: 'Email'),
                        onChanged: (val) => setState(() {
                          email = val;
                        }),
                        validator: (val) => val!.isEmpty ? 'Enter email' : null,
                      ),
                      const SizedBox(height: 5.0),
                      TextFormField(
                        decoration:
                            textInputDecoration.copyWith(hintText: 'Password'),
                        obscureText: true,
                        onChanged: (val) => setState(() {
                          password = val;
                        }),
                        validator: (val) =>
                            val!.length < 6 ? 'Enter 6+ characters' : null,
                      ),
                      const SizedBox(height: 5.0),
                      DropdownButtonFormField<String>(
                        value: role.isEmpty ? null : role,
                        items: <String>['staff', 'manager'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            role = newValue ?? '';
                          });
                        },
                        hint: const Text('Select Role'),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Select a role' : null,
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: _addUser,
                             style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Cancel and navigate to AdminDashboard
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const Admindashboard(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
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
