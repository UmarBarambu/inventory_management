import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/screens/authenticate/authenticate.dart'; // Ensure this import is added for navigation
import 'package:inventory_management/services/auth.dart';
import 'package:inventory_management/shared/constant.dart';

class Register extends StatefulWidget {
  final VoidCallback
      toggleView; // Callback to switch between Register and SignIn

  const Register({required this.toggleView, super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // Form fields
  String email = '';
  String password = '';
  String firstName = '';
  String lastName = '';
  String phoneNumber = '';
  String role = 'staff'; // Default role is staff
  String error = '';
  bool isLoading = false; // Loading state

  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: const Text('Register'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.login, color: Colors.red),
            label: const Text('Sign In', style: TextStyle(color: Colors.red)),
            onPressed: widget.toggleView, // Switch to Sign In screen
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue!),
              ),
            )
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      'StockMate',
                      style: TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    TextFormField(
                      decoration:
                          textInputDecoration.copyWith(hintText: 'First Name'),
                      validator: (val) =>
                          val!.isEmpty ? 'Enter a first name' : null,
                      onChanged: (val) {
                        setState(() {
                          firstName = val;
                        });
                      },
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      decoration:
                          textInputDecoration.copyWith(hintText: 'Last Name'),
                      validator: (val) =>
                          val!.isEmpty ? 'Enter a last name' : null,
                      onChanged: (val) {
                        setState(() {
                          lastName = val;
                        });
                      },
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      decoration: textInputDecoration.copyWith(
                          hintText: 'Phone Number'),
                      validator: (val) =>
                          val!.isEmpty ? 'Enter a phone number' : null,
                      onChanged: (val) {
                        setState(() {
                          phoneNumber = val;
                        });
                      },
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      decoration:
                          textInputDecoration.copyWith(hintText: 'Email'),
                      validator: (val) =>
                          val!.isEmpty ? 'Enter an email' : null,
                      onChanged: (val) {
                        setState(() {
                          email = val;
                        });
                      },
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      decoration:
                          textInputDecoration.copyWith(hintText: 'Password'),
                      validator: (val) =>
                          val!.length < 6 ? 'Enter 6+ characters' : null,
                      obscureText: true,
                      onChanged: (val) {
                        setState(() {
                          password = val;
                        });
                      },
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            isLoading = true; // Start loading
                            error = ''; // Clear previous errors
                          });

                          try {
                            // Determine the role based on the number of users
                            String assignedRole = await _determineRole();

                            // Register user
                            dynamic result =
                                await _authService.registerWithEmailAndPassword(
                                    email, password, assignedRole);

                            if (result is String) {
                              // If result is a String, it indicates an error
                              setState(() {
                                error = result;
                              });
                            } else {
                              var user = result;

                              // Save additional user info in Firestore
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .set({
                                'firstName': firstName,
                                'lastName': lastName,
                                'email': email,
                                'phoneNumber': phoneNumber,
                                'role':
                                    assignedRole, // Set the role dynamically
                                'isActive': assignedRole ==
                                    'admin', // Admin is active, others are inactive by default
                              });

                              // Redirect based on role
                              if (assignedRole == 'admin') {
                                // Admin can be navigated to the dashboard
                                // ignore: use_build_context_synchronously
                                Navigator.of(context)
                                    .pop(); // or navigate to the admin dashboard
                              } else {
                                // Non-admin users go back to the sign-in page
                                // ignore: use_build_context_synchronously
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Authenticate()),
                                    (route) => false);
                              }
                            }
                          } catch (e) {
                            if (kDebugMode) {
                              print('Error during registration: $e');
                            }
                            setState(() {
                              error =
                                  'Error during registration. Please try again.';
                            });
                          } finally {
                            setState(() {
                              isLoading = false; // Stop loading
                            });
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      error,
                      style: const TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<String> _determineRole() async {
    try {
      // Check if there are any users in the collection
      QuerySnapshot userDocs =
          await FirebaseFirestore.instance.collection('users').get();
      if (userDocs.docs.isEmpty) {
        // If no users exist, assign 'admin' role
        return 'admin';
      } else {
        // Otherwise, assign 'staff' role
        return 'staff';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error determining role: $e');
      }
      return 'staff'; // Default to 'staff' if an error occurs
    }
  }
}
