import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/screens/home/activities/add_product.dart';
import 'package:inventory_management/screens/home/activities/edit_only_stock.dart';
import 'package:inventory_management/screens/home/activities/update.dart';
import 'package:inventory_management/screens/home/details/productDetails.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProductSearchScreenState createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String searchQuery = '';
  String? userRole; // Variable to store the user's role
  bool isLoading = true; // Indicates if user role is being fetched

  @override
  void initState() {
    super.initState();
    _getUserRole(); // Fetch user role when screen initializes
  }

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
      }
    } catch (e) {
      debugPrint('Failed to fetch user role: $e');
      setState(() {
        isLoading = false; // Error occurred, stop loading
      });
    }
  }

  // Function to add a history record to Firestore
  Future<void> _addToHistory(
      String productName, int amount, String action, DateTime date) async {
    try {
      await _firestore.collection('history').add({
        'productName': productName,
        'amount': amount,
        'action': action,
        'date': date,
      });
    } catch (e) {
      debugPrint('Failed to add history: $e');
    }
  }

  void _showBottomMenu(BuildContext context, DocumentSnapshot product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? 'Unnamed Product',
                  style:
                      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.folder),
                  title: const Text('Change Catalog'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditStockNo(
                          product: product,
                          updateHistory: _addToHistory,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit'),
                  onTap: () {
                    Navigator.pop(context); // Close the modal
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UpdateProductScreen(product: product),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Delete'),
                  onTap: () {
                    Navigator.pop(context); // Close the modal
                    _confirmDeleteProduct(context, product.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteProduct(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _deleteProduct(productId); // Proceed with deletion
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      debugPrint('Product deleted successfully');
      // Optionally, you can add a snackbar or another form of feedback here
    } catch (e) {
      debugPrint('Failed to delete product: $e');
      // Optionally, show an error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while fetching the user role
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            'Product Search',
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Product Search',
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value; // Update search query
                });
              },
              decoration: InputDecoration(
                hintText: 'Search products',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  borderSide:
                      BorderSide(color: Colors.blue, width: 2.0),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('products').snapshots(),
        builder: (context, productSnapshot) {
          if (productSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.lightBlue),
              ),
            );
          }

          if (productSnapshot.hasError) {
            return const Center(child: Text('Failed to load products.'));
          }

          // Filter products based on search query
          var filteredProducts = productSnapshot.data!.docs.where((doc) {
            final productName = doc['name']?.toString().toLowerCase() ?? '';
            return productName.contains(searchQuery.toLowerCase());
          }).toList();

          if (filteredProducts.isEmpty) {
            return const Center(child: Text('No products found.'));
          }

          return ListView.builder(
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              var product = filteredProducts[index];
              String productName = product['name'] ?? 'Unnamed Product';
              double sellingPrice =
                  product['sellingPrice']?.toDouble() ?? 0.0;
              int stock = product['stock']?.toInt() ?? 0;

              return Column(
                children: [
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 0),
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
                            child: (userRole == 'admin' ||
                                    userRole == 'manager')
                                ? TextButton(
                                    onPressed: () {
                                      // Navigate to the ProductDetails screen
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProductDetails(
                                                  productId: product.id),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      productName,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  )
                                : Text(
                                    productName,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Text(
                              'N${sellingPrice.toStringAsFixed(2)}',
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          // Conditionally show the icon based on user role
                          if (userRole == 'admin' || userRole == 'manager')
                            IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () => _showBottomMenu(context, product),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    thickness: 1,
                    color: Colors.grey,
                    height: 1,
                  ),
                ],
              );
            },
          );
        },
      ),
      // Conditionally show the FAB based on user role
      floatingActionButton:FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddProduct(),
                  ),
                );
              },
              backgroundColor: Colors.blue,
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 35,
              ),
            )
     
    );
  }
}
