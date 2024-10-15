// lib/screens/invoice/second_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';



/// Second Page for Selecting Products
class SecondPage extends StatefulWidget {
  final String customerName;
  final String contact;

  const SecondPage({
    Key? key,
    required this.customerName,
    required this.contact,
  }) : super(key: key);

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _products = [];
  List<Map<String, dynamic>> _selectedProducts = [];
  List<String> _excludedProductIds = []; // To exclude products added via 'Next'

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Fetch products from Firestore
  void _fetchProducts() {
    _firestore.collection('products').snapshots().listen((snapshot) {
      setState(() {
        _products = snapshot.docs;
      });
    });
  }

  /// Filter products based on search query
  void _filterProducts() {
    setState(() {});
  }

  /// Toggle product selection (for checkboxes if needed elsewhere)
  void _toggleProductSelection(DocumentSnapshot product) {
    String productId = product.id;
    String productName = product['name'] ?? 'Unnamed Product';
    double sellingPrice = (product['sellingPrice'] ?? 0.0).toDouble();
    int stock = (product['stock'] ?? 0).toInt();

    setState(() {
      int index = _selectedProducts.indexWhere((p) => p['id'] == productId);
      if (index == -1) {
        _selectedProducts.add({
          'id': productId,
          'name': productName,
          'sellingPrice': sellingPrice,
          'stock': stock,
          'quantity': 1, // Default quantity
        });
      } else {
        _selectedProducts.removeAt(index);
      }
    });
  }

  /// Show modal bottom sheet for quantity input and action buttons
  void _showProductDetails(DocumentSnapshot product) {
    String productId = product.id;
    String productName = product['name'] ?? 'Unnamed Product';
    double sellingPrice = (product['sellingPrice'] ?? 0.0).toDouble();
    int stock = (product['stock'] ?? 0).toInt();

    TextEditingController _quantityController =
        TextEditingController(text: '1');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // To make the modal full height if needed
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16.0,
            left: 16.0,
            right: 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wrap content
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // Optional: Validate input here
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // "Next" Button Action
                      int quantity =
                          int.tryParse(_quantityController.text) ?? 1;
                      quantity = quantity < 1 ? 1 : quantity; // Ensure quantity is at least 1

                      setState(() {
                        // Add to selected products
                        _selectedProducts.add({
                          'id': productId,
                          'name': productName,
                          'sellingPrice': sellingPrice,
                          'stock': stock,
                          'quantity': quantity,
                        });
                        // Exclude from main list
                        _excludedProductIds.add(productId);
                      });

                      Navigator.pop(context); // Close the modal

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('$productName added to order!')),
                      );
                    },
                    child: const Text('Next'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      // "View" Button Action
                      Navigator.pop(context); // Close the modal
                      _confirmSelection();
                    },
                    child: const Text('View'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  /// Confirm selection and navigate to Order Confirmation Page
  void _confirmSelection() {
    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one product')),
      );
      return;
    }

    // Navigate to the confirmation page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationPage(
          selectedProducts: _selectedProducts,
          customerName: widget.customerName,
          contact: widget.contact,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String query = _searchController.text.toLowerCase();

    // Filter products based on search query and excluded product IDs
    List<DocumentSnapshot> filteredProducts = _products.where((product) {
      String name = (product['name'] ?? '').toString().toLowerCase();
      return name.contains(query) && !_excludedProductIds.contains(product.id);
    }).toList();

    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Select Products'),
      ),
      body: SafeArea(child:
      Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Product',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // Product List
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: Text('No products found.'))
                : ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      var product = filteredProducts[index];
                      String productName = product['name'] ?? 'Unnamed Product';
                      double sellingPrice =
                          (product['sellingPrice'] ?? 0.0).toDouble();
                      int stock = (product['stock'] ?? 0).toInt();

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: ListTile(
                          title: Text(productName),
                          subtitle: Text(
                              'Price: N${sellingPrice.toStringAsFixed(2)} | Stock: $stock'),
                          trailing: Checkbox(
                            value: _selectedProducts
                                .any((p) => p['id'] == product.id),
                            onChanged: (bool? value) {
                              // When checkbox is tapped, show the modal to enter quantity
                              _showProductDetails(product);
                            },
                          ),
                          onTap: () {
                            // Also show the modal when the tile is tapped
                            _showProductDetails(product);
                          },
                        ),
                      );
                    },
                  ),
          ),
          // Selected Products and Actions
          if (_selectedProducts.isNotEmpty)
            Expanded(
              child: Column(
                children: [
                  const Divider(),
                  const Text(
                    'Selected Products',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  
                  Expanded(
                    child: ListView.builder(
                      itemCount: _selectedProducts.length,
                      itemBuilder: (context, index) {
                        var product = _selectedProducts[index];
                        return ListTile(
                          title: Text(product['name']),
                          subtitle: Text(
                              'Price: N${product['sellingPrice'].toStringAsFixed(2)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 50,
                                child: TextButton(child: Text(product['quantity'].toString(),) , onPressed: (){
                                   showModalBottomSheet(
      context: context,
      isScrollControlled: true, // To make the modal full height if needed
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16.0,
            left: 16.0,
            right: 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wrap content
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                                  TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'Qty',
                                  ),
                                  onChanged: (value) {
                                    // Validate input to ensure it's a positive integer
                                    int quantity = int.tryParse(value) ?? 1;
                                    quantity = quantity < 1 ? 1 : quantity; // Ensure quantity is at least 1
                                    _updateProductQuantity(
                                        product['id'], quantity);
                                  },
                                  controller: TextEditingController(
                                    text: product['quantity'].toString(),
                                  ),
                                ),
             
                            ],
          ),
          );
      }
                                   );
                                }
                                ),
                              ),
                          

                                   
   
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  // Remove product from selection
                                  setState(() {
                                    _selectedProducts.removeAt(index);
                                    _excludedProductIds
                                        .remove(product['id']); // Re-include in list
                                  });
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            // Optionally, allow editing quantity by tapping
                            _showProductDetails(
                                _products.firstWhere((p) => p.id == product['id']));
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _confirmSelection,
                    child: const Text('Confirm Selection'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50), // Full width button
                    ),
                  ),
                ],
              ),
            
            ),
        ],
      ),
      ),
      // Remove FloatingActionButton to avoid multiple tags
    );
  }

  void _updateProductQuantity(String productId, int quantity) {
    int index = _selectedProducts.indexWhere((p) => p['id'] == productId);
    if (index != -1) {
      setState(() {
        _selectedProducts[index]['quantity'] = quantity;
      });
    }
  }
}

