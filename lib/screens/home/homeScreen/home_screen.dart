import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/screens/home/activities/add_product.dart';
import 'package:inventory_management/screens/home/activities/edit_only_stock.dart';
import 'package:inventory_management/screens/home/activities/update.dart';
import 'package:inventory_management/screens/home/details/productDetails.dart'; // Ensure to import your ProductDetail screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? userRole; // Variable to store the user's role

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
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        setState(() {
          userRole = userDoc['role']; // Fetch role from Firestore
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch user role: $e');
    }
  }

  Future<void> _addToHistory(String productName, int amount, String action, DateTime date) async {
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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      builder: (context) => UpdateProductScreen(product: product),
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
    } catch (e) {
      debugPrint('Failed to delete product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
            ));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load categories.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No categories found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var category = snapshot.data!.docs[index];
              String categoryName = category['name'] ?? 'Unnamed Category';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.grey[100],
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                    child: Text(
                      categoryName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('products')
                        .where('category_name', isEqualTo: categoryName)
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
                          child: Text('No products found.'),
                        );
                      }

                      return Column(
                        children: productSnapshot.data!.docs.asMap().entries.map((entry) {
                          int idx = entry.key;
                          var product = entry.value;
                          String productName = product['name'] ?? 'Unnamed Product';
                          double sellingPrice = product['sellingPrice']?.toDouble() ?? 0.0;
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
                                        child: userRole == 'admin' || userRole == 'manager'
                                            ? TextButton(
                                                onPressed: () {
                                                  // Push to the ProductDetail class, passing the product data
                                                Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ProductDetails(productId: product.id),
                                              ),
                                            );
                                                },
                                                child: Text(
                                                  productName,
                                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color:Colors.black),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              )
                                            : Text(
                                                productName,
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                      ),
                                      SizedBox(
                                        width: 80,
                                        child: Text(
                                          'N${sellingPrice.toStringAsFixed(2)}',
                                          textAlign: TextAlign.end,
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
      floatingActionButton: FloatingActionButton(
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
      ),
    );
  }
}
