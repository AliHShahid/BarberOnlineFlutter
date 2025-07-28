import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/database_helper.dart';
import '../../models/shop.dart';
import '../../models/user.dart';
import '../../models/booking.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  _CustomerHomeScreenState createState() => _CustomerHomeScreenState();
}

// class CustomerHomeScreen extends StatefulWidget {
//   @override
//   _CustomerHomeScreenState createState() => _CustomerHomeScreenState();
// }

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  List<Shop> _shops = [];
  List<Booking> _myBookings = [];
  User? _currentUser;
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId != null) {
      DatabaseHelper dbHelper = DatabaseHelper();
      _currentUser = await dbHelper.getUserById(userId);
      _shops = await dbHelper.getAllShops();
      _myBookings = await dbHelper.getBookingsByCustomerId(userId);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barber Shops'),
        backgroundColor: Colors.blue,
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: _logout)],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildShopsTab(),
                  _buildBookingsTab(),
                  _buildProfileTab(),
                ],
              ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shops'),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'My Bookings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildShopsTab() {
    return RefreshIndicator(
      onRefresh: () async => await _loadData(),
      // onRefresh: _loadData,
      child:
          _shops.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.store_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No barber shops available'),
                  ],
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _shops.length,
                itemBuilder: (context, index) {
                  Shop shop = _shops[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.content_cut, color: Colors.white),
                      ),
                      title: Text(
                        shop.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(shop.address),
                          if (shop.phone != null) Text('Phone: ${shop.phone}'),
                          if (shop.description != null) Text(shop.description!),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/shop-details',
                          arguments: shop,
                        ).then((_) => _loadData());
                      },
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildBookingsTab() {
    return RefreshIndicator(
      onRefresh: () async => await _loadData(),
      // onRefresh: _loadData,
      child:
          _myBookings.isEmpty
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
                    Text('No bookings yet'),
                  ],
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _myBookings.length,
                itemBuilder: (context, index) {
                  Booking booking = _myBookings[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(booking.status),
                        child: Icon(Icons.schedule, color: Colors.white),
                      ),
                      title: Text('Booking #${booking.id}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date: ${booking.bookingDate}'),
                          Text('Time: ${booking.bookingTime}'),
                          Text(
                            'Price: \$${booking.totalPrice.toStringAsFixed(2)}',
                          ),
                          Text('Status: ${booking.status.toUpperCase()}'),
                        ],
                      ),
                      trailing: _buildStatusChip(booking.status),
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildProfileTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    _currentUser?.name ?? 'User',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(_currentUser?.email ?? ''),
                  if (_currentUser?.phone != null) Text(_currentUser!.phone!),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout'),
              onTap: _logout,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusChip(String status) {
    return Chip(
      label: Text(status.toUpperCase()),
      backgroundColor: _getStatusColor(status),
      labelStyle: TextStyle(color: Colors.white, fontSize: 12),
    );
  }

  _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }
}
