import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'history'; // Firestore collection for history records

// Method to add a history record
Future<void> addHistoryRecord(
    String productName, 
    int amount, 
    String action, 
    DateTime dateTime, 
    Color actionColor) async {
  try {
    String formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss a').format(dateTime);
    await _firestore.collection('history').add({
      'productName': productName,
      'amount': amount,
      'action': action,
      'date': formattedDate, // Store formatted date and time
      'actionColor': actionColor.value, // Store the color as an integer
    });
  } catch (e) {
    debugPrint('Failed to add history record: $e');
  }
}



  // Method to delete a history record by document ID
  Future<void> deleteHistoryRecord(String documentId) async {
    try {
      await _firestore.collection(collectionName).doc(documentId).delete();
    } catch (e) {
      debugPrint('Failed to delete history record: $e');
    }
  }

  // Function to fetch history records
  Future<List<DocumentSnapshot>> fetchHistoryRecords() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection(collectionName).orderBy('date', descending: true).get();
      return querySnapshot.docs;
    } catch (e) {
      print('Error fetching history records: $e');
      return [];
    }
  }
}

