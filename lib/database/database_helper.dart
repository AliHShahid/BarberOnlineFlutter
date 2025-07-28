// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import '../models/user.dart';
// import '../models/shop.dart';
// import '../models/service.dart';
// import '../models/booking.dart';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   static Database? _database;

//   DatabaseHelper._internal();

//   factory DatabaseHelper() => _instance;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     String path = join(await getDatabasesPath(), 'barber_management.db');
//     return await openDatabase(path, version: 1, onCreate: _createTables);
//   }

//   Future<void> _createTables(Database db, int version) async {
//     // Users table (both customers and shop owners)
//     await db.execute('''
//       CREATE TABLE users (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         name TEXT NOT NULL,
//         email TEXT UNIQUE NOT NULL,
//         password TEXT NOT NULL,
//         phone TEXT,
//         user_type TEXT NOT NULL,
//         created_at TEXT NOT NULL
//       )
//     ''');

//     // Shops table
//     await db.execute('''
//       CREATE TABLE shops (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         owner_id INTEGER NOT NULL,
//         name TEXT NOT NULL,
//         address TEXT NOT NULL,
//         phone TEXT,
//         description TEXT,
//         opening_time TEXT,
//         closing_time TEXT,
//         created_at TEXT NOT NULL,
//         FOREIGN KEY (owner_id) REFERENCES users (id)
//       )
//     ''');

//     // Services table
//     await db.execute('''
//       CREATE TABLE services (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         shop_id INTEGER NOT NULL,
//         name TEXT NOT NULL,
//         description TEXT,
//         price REAL NOT NULL,
//         duration INTEGER NOT NULL,
//         created_at TEXT NOT NULL,
//         FOREIGN KEY (shop_id) REFERENCES shops (id)
//       )
//     ''');

//     // Bookings table
//     await db.execute('''
//       CREATE TABLE bookings (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         customer_id INTEGER NOT NULL,
//         shop_id INTEGER NOT NULL,
//         service_id INTEGER NOT NULL,
//         booking_date TEXT NOT NULL,
//         booking_time TEXT NOT NULL,
//         status TEXT NOT NULL,
//         total_price REAL NOT NULL,
//         notes TEXT,
//         created_at TEXT NOT NULL,
//         FOREIGN KEY (customer_id) REFERENCES users (id),
//         FOREIGN KEY (shop_id) REFERENCES shops (id),
//         FOREIGN KEY (service_id) REFERENCES services (id)
//       )
//     ''');
//   }

//   // User operations
//   Future<int> insertUser(User user) async {
//     final db = await database;
//     return await db.insert('users', user.toMap());
//   }

//   Future<User?> getUserByEmail(String email) async {
//     final db = await database;
//     final maps = await db.query(
//       'users',
//       where: 'email = ?',
//       whereArgs: [email],
//     );
//     if (maps.isNotEmpty) {
//       return User.fromMap(maps.first);
//     }
//     return null;
//   }

//   Future<User?> getUserById(int id) async {
//     final db = await database;
//     final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
//     if (maps.isNotEmpty) {
//       return User.fromMap(maps.first);
//     }
//     return null;
//   }

//   // Shop operations
//   Future<int> insertShop(Shop shop) async {
//     final db = await database;
//     return await db.insert('shops', shop.toMap());
//   }

//   Future<List<Shop>> getAllShops() async {
//     final db = await database;
//     final maps = await db.query('shops');
//     return List.generate(maps.length, (i) => Shop.fromMap(maps[i]));
//   }

//   Future<Shop?> getShopByOwnerId(int ownerId) async {
//     final db = await database;
//     final maps = await db.query(
//       'shops',
//       where: 'owner_id = ?',
//       whereArgs: [ownerId],
//     );
//     if (maps.isNotEmpty) {
//       return Shop.fromMap(maps.first);
//     }
//     return null;
//   }

//   // Service operations
//   Future<int> insertService(Service service) async {
//     final db = await database;
//     return await db.insert('services', service.toMap());
//   }

//   Future<List<Service>> getServicesByShopId(int shopId) async {
//     final db = await database;
//     final maps = await db.query(
//       'services',
//       where: 'shop_id = ?',
//       whereArgs: [shopId],
//     );
//     return List.generate(maps.length, (i) => Service.fromMap(maps[i]));
//   }

//   Future<int> updateService(Service service) async {
//     final db = await database;
//     return await db.update(
//       'services',
//       service.toMap(),
//       where: 'id = ?',
//       whereArgs: [service.id],
//     );
//   }

//   Future<int> deleteService(int id) async {
//     final db = await database;
//     return await db.delete('services', where: 'id = ?', whereArgs: [id]);
//   }