/// Order Confirmation Page
class OrderConfirmationPage extends StatelessWidget {
  final List<Map<String, dynamic>> selectedProducts;
  final String customerName;
  final String contact;

  const OrderConfirmationPage({
    Key? key,
    required this.selectedProducts,
    required this.customerName,
    required this.contact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate total amount
    double totalAmount = selectedProducts.fold(
      0.0,
      (sum, item) =>
          sum + ((item['sellingPrice'] ?? 0.0) * (item['quantity'] ?? 1)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmation'),
      ),
      body:SafeArea(child: 
     Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Customer Details
            Text(
              'Customer: $customerName\nContact: $contact',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 30, thickness: 2),
            // Products List
            Expanded(
              child: ListView.builder(
                itemCount: selectedProducts.length,
                itemBuilder: (context, index) {
                  var product = selectedProducts[index];
                  return ListTile(
                    title: Text(product['name']),
                    subtitle: Text(
                        'Quantity: ${product['quantity']} | Price: N${(product['sellingPrice'] * product['quantity']).toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            // Total Amount
            Text(
              'Total Amount: N${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Confirm Invoice Button
            ElevatedButton(
              onPressed: () {
                // Handle invoice confirmation logic here
                _createInvoice(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invoice confirmed!')),
                );

                // Optionally, navigate back to Home or another page
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Confirm Invoice'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50), // Full width button
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  // Method to create an invoice in Firestore
  void _createInvoice(BuildContext context) async {
    try {
      double totalAmount = selectedProducts.fold(
        0.0,
        (sum, item) =>
            sum + ((item['sellingPrice'] ?? 0.0) * (item['quantity'] ?? 1)),
      );

      await FirebaseFirestore.instance.collection('invoices').add({
        'customerName': customerName,
        'contact': contact,
        'products': selectedProducts,
        'date': DateTime.now(),
        'totalAmount': totalAmount,
      });

      // Optionally, show a success message or navigate
    } catch (e) {
      debugPrint('Failed to create invoice: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create invoice')),
      );
    }
  }
}
