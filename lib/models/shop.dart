class Shop {
  final int? id;
  final int ownerId;
  final String name;
  final String address;
  final String? phone;
  final String? description;
  final String? openingTime;
  final String? closingTime;
  final String createdAt;

  Shop({
    this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    this.phone,
    this.description,
    this.openingTime,
    this.closingTime,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'address': address,
      'phone': phone,
      'description': description,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'created_at': createdAt,
    };
  }

  factory Shop.fromMap(Map<String, dynamic> map) {
    return Shop(
      id: map['id'],
      ownerId: map['owner_id'],
      name: map['name'],
      address: map['address'],
      phone: map['phone'],
      description: map['description'],
      openingTime: map['opening_time'],
      closingTime: map['closing_time'],
      createdAt: map['created_at'],
    );
  }
}
