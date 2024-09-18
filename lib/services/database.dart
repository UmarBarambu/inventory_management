import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  // Reference to the 'users' collection
  CollectionReference get usersCollection => _firestore.collection('users');

  // Add or update user data in Firestore
  Future<void> updateUserData({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String role,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await usersCollection.doc(user.uid).set({
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
          'email': email,
          'role': role,
        }, SetOptions(merge: true));
      } else {
        _logger.w('No user is currently signed in.');
      }
    } catch (e) {
      _logger.e('Error updating user data', e);
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot snapshot = await usersCollection.doc(user.uid).get();
        return snapshot.data() as Map<String, dynamic>?;
      } else {
        _logger.w('No user is currently signed in.');
        return null;
      }
    } catch (e) {
      _logger.e('Error getting user data', e);
      return null;
    }
  }

  // Update specific fields for a user
  Future<void> updateUserField(String field, dynamic value) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await usersCollection.doc(user.uid).update({field: value});
      } else {
        _logger.w('No user is currently signed in.');
      }
    } catch (e) {
      _logger.e('Error updating user field', e);
    }
  }

  // General method to delete a user from Firestore by user ID
  Future<void> deleteUserById(String userId) async {
    try {
      await usersCollection.doc(userId).delete();
      _logger.i('User deleted successfully');
    } catch (e) {
      _logger.e('Error deleting user: $e');
    }
  }
}
