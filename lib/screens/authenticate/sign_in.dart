import 'package:flutter/material.dart';
import 'package:inventory_management/screens/wrapper.dart';
import 'package:inventory_management/services/auth.dart';
import 'package:inventory_management/shared/constant.dart';

class SignIn extends StatefulWidget {
  final VoidCallback toggleView;

  const SignIn({required this.toggleView, super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String email = '';
  String password = '';
  String error = '';
  bool isLoading = false;

  final AuthService _service = AuthService();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: const Text('Sign In'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.person_add, color: Colors.red),
            label: const Text('Register', style: TextStyle(color: Colors.red)),
            onPressed: widget.toggleView,
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
                          textInputDecoration.copyWith(hintText: 'Email'),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Enter an email';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(val)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                      onChanged: (val) {
                        if (mounted) {
                          setState(() {
                            email = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      decoration:
                          textInputDecoration.copyWith(hintText: 'Password'),
                      validator: (val) {
                        if (val == null || val.length < 6) {
                          return 'Enter a password with at least 6 characters';
                        }
                        return null;
                      },
                      obscureText: true,
                      onChanged: (val) {
                        if (mounted) {
                          setState(() {
                            password = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () async {
                        await _login();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        'Sign In',
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

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (mounted) {
        setState(() {
          isLoading = true;
          error = '';
        });
      }
      dynamic result =
          await _service.signInWithEmailAndPassword(email, password);
      if (mounted) {
        setState(() {
          isLoading = false;
          if (result is String) {
            error = result;
          } else {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const Wrapper()));
          }
        });
      }
    }
  }
}
