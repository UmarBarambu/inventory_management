import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Vendordetails extends StatefulWidget {
  const Vendordetails({super.key});

  @override
  State<Vendordetails> createState() => _VendordetailsState();
}

class _VendordetailsState extends State<Vendordetails> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? userRole; 
  bool isLoading = true; 

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        setState(() {
          userRole = userDoc['role'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user is currently logged in.')),
        );
      }
    } catch (e) {
      debugPrint('Failed to fetch user role: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch user role')),
      );
    }
  }

  Future<void> _renameVendor(BuildContext context, String vendorId, String currentName) async {
    TextEditingController vendorController = TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rename Vendor'),
          content: TextField(
            controller: vendorController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter new vendor name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String trimmedName = vendorController.text.trim();
                if (trimmedName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vendor name cannot be empty')),
                  );
                  return;
                }

                try {
                  WriteBatch batch = _firestore.batch();
                  DocumentReference vendorRef = _firestore.collection('vendors').doc(vendorId);
                  batch.update(vendorRef, {'name': trimmedName});

                  QuerySnapshot productsSnapshot = await _firestore
                      .collection('products')
                      .where('vendor_name', isEqualTo: currentName)
                      .get();

                  for (var doc in productsSnapshot.docs) {
                    DocumentReference productRef = _firestore.collection('products').doc(doc.id);
                    batch.update(productRef, {'vendor_name': trimmedName});
                  }

                  await batch.commit();

                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vendor renamed successfully')),
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

  // Method to delete the vendor
  Future<void> _deleteVendor(BuildContext context, String vendorId, String vendorName) async {
    try {
      // Check if the vendor has associated products
      QuerySnapshot productsSnapshot = await _firestore
          .collection('products')
          .where('vendor_name', isEqualTo: vendorName)
          .get();

      if (productsSnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot delete vendor with existing products.')),
        );
        return;
      }

      // Proceed with deletion
      await _firestore.collection('vendors').doc(vendorId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vendor deleted successfully')),
      );
    } catch (e) {
      debugPrint('Failed to delete vendor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete vendor')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
        stream: _firestore.collection('vendors').snapshots(),
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
              String vendorId = vendor.id;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.grey[100],
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                   child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Use spaceBetween to push icons to the end
                        children: [
                          Expanded(
                            child: Text(
                              vendorName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Edit Icon
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20.0, color: Colors.black),
                            onPressed: () {
                              _renameVendor(context, vendorId, vendorName);
                            },
                          ),
                          // Delete Icon
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20.0, color: Colors.red),
                            onPressed: () {
                              _deleteVendor(context, vendorId, vendorName);
                            },
                          ),
                        ],
                      ),

                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('products')
                        .where('vendor_name', isEqualTo: vendorName)
                        .snapshots(),
                    builder: (context, productSnapshot) {
                      if (productSnapshot.hasError) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Failed to load products.'),
                        );
                      }
                      if (!productSnapshot.hasData || productSnapshot.data!.docs.isEmpty) {
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        child: Text(
                                          '$stock',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          productName,
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (idx < productSnapshot.data!.docs.length - 1)
                                const Divider(height: 1, thickness: 1, color: Colors.grey),
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
    );
  }
}
