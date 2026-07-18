class Product {
  final String? id;
  final String name;
  final double price;
  final bool isActive;

  Product({this.id, required this.name, required this.price, this.isActive = true});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toString(),
      name: map['name'],
      price: map['price'],
      isActive: map['is_active'] == 1,
    );
  }
}
