class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String userType; // 'customer' or 'shop_owner'
  final String createdAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    required this.userType,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'user_type': userType,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      phone: map['phone'],
      userType: map['user_type'],
      createdAt: map['created_at'],
    );
  }
}
