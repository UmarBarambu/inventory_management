import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/screens/home/activities/add_category.dart';
import 'package:inventory_management/screens/home/activities/add_vendor.dart';
import 'package:inventory_management/services/account_service.dart';
import 'package:inventory_management/shared/constant.dart'; // Ensure this has textInputDecoration

class UpdateProductScreen extends StatefulWidget {
  final DocumentSnapshot? product;

  const UpdateProductScreen({super.key, this.product});

  @override
  State<UpdateProductScreen> createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String _productName = '';
  double _sellingPrice = 0.0;
  double _buyingPrice = 0.0;
  int _stock = 0;
  String _selectedCategory = '';
  String _selectedVendor = '';
  List<String> _categories = [];
  List<String> _vendors = [];

 double get totalProductValue => _buyingPrice * _stock;
 final ProductService _productService = ProductService(); 

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadVendors();

    if (widget.product != null) {
      _productName = widget.product!['name'] ?? '';
      _sellingPrice = widget.product!['sellingPrice']?.toDouble() ?? 0.0;
      _buyingPrice = widget.product!['buyingPrice']?.toDouble() ?? 0.0;
      _stock = widget.product!['stock']?.toInt() ?? 0;
      _selectedCategory = widget.product!['category_name'] ?? '';
      _selectedVendor = widget.product!['vendor_name'] ?? '';
    }
  }

  Future<void> _loadCategories() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      _categories = querySnapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  Future<void> _loadVendors() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('vendors').get();
    setState(() {
      _vendors = querySnapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  void _showSelectionDialog(String type) async {
    List<String> items = type == 'Category' ? _categories : _vendors;

    showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select $type'),
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...items.isEmpty
                      ? [Text('No $type found')]
                      : items.map((item) => RadioListTile<String>(
                            title: Text(item),
                            value: item,
                            groupValue: type == 'Category' ? _selectedCategory : _selectedVendor,
                            onChanged: (value) {
                              Navigator.of(context).pop(value);
                            },
                          )),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog  
                      if (type == 'Category') {
                         Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddCategory()));
                       } else if (type == 'Vendor') {
                         Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddVendor()));
                     }
                    },
                    child: Text('Add New $type'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    ).then((selectedItem) {
      if (selectedItem != null) {
        setState(() {
          if (type == 'Category') {
            _selectedCategory = selectedItem;
          } else {
            _selectedVendor = selectedItem;
          }
        });
      }
    });
  }

 

Future<void> _saveProduct() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    try {
      if (widget.product != null) {
        // Update existing product
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.product!.id)
            .update({
          'name': _productName,
          'sellingPrice': _sellingPrice,
          'buyingPrice': _buyingPrice,
          'stock': _stock,
          'category_name': _selectedCategory,
          'vendor_name': _selectedVendor,
          'totalProductValue': totalProductValue, // Update this line if necessary
        });
        debugPrint('Product updated successfully');
      } else {
        // Add new product
        await FirebaseFirestore.instance.collection('products').add({
          'name': _productName,
          'sellingPrice': _sellingPrice,
          'buyingPrice': _buyingPrice,
          'stock': _stock,
          'category_name': _selectedCategory,
          'vendor_name': _selectedVendor,
          'totalProductValue': totalProductValue, // Update this line if necessary
        });
        debugPrint('Product added successfully');
      }

      // Update the account balance after saving the product
      await _productService.updateTotalBalance() ;

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Failed to save product: $e');
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? 'Edit Product' : 'Add Product',
        style: const TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
          ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Add this line
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _productName,
                decoration: myTextInputDecoration.copyWith(labelText: 'Product Name'), // Ensure consistent use
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
                onSaved: (value) => _productName = value!,
              ),
               const SizedBox(height: 15),
              TextFormField(
                initialValue: _sellingPrice.toString(),
                decoration: myTextInputDecoration.copyWith(labelText: 'Selling Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
                onSaved: (value) => _sellingPrice = double.parse(value!),
              ),
               const SizedBox(height: 15),
              TextFormField(
                initialValue: _buyingPrice.toString(),
                decoration: myTextInputDecoration.copyWith(labelText: 'Buying Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
                onSaved: (value) => _buyingPrice = double.parse(value!),
              ),
               const SizedBox(height: 15),
              TextFormField(
                initialValue: _stock.toString(),
                decoration: myTextInputDecoration.copyWith(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Please enter a valid stock amount';
                  }
                  return null;
                },
                onSaved: (value) => _stock = int.parse(value!),
              ),
               const SizedBox(height: 15),
              GestureDetector(
                onTap: () => _showSelectionDialog('Category'),
                child: InputDecorator(
                  decoration: myTextInputDecoration.copyWith(labelText: 'Category'),
                  child: Text(_selectedCategory.isEmpty ? ' Category' : _selectedCategory),
                ),
              ),
               const SizedBox(height: 15),
              GestureDetector(
                onTap: () => _showSelectionDialog('Vendor'),
                child: InputDecorator(
                  decoration: myTextInputDecoration.copyWith(labelText: 'Vendor'),
                  child: Text(_selectedVendor.isEmpty ? 'Select Vendor' : _selectedVendor),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct,
                 style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // Set button color to blue
                            foregroundColor: Colors.white,
                 ),
                child: Text(widget.product != null ? 'Update Product' : 'Add Product'),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
