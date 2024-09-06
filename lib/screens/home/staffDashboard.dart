import 'package:flutter/material.dart';
import 'package:inventory_management/services/auth.dart'; // Adjust the import to your project's path

class Staffdashboard extends StatefulWidget {
  const Staffdashboard({super.key});

  @override
  State<Staffdashboard> createState() => _StaffdashboardState();
}

class _StaffdashboardState extends State<Staffdashboard> {
  final AuthService _authService = AuthService(); // Instance of AuthService
  
   Future<void> _signOut() async {
    try {
      await _authService.signOut(context); // Pass context here
    } catch (e) {
      // Handle any errors here
      print('Error signing out: $e');
    }
  }  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
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
          'Welcome to the Staff Dashboard',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
