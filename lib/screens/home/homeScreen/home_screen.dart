import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/screens/home/activities/add_product.dart';
import 'package:inventory_management/screens/home/activities/edit_only_stock.dart';
import 'package:inventory_management/screens/home/activities/update.dart';
import 'package:inventory_management/screens/home/details/productDetails.dart';
import 'package:inventory_management/screens/home/generate_invoice/invoice.dart'; // Ensure this import is correct

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  


  @override
  void initState() {
    super.initState();
   
  }

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add history')),
      );
    }
  }

  // Define the _renameCategory method
  Future<void> _renameCategory(
      BuildContext context, String categoryId, String currentName) async {
// Initialize with the current name
    TextEditingController categoryController =
        TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rename Category'),
          content: TextField(
            controller: categoryController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter new category name',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
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
                String trimmedName = categoryController.text.trim();
                if (trimmedName.isEmpty) {
                  // Show error if the new name is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Category name cannot be empty')),
                  );
                  return;
                }

                try {
                  // Begin a batch write
                  WriteBatch batch = _firestore.batch();

                  // Update the category name in Firestore
                  DocumentReference categoryRef =
                      _firestore.collection('categories').doc(categoryId);
                  batch.update(categoryRef, {'name': trimmedName});

                  // Fetch all products with the old category name
                  QuerySnapshot productsSnapshot = await _firestore
                      .collection('products')
                      .where('category_name', isEqualTo: currentName)
                      .get();

                  // Update each product's category_name to the new name
                  for (var doc in productsSnapshot.docs) {
                    DocumentReference productRef =
                        _firestore.collection('products').doc(doc.id);
                    batch.update(productRef, {'category_name': trimmedName});
                  }

                  // Commit the batch
                  await batch.commit();

                  Navigator.of(context).pop(); // Close the dialog

                  // Optionally, show a success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Category renamed successfully')),
                  );
                } catch (e) {
                  debugPrint('Failed to rename category: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to rename category')),
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
                await _deleteProduct(context, productId); // Proceed with deletion
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

 // Method to delete the category
Future<void> _deleteCategory(BuildContext context, String categoryId, String categoryName) async {
  try {
    // Check if the category has associated products
    QuerySnapshot productsSnapshot = await _firestore
        .collection('products')
        .where('category_name', isEqualTo: categoryName)
        .get();

    if (productsSnapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete category with existing products.')),
      );
      return;
    }

    // Proceed with deletion
    await _firestore.collection('categories').doc(categoryId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Category deleted successfully')),
    );
  } catch (e) {
    debugPrint('Failed to delete category: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to delete category')),
    );
  }
}

  Future<void> _deleteProduct(BuildContext context, String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      debugPrint('Product deleted successfully');
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully')),
      );
    } catch (e) {
      debugPrint('Failed to delete product: $e');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete product')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Home',
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
              ),
            );
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
                   child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Use spaceBetween to push icons to the end
                        children: [
                          Expanded(
                            child: Text(
                          categoryName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                         ),
                          IconButton(
                            icon: const Icon(Icons.edit,
                                size: 20.0, color: Colors.black),
                            onPressed: () {
                              // Call the _renameCategory method with context, category.id, categoryName
                              _renameCategory(context, category.id, categoryName);
                            },
                          ),
                           IconButton(
                                icon: const Icon(Icons.delete, size: 20.0, color: Colors.red),
                              onPressed: () {
                                _deleteCategory(context, category.id, categoryName);
                               },
                            ),
                      ],
                    ),
                  ),

                  // Products under the Category
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

                      if (!productSnapshot.hasData ||
                          productSnapshot.data!.docs.isEmpty) {
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
                                        child: TextButton(
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
                                        IconButton(
                                          icon: const Icon(Icons.more_vert),
                                          onPressed: () =>
                                              _showBottomMenu(context, product),
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
   
    floatingActionButton: Column(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const InvoiceScreen(),
          ),
        );
      },
      backgroundColor: Colors.blue,
      child: const Icon(
        Icons.trolley,
        color: Colors.white,
        size: 35,
      ),
    ),
    const SizedBox(height: 16), // Space between the buttons
    FloatingActionButton(
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
  ],
),

  );
}
}