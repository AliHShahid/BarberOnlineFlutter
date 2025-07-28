import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/database_helper.dart';
import '../../models/shop.dart';
import '../../models/user.dart';
import '../../models/service.dart';
import '../../models/booking.dart';

class ShopHomeScreen extends StatefulWidget {
  @override
  _ShopHomeScreenState createState() => _ShopHomeScreenState();
}

class _ShopHomeScreenState extends State<ShopHomeScreen> {
  Shop? _shop;
  User? _currentUser;
  List<Service> _services = [];
  List<Booking> _bookings = [];
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
      _shop = await dbHelper.getShopByOwnerId(userId);

      if (_shop != null) {
        _services = await dbHelper.getServicesByShopId(_shop!.id!);
        _bookings = await dbHelper.getBookingsByShopId(_shop!.id!);
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_shop?.name ?? 'My Shop'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _selectedIndex,
              children: [
                _buildDashboardTab(),
                _buildServicesTab(),
                _buildBookingsTab(),
                _buildProfileTab(),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.room_service),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    int pendingBookings = _bookings.where((b) => b.status == 'pending').length;
    int confirmedBookings =
        _bookings.where((b) => b.status == 'confirmed').length;
    double totalRevenue = _bookings
        .where((b) => b.status == 'completed')
        .fold(0.0, (sum, booking) => sum + booking.totalPrice);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pending Bookings',
                  pendingBookings.toString(),
                  Icons.pending_actions,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Confirmed Bookings',
                  confirmedBookings.toString(),
                  Icons.check_circle,
                  Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Services',
                  _services.length.toString(),
                  Icons.room_service,
                  Colors.green,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Total Revenue',
                  '\$${totalRevenue.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.purple,
                ),
              ),
            ],
          ),

          SizedBox(height: 24),
          Text(
            'Recent Bookings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          // Recent Bookings
          _bookings.isEmpty
              ? Card(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.book_online_outlined,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No bookings yet'),
                        ],
                      ),
                    ),
                  ),
                )
              : Column(
                  children: _bookings.take(5).map((booking) {
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(booking.status),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text('Booking #${booking.id}'),
                        subtitle: Text(
                            '${booking.bookingDate} at ${booking.bookingTime}'),
                        trailing: _buildStatusChip(booking.status),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Services',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/manage-services')
                      .then((_) => _loadData());
                },
                icon: Icon(Icons.add),
                label: Text('Add Service'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _services.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.room_service_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No services added yet'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/manage-services')
                              .then((_) => _loadData());
                        },
                        child: Text('Add Your First Service'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    Service service = _services[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.content_cut, color: Colors.white),
                        ),
                        title: Text(service.name,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (service.description != null)
                              Text(service.description!),
                            Text('Duration: ${service.duration} minutes'),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '\$${service.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBookingsTab() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bookings',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/view-bookings')
                      .then((_) => _loadData());
                },
                icon: Icon(Icons.visibility),
                label: Text('View All'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book_online_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No bookings yet'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    Booking booking = _bookings[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(booking.status),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text('Booking #${booking.id}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date: ${booking.bookingDate}'),
                            Text('Time: ${booking.bookingTime}'),
                            Text(
                                'Price: \$${booking.totalPrice.toStringAsFixed(2)}'),
                          ],
                        ),
                        trailing: _buildStatusChip(booking.status),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
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
                    child: Icon(Icons.store, size: 50, color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    _shop?.name ?? 'Shop Name',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(_shop?.address ?? 'Address'),
                  if (_shop?.phone != null) Text(_shop!.phone!),
                  if (_shop?.description != null)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(_shop!.description!),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Owner Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text(_currentUser?.name ?? 'Owner Name'),
                    subtitle: Text('Owner'),
                  ),
                  ListTile(
                    leading: Icon(Icons.email),
                    title: Text(_currentUser?.email ?? 'Email'),
                    subtitle: Text('Email'),
                  ),
                  if (_currentUser?.phone != null)
                    ListTile(
                      leading: Icon(Icons.phone),
                      title: Text(_currentUser!.phone!),
                      subtitle: Text('Phone'),
                    ),
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

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
