import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/screens/home/activities/add_product.dart';
import 'package:inventory_management/screens/home/activities/editOnlyStock.dart';
import 'package:inventory_management/screens/home/activities/update.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // Fetch categories
  Future<List<DocumentSnapshot>> _fetchCategories() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('categories').get();
      return querySnapshot.docs;
    } catch (e) {
      debugPrint("Error fetching categories: $e");
      return [];
    }
  }

  // Fetch products for each category based on the search query
  Future<List<DocumentSnapshot>> _fetchProducts(String categoryName) async {
    try {
      debugPrint("Fetching products for category: $categoryName");
      QuerySnapshot querySnapshot = await _firestore
          .collection('products')
          .where('category_name', isEqualTo: categoryName)
          .get();
      return querySnapshot.docs.where((doc) {
        final productName = doc['name']?.toLowerCase() ?? '';
        return productName.contains(searchQuery.toLowerCase());
      }).toList();
    } catch (e) {
      debugPrint("Error fetching products for category $categoryName: $e");
      return [];
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
                          updateHistory: _addToHistory, // Pass the callback
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
                    _deleteProduct(product.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Delete the product
  Future<void> _deleteProduct(String productId) async {
    try {
      await deleteProduct(productId);
      debugPrint('Product deleted successfully');
      // Refresh the UI after deletion
      setState(() {});
    } catch (e) {
      debugPrint('Failed to delete product: $e');
    }
  }

  // The deleteProduct method that deletes the product from Firestore
  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
      debugPrint('Product deleted successfully');
    } catch (e) {
      debugPrint('Failed to delete product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load categories.'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No categories found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var category = snapshot.data![index];
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
                  FutureBuilder<List<DocumentSnapshot>>(
                    future: _fetchProducts(categoryName),
                    builder: (context, productSnapshot) {
                      if (productSnapshot.hasError) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Failed to load products.'),
                        );
                      }

                      if (!productSnapshot.hasData || productSnapshot.data!.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('No products found.'),
                        );
                      }

                      return Column(
                        children: productSnapshot.data!.asMap().entries.map((entry) {
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
                                        child: Text(
                                          productName,
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 80,
                                        child: Text(
                                          '\N${sellingPrice.toStringAsFixed(2)}',
                                          textAlign: TextAlign.end,
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.more_vert),
                                        onPressed: () => _showBottomMenu(context, product),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (idx < productSnapshot.data!.length - 1)
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
              builder: (context) => const AddProduct(), // Navigate to AddProduct page
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
