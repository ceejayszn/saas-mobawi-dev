class MenuItem {
  final int? id;
  final String name;
  final double price;
  final bool isActive;

  MenuItem({this.id, required this.name, required this.price, this.isActive = true});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      isActive: map['is_active'] == 1,
    );
  }
}
