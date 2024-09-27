import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:flutter/material.dart';

class Vendordetails extends StatefulWidget {
  const Vendordetails({super.key});

  @override
  State<Vendordetails> createState() => _VendordetailsState();
}

class _VendordetailsState extends State<Vendordetails> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Initialize FirebaseAuth

  String? userRole; // Variable to store the user's role
  bool isLoading = true; // Indicates if user role is being fetched

  @override
  void initState() {
    super.initState();
    _getUserRole(); // Fetch user role when screen initializes
  }

  // Method to fetch the current user's role
  Future<void> _getUserRole() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Assuming user roles are stored in the Firestore under a 'users' collection
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        setState(() {
          userRole = userDoc['role']; // Fetch role from Firestore
          isLoading = false; // Role fetched, stop loading
        });
      } else {
        setState(() {
          isLoading = false; // No user logged in, stop loading
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user is currently logged in.')),
        );
      }
    } catch (e) {
      debugPrint('Failed to fetch user role: $e');
      setState(() {
        isLoading = false; // Error occurred, stop loading
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch user role')),
      );
    }
  }

  // Method to rename the vendor and update associated products
  Future<void> _renameVendor(
      BuildContext context, String vendorId, String currentName) async {
    String newVendorName = currentName; // Initialize with the current name
    TextEditingController _vendorController =
        TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rename Vendor'),
          content: TextField(
            controller: _vendorController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter new vendor name',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              newVendorName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String trimmedName = _vendorController.text.trim();
                if (trimmedName.isEmpty) {
                  // Show error if the new name is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Vendor name cannot be empty')),
                  );
                  return;
                }

                try {
                  // Begin a batch write
                  WriteBatch batch = _firestore.batch();

                  // Update the vendor name in Firestore
                  DocumentReference vendorRef =
                      _firestore.collection('vendors').doc(vendorId);
                  batch.update(vendorRef, {'name': trimmedName});

                  // Fetch all products with the old vendor name
                  QuerySnapshot productsSnapshot = await _firestore
                      .collection('products')
                      .where('vendor_name', isEqualTo: currentName)
                      .get();

                  // Update each product's vendor_name to the new name
                  for (var doc in productsSnapshot.docs) {
                    DocumentReference productRef =
                        _firestore.collection('products').doc(doc.id);
                    batch.update(productRef, {'vendor_name': trimmedName});
                  }

                  // Commit the batch
                  await batch.commit();

                  Navigator.of(context).pop(); // Close the dialog

                  // Show a success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Vendor renamed successfully')),
                  );
                } catch (e) {
                  debugPrint('Failed to rename vendor: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to rename vendor')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while fetching the user role
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Vendor Details'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Details'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('vendors').snapshots(), // Change to your vendor collection
        builder: (context, vendorSnapshot) {
          if (vendorSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vendorSnapshot.hasError) {
            return const Center(child: Text('Failed to load vendors.'));
          }
          if (!vendorSnapshot.hasData || vendorSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No vendors found.'));
          }

          return ListView.builder(
            itemCount: vendorSnapshot.data!.docs.length,
            itemBuilder: (context, vendorIndex) {
              var vendor = vendorSnapshot.data!.docs[vendorIndex];
              String vendorName = vendor['name'] ?? 'Unnamed Vendor';
              String vendorId = vendor.id; // Get the vendor document ID

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vendor Header with Conditional Edit Icon
                  Container(
                    width: double.infinity,
                    color: Colors.grey[100],
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          vendorName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Show Edit Icon only for Admin and Manager
                        if (userRole == 'admin' || userRole == 'manager')
                          IconButton(
                            icon: const Icon(Icons.edit,
                                size: 20.0, color: Colors.black),
                            onPressed: () {
                              // Call the _renameVendor method with context, vendor.id, vendorName
                              _renameVendor(context, vendorId, vendorName);
                            },
                          ),
                      ],
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('products')
                        .where('vendor_name', isEqualTo: vendorName) // Fetch products by vendor name
                        .snapshots(),
                    builder: (context, productSnapshot) {
                      if (productSnapshot.hasError) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Failed to load products.'),
                        );
                      }
                      if (!productSnapshot.hasData ||
                          productSnapshot.data!.docs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('No products found for this vendor.'),
                        );
                      }

                      return Column(
                        children: productSnapshot.data!.docs.asMap().entries.map((entry) {
                          int idx = entry.key;
                          var product = entry.value;
                          String productName = product['name'] ?? 'Unnamed Product';
                          int stock = product['stock']?.toInt() ?? 0;

                          return Column(
                            children: [
                              Card(
                                margin: const EdgeInsets.only(top: 0, bottom: 0),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                                color: Colors.white,
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        child: Text(
                                          '$stock',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          productName,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (idx < productSnapshot.data!.docs.length - 1)
                                const Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Colors.grey),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    // Hide FAB for non-admin/manager users
    );
  }

  // Optional: If you have actions related to products, implement them here
}
