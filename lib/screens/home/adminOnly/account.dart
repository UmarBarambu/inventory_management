import 'package:flutter/material.dart';
import 'package:inventory_management/services/account_service.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    _initializeAccount();
  }

  Future<void> _initializeAccount() async {
    await _productService.createAccount(0.0); // Create account with initial balance 0.0
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account',
        style:  TextStyle(
                      fontSize: 20,
                       fontWeight: FontWeight.w600,
                    ),
                    ),
      ),
      body: StreamBuilder<double>(
        stream: _productService.accountBalanceStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final totalBalance = snapshot.data ?? 0.0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50), 
                Text(
                  'Total Store Balance: \$${totalBalance.toStringAsFixed(2)}', // Fixed the currency symbol
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Additional UI elements can be added here
              ],
            ),
          );
        },
      ),
    );
  }
}
