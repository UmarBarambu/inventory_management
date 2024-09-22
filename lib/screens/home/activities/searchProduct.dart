import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/screens/home/activities/editOnlyStock.dart';
import 'package:inventory_management/screens/home/activities/update.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  _ProductSearchScreenState createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  // Fetch all products based on the search query
  Future<List<DocumentSnapshot>> _fetchProducts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('products').get();
      return querySnapshot.docs.where((doc) {
        final productName = doc['name']?.toLowerCase() ?? '';
        return productName.contains(searchQuery.toLowerCase());
      }).toList();
    } catch (e) {
      debugPrint("Error fetching products: $e");
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
  isScrollControlled: true, // Allow the bottom sheet to take full height
  builder: (BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Use min size for the column
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
                Navigator.pop(context);
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
                Navigator.pop(context);
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

  Future<void> _deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      debugPrint('Product deleted successfully');
      setState(() {}); // Refresh the UI after deletion
    } catch (e) {
      debugPrint('Failed to delete product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:  Colors.white,
        centerTitle: true,
        title: const Text('Product Search',
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
                    borderRadius: BorderRadius.all(Radius.circular(20.0)), // Rounded edges
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)), // Rounded edges
                    borderSide: BorderSide(color: Colors.grey), // Gray border when not focused
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)), // Rounded edges
                    borderSide: BorderSide(color: Colors.blue, width: 2.0), // Thicker blue border when focused
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search, color: Colors.grey), // Search icon
                ),

            ),
          ),
        ),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _fetchProducts(), // Fetch products directly
        builder: (context, productSnapshot) {
          if (productSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productSnapshot.hasError) {
            return const Center(child: Text('Failed to load products.'));
          }

          if (!productSnapshot.hasData || productSnapshot.data!.isEmpty) {
            return const Center(child: Text('No products found.'));
          }

          return ListView.builder(
            itemCount: productSnapshot.data!.length,
            itemBuilder: (context, index) {
              var product = productSnapshot.data![index];
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
                // Add the divider between products
                const Divider(
                  thickness: 1, // Line thickness
                  color: Colors.grey, // Line color
                  height: 1, // Height between the Card and Divider
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
