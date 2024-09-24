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
import 'package:inventory_management/screens/home/activities/searchProduct.dart';
import 'package:inventory_management/screens/home/charts/chart.dart';
import 'package:inventory_management/screens/home/history/history_screen.dart';
import 'package:inventory_management/screens/home/homeScreen/home_screen.dart';
import 'package:inventory_management/services/auth.dart';

class Managerdashboard extends StatefulWidget {
  const Managerdashboard({super.key});

  @override
  State<Managerdashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<Managerdashboard> {
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
    if (kDebugMode) {
      print('Error fetching user details: $e');
    }
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
      return const  HomeScreen(); // Return the HomeScreen widget
    case 1:
      return const History(history: [],); // Return the HistoryScreen widget
    case 2:
      return const Stock(); // Return the ChartScreen widget
    default:
      return const Center(child: Text('Unknown Screen', style: TextStyle(fontSize: 24)));
  }
}

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Available Stock';
      case 1:
        return 'History';
      case 2:
        return 'Chart';
      default:
        return 'Dashboard';
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white,
         appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0), // Set the height of the AppBar
        child:
         AppBar(
        title: Text(
          _getAppBarTitle(_selectedIndex),
          style: const TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
            color: Colors.lightBlue,
          ),
        ),
        centerTitle: true,
         backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductSearchScreen()),
              );
            },
          ),
         
        ],
      ),
         ),
       drawer: Drawer(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.2, // Set the width to 20% of the screen width
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.lightBlue,
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
                                backgroundColor: Colors.white,
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
                    const SizedBox(height: 8), // Add spacing between avatar and text
                    Text(
                    _userName.isNotEmpty ? _userName : 'Loading...', // Display user name
                    style: const TextStyle(
                       color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2), // Add space between name and role
                  Text(
                    _roleName.isNotEmpty ? '($_roleName) ': 'Loading...', // Display user role
                    style: const TextStyle(
                     color: Colors.white,
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
                 style: TextStyle(
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
                 style: TextStyle(
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
                 style:  TextStyle(
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
                style:  TextStyle(
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
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout',   
                style:  TextStyle(
                        color: Colors.red,
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
      bottomNavigationBar: BottomNavigationBar(
         backgroundColor: Colors.white,
  currentIndex: _selectedIndex,
  onTap: (index) {
    setState(() {
      _selectedIndex = index;
    });
  },
  selectedItemColor: Colors.blue, // Color for the selected item
  unselectedItemColor: Colors.grey, // Color for unselected items
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

extension on AuthService {
  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }
}
