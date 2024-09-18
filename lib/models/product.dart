import 'package:intl/intl.dart'; // Import the intl package

class Product {
  final String id;
  final String name;
  final double buyingPrice;
  final double sellingPrice;
  final String category_name;
  final String vendorId;
  final int stock;
  final DateTime createdAt; // Field for creation timestamp

  // Constructor
  Product({
    required this.id,
    required this.name,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.category_name,
    required this.vendorId,
    required this.stock,
    required this.createdAt, // Initialize the field
  });

  // Convert Product to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'buyingPrice': buyingPrice,
      'sellingPrice': sellingPrice,
      'category_name': category_name,
      'vendorId': vendorId,
      'stock': stock,
      'createdAt': _formatDate(createdAt), // Use custom formatting for DateTime
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
      vendorId: map['vendorId'],
      stock: map['stock'],
      createdAt: DateTime.parse(map['createdAt']), // Parse the formatted DateTime string
    );
  }
}
