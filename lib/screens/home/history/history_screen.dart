import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventory_management/services/history_database.dart';

class History extends StatefulWidget {
  const History({super.key, required List history});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final HistoryService _historyService = HistoryService();
  List<DocumentSnapshot> _historyList = [];
  String? _errorMessage; // Variable to hold error messages

  @override
  void initState() {
    super.initState();
    _fetchHistoryRecords();
  }

  Future<void> _fetchHistoryRecords() async {
    try {
      final records = await _historyService.fetchHistoryRecords();
      setState(() {
        _historyList = records;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching history records: $e'; // Set error message
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _errorMessage != null // Display error message if available
          ? Center(child: Text(_errorMessage!))
          : ListView.builder(
              itemCount: _historyList.length,
              itemBuilder: (context, index) {
                final item = _historyList[index].data() as Map<String, dynamic>;
                DateTime dateTime;

                if (item['date'] is Timestamp) {
                  dateTime = (item['date'] as Timestamp).toDate();
                } else if (item['date'] is String) {
                  String dateString = item['date'];
                  dateTime = DateFormat('yyyy-MM-dd hh:mm:ss a').parse(dateString);
                } else {
                  dateTime = DateTime.now();
                }

                String formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss a').format(dateTime);
                Color textColor = item['actionColor'] != null
                    ? Color(item['actionColor'])
                    : Colors.black; // Default text color if actionColor is null

                return Column(
                  children: [
                    const Divider(height: 1, thickness: 1),
                    Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(top: 0, bottom: 0),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      child: ListTile(
                        title: Text(
                          item['productName'],
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          '${item['amount']} ${item['action']} on $formattedDate',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textColor, // Set text color here
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1, thickness: 1),
                  ],
                );
              },
            ),
    );
  }
}