//   // Booking operations
//   Future<int> insertBooking(Booking booking) async {
//     final db = await database;
//     return await db.insert('bookings', booking.toMap());
//   }

//   Future<List<Booking>> getBookingsByCustomerId(int customerId) async {
//     final db = await database;
//     final maps = await db.query(
//       'bookings',
//       where: 'customer_id = ?',
//       whereArgs: [customerId],
//     );
//     return List.generate(maps.length, (i) => Booking.fromMap(maps[i]));
//   }

//   Future<List<Booking>> getBookingsByShopId(int shopId) async {
//     final db = await database;
//     final maps = await db.query(
//       'bookings',
//       where: 'shop_id = ?',
//       whereArgs: [shopId],
//     );
//     return List.generate(maps.length, (i) => Booking.fromMap(maps[i]));
//   }

//   Future<int> updateBookingStatus(int bookingId, String status) async {
//     final db = await database;
//     return await db.update(
//       'bookings',
//       {'status': status},
//       where: 'id = ?',
//       whereArgs: [bookingId],
//     );
//   }
// }

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/shop.dart';
import '../models/service.dart';
import '../models/booking.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'barber_management.db');
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    // Users table (both customers and shop owners)
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        phone TEXT,
        user_type TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Shops table
    await db.execute('''
      CREATE TABLE shops (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        owner_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        phone TEXT,
        description TEXT,
        opening_time TEXT,
        closing_time TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (owner_id) REFERENCES users (id)
      )
    ''');

    // Services table
    await db.execute('''
      CREATE TABLE services (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        duration INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (shop_id) REFERENCES shops (id)
      )
    ''');

    // Bookings table
    await db.execute('''
      CREATE TABLE bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        shop_id INTEGER NOT NULL,
        service_id INTEGER NOT NULL,
        booking_date TEXT NOT NULL,
        booking_time TEXT NOT NULL,
        status TEXT NOT NULL,
        total_price REAL NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES users (id),
        FOREIGN KEY (shop_id) REFERENCES shops (id),
        FOREIGN KEY (service_id) REFERENCES services (id)
      )
    ''');
  }

  // User operations
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Shop operations
  Future<int> insertShop(Shop shop) async {
    final db = await database;
    return await db.insert('shops', shop.toMap());
  }

  Future<List<Shop>> getAllShops() async {
    final db = await database;
    final maps = await db.query('shops');
    return List.generate(maps.length, (i) => Shop.fromMap(maps[i]));
  }

  Future<Shop?> getShopByOwnerId(int ownerId) async {
    final db = await database;
    final maps = await db.query(
      'shops',
      where: 'owner_id = ?',
      whereArgs: [ownerId],
    );
    if (maps.isNotEmpty) {
      return Shop.fromMap(maps.first);
    }
    return null;
  }

  // Service operations
  Future<int> insertService(Service service) async {
    final db = await database;
    return await db.insert('services', service.toMap());
  }

  Future<List<Service>> getServicesByShopId(int shopId) async {
    final db = await database;
    final maps = await db.query(
      'services',
      where: 'shop_id = ?',
      whereArgs: [shopId],
    );
    return List.generate(maps.length, (i) => Service.fromMap(maps[i]));
  }

  Future<int> updateService(Service service) async {
    final db = await database;
    return await db.update(
      'services',
      service.toMap(),
      where: 'id = ?',
      whereArgs: [service.id],
    );
  }

  Future<int> deleteService(int id) async {
    final db = await database;
    return await db.delete('services', where: 'id = ?', whereArgs: [id]);
  }

  // Booking operations
  Future<int> insertBooking(Booking booking) async {
    final db = await database;
    return await db.insert('bookings', booking.toMap());
  }

  Future<List<Booking>> getBookingsByCustomerId(int customerId) async {
    final db = await database;
    final maps = await db.query(
      'bookings',
      where: 'customer_id = ?',
      whereArgs: [customerId],
    );
    return List.generate(maps.length, (i) => Booking.fromMap(maps[i]));
  }

  Future<List<Booking>> getBookingsByShopId(int shopId) async {
    final db = await database;
    final maps = await db.query(
      'bookings',
      where: 'shop_id = ?',
      whereArgs: [shopId],
    );
    return List.generate(maps.length, (i) => Booking.fromMap(maps[i]));
  }

  Future<int> updateBookingStatus(int bookingId, String status) async {
    final db = await database;
    return await db.update(
      'bookings',
      {'status': status},
      where: 'id = ?',
      whereArgs: [bookingId],
    );
  }
}
