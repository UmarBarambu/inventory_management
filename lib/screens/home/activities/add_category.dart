import 'package:flutter/material.dart';
import 'package:inventory_management/models/category.dart'; // Import the Category model
import 'package:inventory_management/screens/home/activities/add_product.dart';
import 'package:inventory_management/services/category_database.dart';
import 'package:inventory_management/shared/constant.dart';

class AddCategory extends StatefulWidget {
  final bool isFromDrawer;
  const AddCategory({super.key, this.isFromDrawer = true});

  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final CategoryDatabase _categoryDatabase = CategoryDatabase(); // Database instance

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {

          // Check if a vendor with the same name exists
    bool exists = await _categoryDatabase.categoryExists(_nameController.text);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category with name "${_nameController.text}" already exists!')),

      );
      return; // Exit the function if vendor exists
    }
      // Create a unique ID based on current timestamp
      final String id = DateTime.now().millisecondsSinceEpoch.toString();

      // Create a Category instance
      final Category category = Category(
        id: id,
        category_name: _nameController.text.trim(),
        description: _descriptionController.text.trim(), 
        createdAt: DateTime.now(),
      );

      try {
        // Add category to the database
        await _categoryDatabase.addCategory(category);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category "${category.category_name}" added successfully!')),
        );

        // Clear the form fields
        _formKey.currentState?.reset();
        _nameController.clear();
        _descriptionController.clear();
        _next();
      } catch (e) {
        // Show error message in case of failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding category: ${e.toString()}')),
        );
      }
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
        title: const Text('Add Category',
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category Name',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: textInputD,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the category name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Description',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: textInput,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Button color
                    foregroundColor: Colors.white, // Text color
                  ),
                  child: const Text('Add Category'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
