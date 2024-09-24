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
              labelStyle: TextStyle(fontSize: 12), // Reduce font size for selected tab
              unselectedLabelStyle: TextStyle(fontSize: 15), // Reduce font size for unselected tabs
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
