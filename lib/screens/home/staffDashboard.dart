import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_management/screens/home/activities/add_category.dart';
import 'package:inventory_management/screens/home/activities/add_product.dart';
import 'package:inventory_management/screens/home/activities/add_vendor.dart';
import 'package:inventory_management/services/auth.dart';

class Staffdashboard extends StatefulWidget {
  const Staffdashboard({super.key});

  @override
  State<Staffdashboard> createState() => _StaffdashboardState();
}

class _StaffdashboardState extends State<Staffdashboard> {
  final AuthService _authService = AuthService(); // Instance of AuthService
  int _selectedIndex = 0; // Track selected index
  File? _profileImage; // Variable to store the picked image
  String _userName = ''; // Variable to store the user's name
  String _roleName = ''; // Variable to store the user's role

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  // Method to fetch user details from Firestore
Future<void> _fetchUserDetails() async {
  try {
    // Get current user ID
    String? uid = _authService.getCurrentUserId();
    if (uid != null) {
      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        setState(() {
          _userName = '${userDoc['firstName']} ${userDoc['lastName']}'; // Update the user's name
          _roleName = userDoc['role']; // Update the user's role
        });
      }
    }
  } catch (e) {
    print('Error fetching user details: $e');
  }
}


  // Method to sign out
  Future<void> _signOut() async {
    try {
      await _authService.signOut(context); // Pass context here
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
    }
  }

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path); // Store the picked image
      });
    }
  }

  // Method to handle screen changes based on selected index
  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const Center(child: Text('Home Screen', style: TextStyle(fontSize: 24)));
      case 1:
        return const Center(child: Text('History Screen', style: TextStyle(fontSize: 24)));
      case 2:
        return const Center(child: Text('Chart Screen', style: TextStyle(fontSize: 24)));
      default:
        return const Center(child: Text('Unknown Screen', style: TextStyle(fontSize: 24)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white,
      appBar: AppBar(
        title: const Text(
                'StockMate',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
       backgroundColor:  Colors.blue.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.2, // Set the width to 20% of the screen width
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Profile Picture
                            CircleAvatar(
                                radius: 40,
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : null, // Use placeholder
                                // ignore: sort_child_properties_last
                                child: _profileImage == null
                                    ? const Icon(Icons.person, size: 30, color: Colors.black45)
                                    : null,
                                backgroundColor:  Colors.white,
                              ),

                        // Camera Icon
                        if (_profileImage == null) // Show camera icon only if no profile image is set
                          Positioned(
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, color: Colors.black, size: 24),
                              onPressed: _pickImage, // Call _pickImage method on tap
                            ),
                          ),
                      ],
                    ),
                    Text(
                    _userName.isNotEmpty ? _userName : 'Loading...', // Display user name
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2), // Add space between name and role
                  Text(
                    _roleName.isNotEmpty ? '($_roleName) ': 'Loading...', // Display user role
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ],
                ),
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.box),
                title: const Text('Add product',
                 style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),),
                onTap: () {
                  Navigator.of(context).pop(); // Close the drawer
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddProduct(), // Navigate to AdminProfile without parameters
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Add category',
                 style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),),
                onTap: () {
                  Navigator.of(context).pop(); // Close the drawer
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddCategory(), // Navigate to AdminProfile without parameters
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.fire_truck_rounded),
                title: const Text('Add vendor',
                 style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),),
                onTap: () {
                  Navigator.of(context).pop(); // Close the drawer
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddVendor(), // Navigate to AdminProfile without parameters
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings',  
                style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),),
                onTap: () {
                  Navigator.of(context).pop(); // Close the drawer
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout',  
                style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),),
                onTap: () {
                  Navigator.of(context).pop(); // Close the drawer
                  _signOut(); // Sign out
                },
              ),
              const Divider(), // Divider for separation
            ],
          ),
        ),
      ),
      body: _getScreen(_selectedIndex), // Show the screen based on the selected index
      bottomNavigationBar:  BottomNavigationBar(
  currentIndex: _selectedIndex,
  backgroundColor:  Colors.blue.shade100,
  onTap: (index) {
    setState(() {
      _selectedIndex = index;
    });
  },
  selectedItemColor: Colors.black, // Color for the selected item
  unselectedItemColor: Colors.black87, // Color for unselected items
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.history),
      label: 'History',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.bar_chart),
      label: 'Chart',
    ),
  ],
),
    );
  }
}

// Custom Search Delegate
class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Implement search result logic
    return Center(
      child: Text('Search result for "$query"'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Provide search suggestions as the user types
    final suggestions = query.isEmpty
        ? ['Suggestion 1', 'Suggestion 2']
        : ['Result 1', 'Result 2']; // You can customize this as needed

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]),
          onTap: () {
            query = suggestions[index];
            showResults(context); // Show results when a suggestion is tapped
          },
        );
      },
    );
  }
}

extension on AuthService {
  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }
}


