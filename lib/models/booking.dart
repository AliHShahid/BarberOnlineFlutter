class Booking {
  final int? id;
  final int customerId;
  final int shopId;
  final int serviceId;
  final String bookingDate;
  final String bookingTime;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final double totalPrice;
  final String? notes;
  final String createdAt;

  Booking({
    this.id,
    required this.customerId,
    required this.shopId,
    required this.serviceId,
    required this.bookingDate,
    required this.bookingTime,
    required this.status,
    required this.totalPrice,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'shop_id': shopId,
      'service_id': serviceId,
      'booking_date': bookingDate,
      'booking_time': bookingTime,
      'status': status,
      'total_price': totalPrice,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      customerId: map['customer_id'],
      shopId: map['shop_id'],
      serviceId: map['service_id'],
      bookingDate: map['booking_date'],
      bookingTime: map['booking_time'],
      status: map['status'],
      totalPrice: map['total_price'].toDouble(),
      notes: map['notes'],
      createdAt: map['created_at'],
    );
  }
}
