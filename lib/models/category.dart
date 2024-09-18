import 'package:intl/intl.dart'; // Import the intl package

class Category {
  final String id;
  final String category_name;
  final String description;
  final DateTime createdAt; // Field for creation timestamp

  Category({
    required this.id,
    required this.category_name,
    required this.description,
    required this.createdAt, // Initialize new field
  });

  // Convert Category to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': category_name,
      'description': description,
      'createdAt': _formatDate(createdAt), // Use custom formatting for DateTime
    };
  }

  // Function to format DateTime without seconds and milliseconds
  String _formatDate(DateTime dateTime) {
    final formatter = DateFormat('yyyy-MM-ddTHH:mm'); // Format: YYYY-MM-DDTHH:MM
    return formatter.format(dateTime);
  }

  // Create Category from a Map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      category_name: map['name'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']), // Parse the formatted DateTime string
    );
  }
}
