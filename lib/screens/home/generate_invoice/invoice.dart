// lib/screens/invoice/invoice_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/screens/home/generate_invoice/secondpage.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({Key? key}) : super(key: key);

  @override
  _InvoiceScreenState createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController(); // Can be email or WhatsApp number

  @override
  void dispose() {
    _customerNameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _navigateToSecondPage() async {
    String customerName = _customerNameController.text.trim();
    String contact = _contactController.text.trim();

    if (customerName.isEmpty || contact.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }

    // Navigate to SecondPage and wait for selected products
    final selectedProducts = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SecondPage(
          customerName: customerName,
          contact: contact,
        ),
      ),
    );

    if (selectedProducts != null && selectedProducts is List<Map<String, dynamic>>) {
      // Calculate total amount using double
      double totalAmount = selectedProducts.fold(
        0.0,
        (sum, item) => sum + ((item['sellingPrice'] ?? 0.0) * (item['quantity'] ?? 1)),
      );

      // Save the invoice to Firestore
      try {
        DocumentReference invoiceRef = await FirebaseFirestore.instance.collection('invoices').add({
          'customerName': customerName,
          'contact': contact,
          'products': selectedProducts,
          'date': DateTime.now(),
          'totalAmount': totalAmount,
        });

        // Prepare the invoice message
        String productList = selectedProducts.map((item) {
          return '${item['name']} - Quantity: ${item['quantity']} - Price: N${item['sellingPrice']}';
        }).join('\n');

        String message = '''
Invoice ID: ${invoiceRef.id}
Date: ${DateTime.now()}

Customer Name: $customerName
Contact: $contact

Products:
$productList

Total Amount: N$totalAmount
''';

        // Clear the input fields
        _customerNameController.clear();
        _contactController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice created successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create invoice: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Invoice'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Customer Name TextField
            TextField(
              controller: _customerNameController,
              decoration: const InputDecoration(
                labelText: 'Customer Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Contact TextField
            TextField(
              controller: _contactController,
              decoration: const InputDecoration(
                labelText: 'Email or WhatsApp Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress, // Customize as needed
            ),
            const SizedBox(height: 20),
            // Start Order Button
            ElevatedButton(
              onPressed: _navigateToSecondPage,
              child: const Text('Start Order'),
            ),
          ],
        ),
      ),
    );
  }
}
