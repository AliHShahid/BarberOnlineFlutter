import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/database_helper.dart';
import '../../models/shop.dart';
import '../../models/booking.dart';
import '../../models/user.dart';
import '../../models/service.dart';

class ViewBookingsScreen extends StatefulWidget {
  const ViewBookingsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ViewBookingsScreenState createState() => _ViewBookingsScreenState();
}

// class ViewBookingsScreen extends StatefulWidget {
//   @override
//   _ViewBookingsScreenState createState() => _ViewBookingsScreenState();
// }

class _ViewBookingsScreenState extends State<ViewBookingsScreen> {
  List<BookingDetails> _bookings = [];
  Shop? _shop;
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId != null) {
      DatabaseHelper dbHelper = DatabaseHelper();
      _shop = await dbHelper.getShopByOwnerId(userId);

      if (_shop != null) {
        List<Booking> bookings = await dbHelper.getBookingsByShopId(_shop!.id!);

        // Get additional details for each booking
        List<BookingDetails> bookingDetails = [];
        for (Booking booking in bookings) {
          User? customer = await dbHelper.getUserById(booking.customerId);
          Service? service = await dbHelper
              .getServicesByShopId(_shop!.id!)
              .then(
                (services) =>
                    services.firstWhere((s) => s.id == booking.serviceId),
              );

          bookingDetails.add(
            BookingDetails(
              booking: booking,
              customer: customer,
              service: service,
            ),
          );
        }

        _bookings = bookingDetails;
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  List<BookingDetails> get _filteredBookings {
    if (_selectedFilter == 'all') {
      return _bookings;
    }
    return _bookings.where((b) => b.booking.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bookings'), backgroundColor: Colors.blue),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Filter Tabs
                  Container(
                    padding: EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('all', 'All'),
                          SizedBox(width: 8),
                          _buildFilterChip('pending', 'Pending'),
                          SizedBox(width: 8),
                          _buildFilterChip('confirmed', 'Confirmed'),
                          SizedBox(width: 8),
                          _buildFilterChip('completed', 'Completed'),
                          SizedBox(width: 8),
                          _buildFilterChip('cancelled', 'Cancelled'),
                        ],
                      ),
                    ),
                  ),

                  // Bookings List
                  Expanded(
                    child:
                        _filteredBookings.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.book_online_outlined,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text('No bookings found'),
                                ],
                              ),
                            )
                            : RefreshIndicator(
                              onRefresh: _loadData,
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _filteredBookings.length,
                                itemBuilder: (context, index) {
                                  BookingDetails bookingDetails =
                                      _filteredBookings[index];
                                  return _buildBookingCard(bookingDetails);
                                },
                              ),
                            ),
                  ),
                ],
              ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    bool isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.blue,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }

  Widget _buildBookingCard(BookingDetails bookingDetails) {
    Booking booking = bookingDetails.booking;
    User? customer = bookingDetails.customer;
    Service? service = bookingDetails.service;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking #${booking.id}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                _buildStatusChip(booking.status),
              ],
            ),
            SizedBox(height: 12),

            // Customer Info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer?.name ?? 'Unknown Customer',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (customer?.email != null) Text(customer!.email),
                      if (customer?.phone != null) Text(customer!.phone!),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),
            Divider(),
            SizedBox(height: 12),

            // Service & Booking Details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(service?.name ?? 'Unknown Service'),
                      if (service?.duration != null)
                        Text('${service!.duration} minutes'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date & Time',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(booking.bookingDate),
                      Text(booking.bookingTime),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Price',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '\$${booking.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Notes
            if (booking.notes != null) ...[
              SizedBox(height: 12),
              Text(
                'Notes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              Text(booking.notes!),
            ],

            // Action Buttons
            if (booking.status == 'pending') ...[
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          () => _updateBookingStatus(booking.id!, 'confirmed'),
                      // child: Text('Confirm'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Confirm'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      // child: ElevatedButton(
                      onPressed:
                          () => _updateBookingStatus(booking.id!, 'cancelled'),
                      // child: Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ] else if (booking.status == 'confirmed') ...[
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      () => _updateBookingStatus(booking.id!, 'completed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Mark as Completed'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'confirmed':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(status.toUpperCase()),
      backgroundColor: color,
      labelStyle: TextStyle(color: Colors.white, fontSize: 12),
    );
  }

  _updateBookingStatus(int bookingId, String status) async {
    try {
      DatabaseHelper dbHelper = DatabaseHelper();
      await dbHelper.updateBookingStatus(bookingId, status);
      _loadData();

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking status updated to $status'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class BookingDetails {
  final Booking booking;
  final User? customer;
  final Service? service;

  BookingDetails({required this.booking, this.customer, this.service});
}
