import 'package:flutter/material.dart';
import 'package:inventory_management/screens/home/charts/stock_level.dart';
import 'package:inventory_management/screens/home/charts/stock_value.dart';
import 'package:inventory_management/screens/home/charts/vendor_chart.dart';

class Stock extends StatefulWidget {
  const Stock({super.key});

  @override
  State<Stock> createState() => _StockState();
}

class _StockState extends State<Stock> {
  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        body: Column(
          children: [
            TabBar(
              labelPadding: EdgeInsets.only(bottom: 0), // Adjust this value as needed
              indicatorPadding: EdgeInsets.only(bottom: 0), // Moves the indicator up (Adjust the value here)
              labelStyle: TextStyle(
                fontSize: 15, // Font size for selected tab
                fontWeight: FontWeight.bold, // Make the text bold
                color: Colors.black, // Set color for selected tab text to black
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 12, // Font size for unselected tabs
                fontWeight: FontWeight.w500,
                color: Colors.black87, // Set color for unselected tab text to black
              ),
              indicatorColor: Colors.lightBlue, // Set the indicator color to light blue
              tabs: [
                Tab(text: 'Stock Levels'),
                Tab(text: 'Stock Value'),
                Tab(text: 'Vendor Chart'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Stocklevel(),
                  Stockvalue(),
                  Vendorchart(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
