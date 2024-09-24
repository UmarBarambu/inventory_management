import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:inventory_management/models/product.dart';
import 'package:inventory_management/services/items.dart';
import 'package:logger/logger.dart';

class ProductDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  // References to collections in Firestore
  CollectionReference get productsCollection => _firestore.collection('products');
  CollectionReference get categoriesCollection => _firestore.collection('categories');
  CollectionReference get vendorsCollection => _firestore.collection('vendors');

  // Function to format Firestore Timestamp
  String formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(dateTime);
  }

       // Check if a product with the given name exists
Future<bool> productExists(String name) async {
  try {
    // Query the vendors collection for a document with the same name
    QuerySnapshot querySnapshot = await productsCollection
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


  // Add a new product to Firestore
  Future<void> addProduct(Product product) async {
    try {
      await productsCollection.doc(product.id).set({
        ...product.toMap(),
        'createdAt': FieldValue.serverTimestamp(), // Add creation timestamp
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

  // Get a product by its ID
  Future<Product?> getProductById(String id) async {
    try {
      DocumentSnapshot doc = await productsCollection.doc(id).get();
      if (doc.exists) {
        final product = Product.fromMap(doc.data() as Map<String, dynamic>);
        final createdAt = doc.get('createdAt') as Timestamp?;
        final updatedAt = doc.get('updatedAt') as Timestamp?;
        if (createdAt != null) {
          _logger.i('Product created at: ${formatTimestamp(createdAt)}');
        }
        if (updatedAt != null) {
          _logger.i('Product updated at: ${formatTimestamp(updatedAt)}');
        }
        return product;
      } else {
        _logger.w('No product found with ID: $id');
        return null;
      }
    } catch (e) {
      _logger.e('Failed to get product', e);
      rethrow;
    } 
  }

  // Get all products from Firestore
  Future<List<Product>> getAllProducts() async {
    try {
      QuerySnapshot querySnapshot = await productsCollection.get();
      return querySnapshot.docs.map((doc) {
        final product = Product.fromMap(doc.data() as Map<String, dynamic>);
        final createdAt = doc.get('createdAt') as Timestamp?;
        final updatedAt = doc.get('updatedAt') as Timestamp?;
        if (createdAt != null) {
          _logger.i('Product created at: ${formatTimestamp(createdAt)}');
        }
        if (updatedAt != null) {
          _logger.i('Product updated at: ${formatTimestamp(updatedAt)}');
        }
        return product;
      }).toList();
    } catch (e) {
      _logger.e('Failed to get all products', e);
      rethrow;
    }
  }


  // Add a product to a category (many-to-many relationship)
Future<void> addProductToCategory(String productId, String categoryId) async {
  try {
    await productsCollection
        .doc(productId)
        .collection('categories')
        .doc(categoryId)
        .set({'categoryId': categoryId, 'addedAt': FieldValue.serverTimestamp()});
    _logger.i('Product added to category successfully');
  } catch (e) {
    _logger.e('Failed to add product to category', e);
    rethrow;
  }
}



  // Remove a product from a category
  Future<void> removeProductFromCategory(String productId, String categoryId) async {
    try {
      await productsCollection
          .doc(productId)
          .collection('categories')
          .doc(categoryId)
          .delete();

      _logger.i('Product removed from category successfully');
    } catch (e) {
      _logger.e('Failed to remove product from category', e);
      rethrow;
    }
  }

  // Add a product to a vendor (many-to-many relationship)
Future<void> addProductToVendor(String productId, String vendorId) async {
  try {
    await productsCollection
        .doc(productId)
        .collection('vendors')
        .doc(vendorId)
        .set({'vendorId': vendorId, 'addedAt': FieldValue.serverTimestamp()});
    _logger.i('Product added to vendor successfully');
  } catch (e) {
    _logger.e('Failed to add product to vendor', e);
    rethrow;
  }
}


  // Remove a product from a vendor
  Future<void> removeProductFromVendor(String productId, String vendorId) async {
    try {
      await productsCollection
          .doc(productId)
          .collection('vendors')
          .doc(vendorId)
          .delete();

      _logger.i('Product removed from vendor successfully');
    } catch (e) {
      _logger.e('Failed to remove product from vendor', e);
      rethrow;
    }
  }

  // Get all categories for a specific product
  Future<List<Item>> getCategoriesForProduct(String productId) async {
    try {
      QuerySnapshot querySnapshot = await productsCollection
          .doc(productId)
          .collection('categories')
          .get();
      return querySnapshot.docs.map((doc) {
        _logger.i('Document data: ${doc.data()}');
        return Item.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      _logger.e('Failed to get categories for product', e);
      rethrow;
    }
  }

  // Get all vendors for a specific product
  Future<List<Item>> getVendorsForProduct(String productId) async {
    try {
      QuerySnapshot querySnapshot = await productsCollection
          .doc(productId)
          .collection('vendors')
          .get();
      return querySnapshot.docs.map((doc) {
        _logger.i('Document data: ${doc.data()}');
        return Item.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      _logger.e('Failed to get vendors for product', e);
      rethrow;
    }
  }

  // Get all items (either categories or vendors) based on the type
  Future<List<Item>> getItems(String type) async {
    CollectionReference collection;

    if (type == 'Category') {
      collection = categoriesCollection;
    } else if (type == 'Vendor') {
      collection = vendorsCollection;
    } else {
      throw ArgumentError('Invalid type: $type');
    }

    try {
      QuerySnapshot querySnapshot = await collection.get();
      List<Item> items = querySnapshot.docs.map((doc) {
        _logger.i('Document ID: ${doc.id}');
        _logger.i('Document data: ${doc.data()}');
        return Item.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      _logger.i('Fetched $type items: $items');
      return items;
    } catch (e) {
      _logger.e('Failed to get $type', e);
      rethrow;
    }
  }
}
