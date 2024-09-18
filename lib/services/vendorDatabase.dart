import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventory_management/models/product.dart'; // Ensure you import the Product class
import 'package:inventory_management/models/vendor.dart'; // Ensure you import the Vendor class
import 'package:logger/logger.dart';

class VendorDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  // Reference to the 'vendors' collection
  CollectionReference get vendorsCollection => _firestore.collection('vendors');

  // Reference to the 'products' collection
  CollectionReference get productsCollection => _firestore.collection('products');

  // Add a new vendor to Firestore
  Future<void> addVendor(Vendor vendor) async {
    try {
      await vendorsCollection.doc(vendor.id).set({
        ...vendor.toMap(),
        'createdAt': FieldValue.serverTimestamp(), // Add creation timestamp
        
      });
      _logger.i('Vendor added successfully');
    } catch (e) {
      _logger.e('Failed to add vendor', e);
      rethrow;
    }
  }

  // Update an existing vendor in Firestore
  Future<void> updateVendor(Vendor vendor) async {
    try {
      await vendorsCollection.doc(vendor.id).update({
        ...vendor.toMap(),
        'updatedAt': FieldValue.serverTimestamp(), // Update timestamp
      });
      _logger.i('Vendor updated successfully');
    } catch (e) {
      _logger.e('Failed to update vendor', e);
      rethrow;
    }
  }

  // Get a vendor by its ID
  Future<Vendor?> getVendorById(String id) async {
    try {
      DocumentSnapshot doc = await vendorsCollection.doc(id).get();
      if (doc.exists) {
        return Vendor.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        _logger.w('No vendor found with ID: $id');
        return null;
      }
    } catch (e) {
      _logger.e('Failed to get vendor', e);
      rethrow;
    }
  }

  // Get all vendors from Firestore
  Future<List<Vendor>> getAllVendors() async {
    try {
      QuerySnapshot querySnapshot = await vendorsCollection.get();
      return querySnapshot.docs.map((doc) => Vendor.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      _logger.e('Failed to get all vendors', e);
      rethrow;
    }
  }

  // Delete a vendor by its ID
  Future<void> deleteVendor(String id) async {
    try {
      await vendorsCollection.doc(id).delete();
      _logger.i('Vendor deleted successfully');
    } catch (e) {
      _logger.e('Failed to delete vendor', e);
      rethrow;
    }
  }

  // Add a new product to a specific vendor's products collection
  Future<void> addProductToVendor(String vendorId, Product product) async {
    try {
      await productsCollection.doc(product.id).set({
        ...product.toMap(),
        'vendorId': vendorId,
        'createdAt': FieldValue.serverTimestamp(), // Add creation timestamp
        
      });
      _logger.i('Product added to vendor successfully');
    } catch (e) {
      _logger.e('Failed to add product to vendor', e);
      rethrow;
    }
  }

  // Update an existing product in a specific vendor's products collection
  Future<void> updateProductInVendor(String vendorId, Product product) async {
    try {
      await productsCollection.doc(product.id).update({
        ...product.toMap(),
        'vendorId': vendorId,
        'updatedAt': FieldValue.serverTimestamp(), // Update timestamp
      });
      _logger.i('Product updated in vendor successfully');
    } catch (e) {
      _logger.e('Failed to update product in vendor', e);
      rethrow;
    }
  }

  // Get all products for a specific vendor
  Future<List<Product>> getProductsForVendor(String vendorId) async {
    try {
      QuerySnapshot querySnapshot = await productsCollection.where('vendorId', isEqualTo: vendorId).get();
      return querySnapshot.docs.map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      _logger.e('Failed to get products for vendor', e);
      rethrow;
    }
  }
}
