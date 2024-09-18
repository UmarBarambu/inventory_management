import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/screens/home/adminDashboard.dart';
import 'package:inventory_management/services/auth.dart';
import 'package:inventory_management/shared/constant.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
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

          if (result == null) {
            throw Exception('Registration failed: No result returned');
          } else if (result is String) {
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
            'isActive': false,
          });

          print('User added successfully to Firestore');

          // Navigate back to the AdminDashboard
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const Admindashboard(),
            ),
          );
        } catch (e) {
          // Handle any exceptions
          print('Error during user registration: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration Error: ${e.toString()}')),
          );
        } finally {
          setState(() {
            isLoading = false; // Stop loading state
          });
        }
      } else {
        print('Please fill all fields');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Please fill all fields')),
        );
      }
    }
  }

  // Future<void> _addUser() async {
  //   if (_formKey.currentState?.validate() ?? false) {
  //     if (email.isNotEmpty &&
  //         password.isNotEmpty &&
  //         firstName.isNotEmpty &&
  //         lastName.isNotEmpty &&
  //         phoneNumber.isNotEmpty &&
  //         role.isNotEmpty) {
  //       setState(() {
  //         isLoading = true; // Start loading state
  //       });

  //       try {
  //         // Register the user with Firebase Authentication
  //         final result = await _authService.registerWithEmailAndPassword(
  //             email, password, role);

  //         if (result == null) {
  //           throw Exception('Registration failed: No result returned');
  //         } else if (result is String) {
  //           throw Exception('Registration failed: $result');
  //         }

  //         final user = result;
  //         if (user.uid == null) {
  //           throw Exception('Registration failed: User ID is null');
  //         }

  //         // Save additional user info to Firestore
  //         await FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(user.uid)
  //             .set({
  //           'firstName': firstName,
  //           'lastName': lastName,
  //           'phoneNumber': phoneNumber,
  //           'email': email,
  //           'role': role,
  //           'isActive': false,
  //         });

  //         print('User added successfully to Firestore');

  //         // Navigate back to the AdminDashboard
  //         Navigator.of(context).pushReplacement(
  //           MaterialPageRoute(
  //             builder: (context) => const Admindashboard(),
  //           ),
  //         );
  //       } catch (e) {
  //         // Handle any exceptions
  //         print('Error during user registration: $e');
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Registration Error: ${e.toString()}')),
  //         );
  //       } finally {
  //         setState(() {
  //           isLoading = false; // Stop loading state
  //         });
  //       }
  //     } else {
  //       print('Please fill all fields');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: const Text('Please fill all fields')),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User'),
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
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue!),
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
                            child: const Text('Save'),
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
                            child: const Text('Cancel'),
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
