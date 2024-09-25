import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/screens/home/details/vendorDetails.dart';

class Vendorchart extends StatefulWidget {
  const Vendorchart({super.key});

  @override
  State<Vendorchart> createState() => _VendorchartState();
}

class _VendorchartState extends State<Vendorchart> {
  // Fetch vendor and stock details from Firestore
  Future<List<Map<String, dynamic>>> _fetchVendorStockData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('products').get();
    List<Map<String, dynamic>> products = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    // Group products by vendor and sum their stock
    Map<String, int> vendorStock = {};
    for (var product in products) {
      String vendorName = product['vendor_name'];
      int stock = product['stock'];

      if (vendorStock.containsKey(vendorName)) {
        vendorStock[vendorName] = vendorStock[vendorName]! + stock;
      } else {
        vendorStock[vendorName] = stock;
      }
    }

    // Convert vendorStock map to a list of maps for chart usage
    return vendorStock.entries
        .map((entry) => {'vendor_name': entry.key, 'total_stock': entry.value})
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         title: const Text(
            'Vendor Stock Levels',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
           ),
           actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward), // Use the forward arrow icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Vendordetails()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchVendorStockData(), // Fetch vendor stock data from Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
            ));
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No vendor stock data found'));
          }

          List<Map<String, dynamic>> vendorStockData = snapshot.data!;
          List<String> vendorNames = vendorStockData.map((data) => data['vendor_name'] as String).toList();
          List<int> vendorStocks = vendorStockData.map((data) => data['total_stock'] as int).toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      height: 600,
                      width: vendorNames.length * 70.0, // Adjust width dynamically based on vendor count
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: vendorStocks.isNotEmpty
                              ? vendorStocks.reduce((a, b) => a > b ? a : b).toDouble() * 1.1
                              : 11000, // Add 10% space above the max stock value
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 100,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  const style = TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  );
                                  int index = value.toInt();
                                  if (index < vendorNames.length) {
                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      child: Transform.translate(
                                        offset: const Offset(-30, 30),
                                        child: Transform.rotate(
                                          angle: -45 * 3.14159 / 180,
                                          child: Text(vendorNames[index], style: style),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return const Text('');
                                  }
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            drawHorizontalLine: true,
                            getDrawingHorizontalLine: (value) {
                              return const FlLine(
                                color: Color(0xFFBEBEBE),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: vendorStocks
                              .asMap()
                              .entries
                              .map((entry) => BarChartGroupData(
                                    x: entry.key,
                                    barRods: [
                                      BarChartRodData(
                                        toY: entry.value.toDouble(),
                                        color: Colors.blue,
                                        width: 30,
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ],
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
