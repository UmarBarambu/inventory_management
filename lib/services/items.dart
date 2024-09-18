class Item {
  final String id;
  final String name;

  Item({
    required this.id,
    required this.name,
  });

  factory Item.fromMap(Map<String, dynamic> map, String id) {
    return Item(
      id: id,
      name: map['name'] ?? '',
    );
  }
}
