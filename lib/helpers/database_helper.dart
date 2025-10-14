// database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'employee.dart'; // Import the model class

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'employee_records.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE employees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        gender TEXT,
        fatherName TEXT,
        motherName TEXT,
        nrcNumber TEXT,
        dateOfBirth TEXT,
        age INTEGER,
        educationLevel TEXT,
        bloodType TEXT,
        address TEXT,
        assignedBranch TEXT,
        firstAssignedPosition TEXT,
        firstAssignedDate TEXT,
        currentPosition TEXT,
        currentSalaryRange TEXT,
        currentPositionAssignDate TEXT,
        currentSalary TEXT,
        trainingCourses TEXT, -- Stored as a JSON string
        remarks TEXT,
        imagePath TEXT
      )
    ''');
  }

  // --- CRUD Operations ---

  // Insert an employee record
  Future<int> insertEmployee(Employee employee) async {
    Database db = await instance.database;
    return await db.insert(
      'employees',
      employee.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Employee?> getEmployeeById(int id) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Employee.fromMap(maps.first);
    }
    return null;
  }

  // Retrieve all employee records
  Future<List<Employee>> getEmployees() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('employees');

    return List.generate(maps.length, (i) {
      return Employee.fromMap(maps[i]);
    });
  }

  Future<int> updateEmployee(Employee employee) async {
    final db = await database;

    return await db.update(
      'employees',
      employee.toMap(),
      where: 'id = ?',
      whereArgs: [employee.id],
    );
  }

  // You can add update and delete methods as well if needed.
}
