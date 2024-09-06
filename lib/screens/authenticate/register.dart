import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/services/auth.dart';
import 'package:inventory_management/shared/constant.dart';

class Register extends StatefulWidget {
  const Register({super.key});

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
  String role = 'admin'; // Default role is admin, but this can be changed dynamically.
  String error = '';
  bool isLoading = false; // Loading state

  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        title: const Text('Register'),
      ),
      body: isLoading // Show a loading indicator when processing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20.0),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(hintText: 'First Name'),
                        validator: (val) => val!.isEmpty ? 'Enter a first name' : null,
                        onChanged: (val) {
                          setState(() {
                            firstName = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(hintText: 'Last Name'),
                        validator: (val) => val!.isEmpty ? 'Enter a last name' : null,
                        onChanged: (val) {
                          setState(() {
                            lastName = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(hintText: 'Phone Number'),
                        validator: (val) => val!.isEmpty ? 'Enter a phone number' : null,
                        onChanged: (val) {
                          setState(() {
                            phoneNumber = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(hintText: 'Email'),
                        validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                        onChanged: (val) {
                          setState(() {
                            email = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(hintText: 'Password'),
                        validator: (val) => val!.length < 6 ? 'Enter 6+ characters' : null,
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

                            dynamic result = await _authService.registerWithEmailAndPassword(email, password, role);

                            if (result is String) {
                              // If result is a String, it indicates an error
                              setState(() {
                                error = result;
                              });
                            } else {
                              var user = result;

                              // Save additional user info in Firestore
                              try {
                                await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                                  'firstName': firstName,
                                  'lastName': lastName,
                                  'email': email,
                                  'phoneNumber': phoneNumber,
                                  'role': role, // Default role is admin, change as needed
                                });

                                // Optionally navigate to another screen after registration success
                                Navigator.of(context).pop(); // Go back or navigate to home
                              } catch (e) {
                                print('Error saving user data: $e');
                                setState(() {
                                  error = 'Error saving user data. Please try again.';
                                });
                              }
                            }

                            setState(() {
                              isLoading = false; // Stop loading
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[600],
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
            ),
    );
  }
}
