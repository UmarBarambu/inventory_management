import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Stocklevel extends StatefulWidget {
  const Stocklevel({super.key});

  @override
  State<Stocklevel> createState() => _StocklevelState();
}

class _StocklevelState extends State<Stocklevel> {
  // Fetch product details from Firestore
  Future<List<Map<String, dynamic>>> _fetchProductData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('products').get();
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         title: const Text(
            'Available Stock',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
           ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchProductData(), // Fetch product data from Firestore
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
            return const Center(child: Text('No products found'));
          }

          List<Map<String, dynamic>> productData = snapshot.data!;
          List<String> productNames = productData.map((data) => data['name'] as String).toList();
          List<int> stockLevels = productData.map((data) => data['stock'] as int).toList();

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
                      width: productNames.length * 70.0, // Adjust width dynamically based on product count
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: stockLevels.isNotEmpty
                              ? stockLevels.reduce((a, b) => a > b ? a : b).toDouble() * 1.1
                              : 11000, // Add 10% space above the max value
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
                                  if (index < productNames.length) {
                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      child: Transform.translate(
                                        offset: const Offset(-30, 30), // Increased offset to move text down
                                        child: Transform.rotate(
                                          angle: -45 * 3.14159 / 180,
                                          child: Text(productNames[index], style: style),
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
                                color: Color.fromARGB(255, 199, 187, 187),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: stockLevels
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
