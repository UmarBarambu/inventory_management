import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/services/historyDatabase.dart';


class EditStockNo extends StatefulWidget {
  final DocumentSnapshot product;

  const EditStockNo({
    Key? key,
    required this.product, required Future<void> Function(String productName, int amount, String action, DateTime date) updateHistory,
  }) : super(key: key);

  @override
  State<EditStockNo> createState() => _EditStockNoState();
}

class _EditStockNoState extends State<EditStockNo> {
  late int currentStock;
  final TextEditingController _stockController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final HistoryService _historyService = HistoryService(); // Initialize HistoryService

  @override
  void initState() {
    super.initState();
    currentStock = widget.product['stock']?.toInt() ?? 0; // Get the current stock from the product
  }

  // Function to update the stock in Firestore
  Future<void> _updateStock(int newStock) async {
    try {
      await _firestore.collection('products').doc(widget.product.id).update({
        'stock': newStock,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock updated successfully')),
      );
    } catch (e) {
      debugPrint('Error updating stock: $e');
    }
  }

// Function to handle adding stock
void _addStock() async {
  int valueToAdd = int.tryParse(_stockController.text) ?? 0;
  if (valueToAdd > 0) {
    setState(() {
      currentStock += valueToAdd;
    });
    _stockController.clear();
    
    // Update stock in Firestore
    await _updateStock(currentStock);

    // Add to history database with formatted date and time
    DateTime now = DateTime.now();
    await _historyService.addHistoryRecord(
      widget.product['name'], 
      valueToAdd, 
      'Added', 
      now, // Pass the DateTime directly
      Colors.green // Pass the green color for addition
    );

    // Navigate back to the home page
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a valid amount to add')),
    );
  }
}


// Function to handle deducting stock
void _deductStock() async {
  int valueToDeduct = int.tryParse(_stockController.text) ?? 0;
  if (valueToDeduct > 0 && currentStock >= valueToDeduct) {
    setState(() {
      currentStock -= valueToDeduct;
    });
    _stockController.clear();
    
    // Update stock in Firestore
    await _updateStock(currentStock);

    // Add to history database with current date and time
    await _historyService.addHistoryRecord(
      widget.product['name'], 
      valueToDeduct, 
      'Deducted', 
      DateTime.now(), // Pass the current DateTime directly
      Colors.red // Pass the red color for deduction
    );

    // Navigate back to the home page
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Not enough stock to deduct or invalid amount')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Stock'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Current Stock: $currentStock',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter stock amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _addStock,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Add Stock'),
                ),
                ElevatedButton(
                  onPressed: _deductStock,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Deduct Stock'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
