import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to update the total balance based on product values
  Future<void> updateTotalBalance() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('products').get();
      double totalBalance = 0;

      for (var doc in snapshot.docs) {
        // Calculate totalProductValue based on buyingPrice and stock
        double buyingPrice = doc['buyingPrice'] ?? 0;
        int stock = doc['stock'] ?? 0;
        double totalProductValue = buyingPrice * stock;
        totalBalance += totalProductValue;
      }

      // Update the totalBalance in the accounts collection
      final accountDocRef = _firestore.collection('accounts').doc('store_balance');
      await accountDocRef.set({'totalBalance': totalBalance}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to update total balance: $e');
    }
  }

  Future<void> createAccount(double initialBalance) async {
    final accountDocRef = _firestore.collection('accounts').doc('store_balance');

    DocumentSnapshot accountSnapshot = await accountDocRef.get();
    if (!accountSnapshot.exists) {
      await accountDocRef.set({
        'totalBalance': initialBalance,
      });
    }
  }

  Future<double> getAccountBalance() async {
    final accountDocRef = _firestore.collection('accounts').doc('store_balance');

    DocumentSnapshot accountSnapshot = await accountDocRef.get();
    if (accountSnapshot.exists) {
      return accountSnapshot['totalBalance']?.toDouble() ?? 0.0;
    } else {
      return 0.0; // Return 0 if the account doesn't exist
    }
  }

  // Method to call when a product is added, updated, or deleted
  Future<void> onProductChange() async {
    await updateTotalBalance(); // Recalculate the total balance
  }

  // Stream to listen to account balance changes
  Stream<double> accountBalanceStream() {
    final accountDocRef = _firestore.collection('accounts').doc('store_balance');
    return accountDocRef.snapshots().map((snapshot) {
      return snapshot.exists ? snapshot['totalBalance']?.toDouble() ?? 0.0 : 0.0;
    });
  }
}
