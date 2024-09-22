import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventory_management/models/category.dart'; // Ensure you import the Category class
import 'package:inventory_management/models/product.dart';
import 'package:logger/logger.dart';

class CategoryDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  // Reference to the 'categories' collection
  CollectionReference get categoriesCollection => _firestore.collection('categories');
  
  // Reference to the 'products' collection
  CollectionReference get productsCollection => _firestore.collection('products');

      // Check if a vendor with the given name exists
Future<bool> categoryExists(String name) async {
  try {
    // Query the vendors collection for a document with the same name
    QuerySnapshot querySnapshot = await categoriesCollection
        .where('name', isEqualTo: name)
        .get();
    // Return true if a vendor with the same name exists
    return querySnapshot.docs.isNotEmpty;
  } catch (e) {
    // Log the error and rethrow
    _logger.e('Failed to check if vendor exists', e);
    rethrow;
  }
}


  // Add a new category to Firestore
  Future<void> addCategory(Category category) async {
    try {
      await categoriesCollection.doc(category.id).set({
        ...category.toMap(),
        'createdAt': FieldValue.serverTimestamp(), // Add creation timestamp
      });
      _logger.i('Category added successfully');
    } catch (e) {
      _logger.e('Failed to add category', e);
      rethrow;
    }
  }

  // Update an existing category in Firestore
  Future<void> updateCategory(Category category) async {
    try {
      await categoriesCollection.doc(category.id).update({
        ...category.toMap(),
        'updatedAt': FieldValue.serverTimestamp(), // Update timestamp
      });
      _logger.i('Category updated successfully');
    } catch (e) {
      _logger.e('Failed to update category', e);
      rethrow;
    }
  }

  // Get a category by its ID
  Future<Category?> getCategoryById(String id) async {
    try {
      DocumentSnapshot doc = await categoriesCollection.doc(id).get();
      if (doc.exists) {
        return Category.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        _logger.w('No category found with ID: $id');
        return null;
      }
    } catch (e) {
      _logger.e('Failed to get category', e);
      rethrow;
    }
  }

  // Get all categories from Firestore
  Future<List<Category>> getAllCategories() async {
    try {
      QuerySnapshot querySnapshot = await categoriesCollection.get();
      return querySnapshot.docs.map((doc) => Category.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      _logger.e('Failed to get all categories', e);
      rethrow;
    }
  }

  // Delete a category by its ID
  Future<void> deleteCategory(String id) async {
    try {
      await categoriesCollection.doc(id).delete();
      _logger.i('Category deleted successfully');
    } catch (e) {
      _logger.e('Failed to delete category', e);
      rethrow;
    }
  }

   

  // Add a new product to Firestore
  Future<void> addProduct(Product product) async {
    try {
      await productsCollection.doc(product.id).set({
        ...product.toMap(),
        'createdAt': FieldValue.serverTimestamp(), // Add creation timestamp
        'updatedAt': FieldValue.serverTimestamp(), // Add updated timestamp
      });
      _logger.i('Product added successfully');
    } catch (e) {
      _logger.e('Failed to add product', e);
      rethrow;
    }
  }

  // Update an existing product in Firestore
  Future<void> updateProduct(Product product) async {
    try {
      await productsCollection.doc(product.id).update({
        ...product.toMap(),
        'updatedAt': FieldValue.serverTimestamp(), // Update timestamp
      });
      _logger.i('Product updated successfully');
    } catch (e) {
      _logger.e('Failed to update product', e);
      rethrow;
    }
  }
}
