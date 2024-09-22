import 'package:flutter/material.dart';
import 'package:inventory_management/models/product.dart';
import 'package:inventory_management/screens/home/activities/add_category.dart';
import 'package:inventory_management/screens/home/activities/add_vendor.dart';
import 'package:inventory_management/screens/home/homeScreen/homeScreen.dart';
import 'package:inventory_management/services/items.dart';
import 'package:inventory_management/services/productDatabase.dart';
import 'package:inventory_management/shared/constant.dart'; // Assuming you have a constant file with InputDecoration
import 'package:uuid/uuid.dart';

class AddProduct extends StatefulWidget {
  final bool isFromDrawer;
  const AddProduct({super.key, this.isFromDrawer = true});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _buyingPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _vendorController = TextEditingController();
  final _stockController = TextEditingController();

  final ProductDatabase _productDatabase =
      ProductDatabase(); // Instance of ProductDatabase

  void _showSelectionDialog(String type) async {
    List<Item> items = await _productDatabase.getItems(type);

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
                            title: Text(item.name),
                            value: item.id,
                            groupValue: type == 'Category'
                                ? _categoryController.text
                                : _vendorController.text,
                            onChanged: (value) {
                              Navigator.of(context)
                                  .pop(value); // Return the selected value
                            },
                          )),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      if (type == 'Category') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AddCategory(),
                          ),
                        );
                      } else if (type == 'Vendor') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AddVendor(
                            ),
                          ),
                        );
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
              child: Text('Done'),
            ),
          ],
        );
      },
    ).then((selectedItemId) {
      if (selectedItemId != null) {
        final selectedItem =
            items.firstWhere((item) => item.id == selectedItemId);
        if (type == 'Category') {
          _categoryController.text =
              selectedItem.name; // Use name if displaying name
        } else if (type == 'Vendor') {
          _vendorController.text =
              selectedItem.name; // Use name if displaying name
        }
      }
    });
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {

             // Check if a vendor with the same name exists
    bool exists = await _productDatabase.productExists(_nameController.text);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product with name "${_nameController.text}" already exists!')),

      );
      return; // Exit the function if vendor exists
    }

      final product = Product(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        buyingPrice: double.parse(_buyingPriceController.text.trim()),
        sellingPrice: double.parse(_sellingPriceController.text.trim()),
        category_name: _categoryController.text.trim(),
        vendor_name: _vendorController.text.trim(),
        stock: int.parse(_stockController.text.trim()),
        createdAt: DateTime.now(),
      );

      try {
        await _productDatabase.addProduct(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product ${product.name} added!')),
        );
        _formKey.currentState?.reset();
        _nameController.clear();
        _buyingPriceController.clear();
        _sellingPriceController.clear();
        _categoryController.clear();
        _vendorController.clear();
        _stockController.clear();
        _next();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: ${e.toString()}')),
        );
      }
    }
  }
  
    void _next() {
    if (widget.isFromDrawer) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Product',
         style: const TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Product Name',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: myTextInputDecoration,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the product name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Buying Price',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _buyingPriceController,
                        decoration: myTextInputDecoration.copyWith(hintText: ''),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the buying price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Selling Price',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _sellingPriceController,
                        decoration: myTextInputDecoration.copyWith(hintText: ''),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the selling price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Category',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _categoryController,
                        decoration:
                            myTextInputDecoration.copyWith(hintText: 'Select a category'),
                        onTap: () => _showSelectionDialog('Category'),
                        readOnly: true,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Vendor',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _vendorController,
                        decoration:
                            myTextInputDecoration.copyWith(hintText: 'Select a vendor'),
                        onTap: () => _showSelectionDialog('Vendor'),
                        readOnly: true,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Stock',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _stockController,
                        decoration: myTextInputDecoration.copyWith(hintText: ''),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the stock quantity';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.blue, // Set button color to blue
                          ),
                          child: const Text(
                            'Add Product',
                            style: TextStyle(
                              color: Colors.white, // Set text color to white
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
