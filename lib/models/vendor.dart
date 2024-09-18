import 'package:intl/intl.dart'; // Import the intl package

class Vendor {
  final String id;
  final String name;
  final String contact;
  final String address;
  final DateTime createdAt; // New field for creation timestamp

  Vendor({
    required this.id,
    required this.name,
    required this.contact,
    required this.address,
    required this.createdAt, // Initialize new field
  });

  // Convert Vendor to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'address': address,
      'createdAt': _formatDate(createdAt), // Format DateTime for Firestore
    };
  }

  // Function to format DateTime without seconds and milliseconds
  String _formatDate(DateTime dateTime) {
    final formatter = DateFormat('yyyy-MM-dd:mm'); // Format: YYYY-MM-DDTHH:MM
    return formatter.format(dateTime);
  }

  // Create Vendor from a Map
  factory Vendor.fromMap(Map<String, dynamic> map) {
    return Vendor(
      id: map['id'],
      name: map['name'],
      contact: map['contact'],
      address: map['address'],
      createdAt: _parseDate(map['created_at']), // Parse the formatted DateTime string
    );
  }

  // Function to parse DateTime from a formatted string
  static DateTime _parseDate(String dateString) {
    return DateFormat('yyyy-MM-dd:mm').parse(dateString);
  }
}
