import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/services/database.dart';
import 'package:logger/logger.dart';

class AdminOnUsers extends StatefulWidget {
  const AdminOnUsers({super.key});

  @override
  State<AdminOnUsers> createState() => _AdminOnUsersState();
}

class _AdminOnUsersState extends State<AdminOnUsers> {
  final DatabaseService _databaseService = DatabaseService(); // Initialize DatabaseService
  Map<String, String> userRoles = {}; // Track roles for each user
  Map<String, bool> userActiveStatus = {}; // Track active status for each user

  // Method to delete a user by calling the DatabaseService
  Future<void> _deleteUser(String userId) async {
    await _databaseService.deleteUserById(userId);
    setState(() {}); // Refresh the UI after deletion
  }

  // Method to update user active status
  Future<void> _updateUserStatus(String userId, bool isActive) async {
    try {
      setState(() {
        userActiveStatus[userId] = isActive;
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'isActive': isActive});
    } catch (e) {
      Logger().e('Error updating user status: $e');
    }
  }

  // Method to update user role
  Future<void> _updateUserRole(String userId, String role) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'role': role});
      setState(() {
        userRoles[userId] = role; // Update the role in the map
      });
    } catch (e) {
      Logger().e('Error updating user role: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Current Staffs',
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .where('role', isNotEqualTo: 'admin') // Exclude admin users
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found'));
          } else {
            final users = snapshot.data!.docs;

            // Initialize userRoles map
            userRoles = {
              for (var userDoc in users) 
                userDoc.id: (userDoc.data() as Map<String, dynamic>)['role'] ?? 'N/A'
            };

            // Initialize userActiveStatus map
            userActiveStatus = {
              for (var userDoc in users) 
                userDoc.id: (userDoc.data() as Map<String, dynamic>)['isActive'] ?? true
            };

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DataTable(
                  columnSpacing: 18.0,
                  columns: <DataColumn>[
                    DataColumn(
                      label: Container(
                        color: Colors.grey,
                        padding: const EdgeInsets.all(8.0),
                        child: const Text(
                          'First Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        color: Colors.grey,
                        padding: const EdgeInsets.all(8.0),
                        child: const Text(
                          'Last Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        color: Colors.grey,
                        padding: const EdgeInsets.all(8.0),
                        child: const Text(
                          'Phone Number',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        color: Colors.grey,
                        padding: const EdgeInsets.all(8.0),
                        child: const Text(
                          'Email',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        color: Colors.grey,
                        padding: const EdgeInsets.all(8.0),
                        child: const Text(
                          'Role',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        color: Colors.grey,
                        padding: const EdgeInsets.all(8.0),
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        color: Colors.grey,
                        padding: const EdgeInsets.all(8.0),
                        child: const Text(
                          'Actions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                  rows: users.map((userDoc) {
                    final user = userDoc.data() as Map<String, dynamic>;
                    final userId = userDoc.id;
                    final phoneNumber = user['phoneNumber'] ?? 'N/A';
                    final role = userRoles[userId] ?? 'N/A'; // Use tracked role
                    final isActive = userActiveStatus[userId] ?? true; // Use tracked status

                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(user['firstName'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                        DataCell(Text(user['lastName'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                        DataCell(Text(phoneNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                        DataCell(Text(user['email'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                        DataCell(
                          DropdownButton<String>(
                            value: role,
                            items: <String>['staff', 'manager'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                _updateUserRole(userId, newValue);
                              }
                            },
                          ),
                        ),
                        DataCell(
                          Checkbox(
                            value: isActive,
                            onChanged: (bool? newValue) {
                              if (newValue != null) {
                                _updateUserStatus(userId, newValue);
                              }
                            },
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteUser(userId),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
