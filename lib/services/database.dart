import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
    User? user = _auth.currentUser;
    if (user != null) {
      await usersCollection.doc(user.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'email': email,
        'role': role,
      }, SetOptions(merge: true));
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot = await usersCollection.doc(user.uid).get();
      return snapshot.data() as Map<String, dynamic>?;
    }
    return null;
  }

  // Update specific fields for a user
  Future<void> updateUserField(String field, dynamic value) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await usersCollection.doc(user.uid).update({field: value});
    }
  }

  // Delete user data
  Future<void> deleteUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await usersCollection.doc(user.uid).delete();
    }
  }
}
