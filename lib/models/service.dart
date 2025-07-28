class Service {
  final int? id;
  final int shopId;
  final String name;
  final String? description;
  final double price;
  final int duration; // in minutes
  final String createdAt;

  Service({
    this.id,
    required this.shopId,
    required this.name,
    this.description,
    required this.price,
    required this.duration,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shop_id': shopId,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'created_at': createdAt,
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'],
      shopId: map['shop_id'],
      name: map['name'],
      description: map['description'],
      price: map['price'].toDouble(),
      duration: map['duration'],
      createdAt: map['created_at'],
    );
  }
}
