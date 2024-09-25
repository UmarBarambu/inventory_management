import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Vendordetails extends StatefulWidget {
  const Vendordetails({super.key});

  @override
  State<Vendordetails> createState() => _VendordetailsState();
}

class _VendordetailsState extends State<Vendordetails> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Details'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('vendors').snapshots(), // Change to your vendor collection
        builder: (context, vendorSnapshot) {
          if (vendorSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vendorSnapshot.hasError) {
            return const Center(child: Text('Failed to load vendors.'));
          }
          if (!vendorSnapshot.hasData || vendorSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No vendors found.'));
          }

          return ListView.builder(
            itemCount: vendorSnapshot.data!.docs.length,
            itemBuilder: (context, vendorIndex) {
              var vendor = vendorSnapshot.data!.docs[vendorIndex];
              String vendorName = vendor['name'] ?? 'Unnamed Vendor';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.grey[100],
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                    child: Text(
                      vendorName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('products')
                        .where('vendor_name', isEqualTo: vendorName) // Fetch products by vendor name
                        .snapshots(),
                    builder: (context, productSnapshot) {
                      if (productSnapshot.hasError) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Failed to load products.'),
                        );
                      }
                      if (!productSnapshot.hasData || productSnapshot.data!.docs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('No products found for this vendor.'),
                        );
                      }

                      return Column(
                        children: productSnapshot.data!.docs.asMap().entries.map((entry) {
                          int idx = entry.key;
                          var product = entry.value;
                          String productName = product['name'] ?? 'Unnamed Product';
                          int stock = product['stock']?.toInt() ?? 0;

                          return Column(
                            children: [
                              Card(
                                margin: const EdgeInsets.only(top: 0, bottom: 0),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                                color: Colors.white,
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        child: Text(
                                          '$stock',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          productName,
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (idx < productSnapshot.data!.docs.length - 1)
                                const Divider(height: 1, thickness: 1, color: Colors.grey),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
