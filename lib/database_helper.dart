import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  DatabaseHelper.internal();

  initDb() async {
    String path = join(await getDatabasesPath(), "users.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
      "CREATE TABLE users(id INTEGER PRIMARY KEY, name TEXT, role TEXT, nfcId TEXT, manualId TEXT, password TEXT)"
    );
    await db.execute(
      "CREATE TABLE attendance(id INTEGER PRIMARY KEY, userId INTEGER, date TEXT, status TEXT)"
    );
    await db.execute(
      "CREATE TABLE jobdesk(id INTEGER PRIMARY KEY, userId INTEGER, monday TEXT, tuesday TEXT, wednesday TEXT, thursday TEXT, friday TEXT)"
    );
    
    await db.insert('users', {'name': 'Employee', 'role': 'employee', 'nfcId': 'F1A39AAA', 'manualId': 'richard.ivan', 'password': '123'});
    await db.insert('users', {'name': 'Supervisor', 'role': 'supervisor', 'nfcId': 'C50634E6', 'manualId': 'nadya.yulianto', 'password': '123'});
    await db.insert('jobdesk', {'userId': 1, 'monday': 'jalur 11', 'tuesday': 'jalur 1', 'wednesday': 'jalur 11', 'thursday': 'jalur 1', 'friday': 'jalur 11'});
    await db.insert('jobdesk', {'userId': 2, 'monday': 'jalur 1', 'tuesday': 'jalur 11', 'wednesday': 'jalur 1', 'thursday': 'jalur 11', 'friday': 'jalur 1'});
  }

  Future<List<Map<String, dynamic>>> getUserByNfcId(String nfcId) async {
    var dbClient = await db;
    var result = await dbClient.query(
      'users',
      where: 'nfcId = ?',
      whereArgs: [nfcId]
    );
    return result;
  }

  Future<void> markAttendance(int userId, String date, String status) async {
    var dbClient = await db;
    await dbClient.insert(
      'attendance',
      {'userId': userId, 'date': date, 'status': status},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('Attendance marked for userId: $userId on $date with status $status');
  }

  Future<List<Map<String, dynamic>>> getAttendance(int userId) async {
    var dbClient = await db;
    var result = await dbClient.query(
      'attendance',
      where: 'userId = ?',
      whereArgs: [userId]
    );
    return result;
  }

  Future<List<Map<String, dynamic>>> getAllAttendance() async {
    var dbClient = await db;
    var result = await dbClient.query('attendance');
    return result;
  }

  Future<void> updateAttendanceStatus(int id, String status) async {
    var dbClient = await db;
    await dbClient.update(
      'attendance',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    var dbClient = await db;
    var result = await dbClient.query('users');
    return result;
  }

  Future<List<Map<String, dynamic>>> getJobdesk(int userId) async {
    var dbClient = await db;
    var result = await dbClient.query(
      'jobdesk',
      where: 'userId = ?',
      whereArgs: [userId]
    );
    return result;
  }

  Future<void> updateJobdesk(int userId, Map<String, String> jobdesk) async {
    var dbClient = await db;
    await dbClient.update(
      'jobdesk',
      jobdesk,
      where: 'userId = ?',
      whereArgs: [userId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  bool checkManualLogin(String manualId, String password) {
    if ((manualId == 'richard.ivan' && password == '123') ||
        (manualId == 'nadya.yulianto' && password == '123')) {
      return true;
    }
    return false;
  }

  // Add method to get user by manual ID
  Future<Map<String, dynamic>?> getUserByManualId(String manualId) async {
    var dbClient = await db;
    var result = await dbClient.query(
      'users',
      where: 'manualId = ?',
      whereArgs: [manualId]
    );
    return result.isNotEmpty ? result.first : null;
  }
}
