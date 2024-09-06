import 'package:flutter/material.dart';
import 'package:inventory_management/services/auth.dart';

class Managerdashboard extends StatefulWidget {
  const Managerdashboard({super.key});

  @override
  State<Managerdashboard> createState() => _ManagerdashboardState();
}

class _ManagerdashboardState extends State<Managerdashboard> {
  final AuthService _auth = AuthService(); // Initialize your AuthService

   Future<void> _signOut() async {
    try {
      await _auth.signOut(context); // Pass context here
    } catch (e) {
      // Handle any errors here
      print('Error signing out: $e');
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
        backgroundColor: Colors.blue,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Logout', style: TextStyle(color: Colors.white)),
            onPressed: _signOut,
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to the Manager Dashboard',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
