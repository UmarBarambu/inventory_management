import 'package:flutter/material.dart';
import 'package:inventory_management/models/vendor.dart'; // Import the Vendor model
import 'package:inventory_management/screens/home/activities/add_product.dart';
import 'package:inventory_management/services/vendor_database.dart';
import 'package:inventory_management/shared/constant.dart'; // Import the VendorDatabase service

class AddVendor extends StatefulWidget {
  final bool isFromDrawer;
  const AddVendor({super.key, this.isFromDrawer = true});

  @override
  State<AddVendor> createState() => _AddVendorState();
}

class _AddVendorState extends State<AddVendor> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();

  
  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }
  final VendorDatabase _vendorDatabase =  VendorDatabase(); // Instance of VendorDatabase

void _submitForm() async {
  print("Button pressed"); // Debug print
  if (_formKey.currentState?.validate() ?? false) {
    print("Form is valid"); // Debug print

    // Check if a vendor with the same name exists
    bool exists = await _vendorDatabase.vendorExists(_nameController.text);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vendor with this "${_nameController.text}" already exists!')),
      );
      return; // Exit the function if vendor exists
    }

    // Create a unique ID for the vendor
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    // Create a Vendor instance
    final Vendor vendor = Vendor(
      id: id,
      name: _nameController.text,
      contact: _contactController.text,
      address: _addressController.text,
      createdAt: DateTime.now(),
    );

    try {
      // Add the vendor to the database
      await _vendorDatabase.addVendor(vendor);
      print("Vendor added: ${vendor.name}"); // Debug print

      // Show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vendor ${vendor.name} added!')),
      );

      // Clear the form
      _formKey.currentState?.reset();
      _nameController.clear();
      _contactController.clear();
      _addressController.clear();
      _next();
    } catch (e) {
      print("Error: $e"); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add vendor: ${e.toString()}')),
      );
    }
  } else {
    print("Form is not valid"); // Debug print
  }
}


  void _next() {
    if (widget.isFromDrawer) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AddProduct()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Vendor',
         style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vendor Name',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: textInputD, // Ensure this is defined in constants
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the vendor name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Contact',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                ),
                TextFormField(
                  controller: _contactController,
                  decoration: textInputD, // Ensure this is defined in constants
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the contact details';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Address',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: textInput, // Ensure this is defined in constants
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Button color
                      foregroundColor: Colors.white, // Text color
                    ),
                    child: const Text('Add Vendor'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
