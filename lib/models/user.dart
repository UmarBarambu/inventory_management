class User {
  final String uid;   // Unique ID for each user (from Firebase, for example)
  final String email; // User's email address
  final String role;  // User's role (e.g., 'admin', 'manager', 'staff')

  // Constructor for the User class
  User({required this.uid, required this.email, required this.role});
}
