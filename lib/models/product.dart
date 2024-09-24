import 'package:intl/intl.dart'; // Import the intl package

class Product {
  final String id;
  final String name;
  final double buyingPrice;
  final double sellingPrice;
  final String category_name;
  final String vendor_name;
  final int stock;
  final DateTime createdAt; // Field for creation timestamp

  // Constructor
  Product({
    required this.id,
    required this.name,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.category_name,
    required this.vendor_name,
    required this.stock,
    required this.createdAt, // Initialize the field
  });

  // Getter for total product value
  double get totalProductValue {
    return buyingPrice * stock;
  }

  // Convert Product to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'buyingPrice': buyingPrice,
      'sellingPrice': sellingPrice,
      'category_name': category_name,
      'vendor_name': vendor_name,
      'stock': stock,
      'createdAt': _formatDate(createdAt), // Use custom formatting for DateTime
      'totalProductValue': totalProductValue, // Include total product value in the map
    };
  }

  // Function to format DateTime without seconds and milliseconds
  String _formatDate(DateTime dateTime) {
    final formatter = DateFormat('yyyy-MM-dd:mm:ss'); // Format: YYYY-MM-DD:MM
    return formatter.format(dateTime);
  }

  // Create Product from a Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      buyingPrice: map['buyingPrice'],
      sellingPrice: map['sellingPrice'],
      category_name: map['category_name'],
      vendor_name: map['vendor_name'],
      stock: map['stock'],
      createdAt: DateTime.parse(map['createdAt']), // Parse the formatted DateTime string
    );
  }
}
