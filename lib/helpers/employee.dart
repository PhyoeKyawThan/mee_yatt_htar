import 'package:sqflite/sqflite.dart'; // Required for SQLite operations
import 'package:path/path.dart'; // Required for database path handling
import 'dart:async';

// ----------------------------------------------------
// 1. Employee Model (Data Structure)
// ----------------------------------------------------
/// Defines the structure for storing employee information.
class Employee {
  int? id;
  String fullName;
  String? gender;
  String fatherName;
  String nrcNumber;
  String dateOfBirth; // Storing as String (DD/MM/YYYY)
  int age;
  String occupation;
  String householdStatus;
  String householdMembers;
  String householdSize;
  String income;
  String salaryRange;
  String monthlyExpenditure;
  String savings;
  String remarks;

  Employee({
    this.id,
    required this.fullName,
    required this.gender,
    required this.fatherName,
    required this.nrcNumber,
    required this.dateOfBirth,
    required this.age,
    required this.occupation,
    required this.householdStatus,
    required this.householdMembers,
    required this.householdSize,
    required this.income,
    required this.salaryRange,
    required this.monthlyExpenditure,
    required this.savings,
    required this.remarks,
  });

  // Converts the Employee object into a Map for database insertion.
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'gender': gender,
      'fatherName': fatherName,
      'nrcNumber': nrcNumber,
      'dateOfBirth': dateOfBirth,
      'age': age,
      'occupation': occupation,
      'householdStatus': householdStatus,
      'householdMembers': householdMembers,
      'householdSize': householdSize,
      'income': income,
      'salaryRange': salaryRange,
      'monthlyExpenditure': monthlyExpenditure,
      'savings': savings,
      'remarks': remarks,
    };
  }
}

// ----------------------------------------------------
// 2. Database Helper Class (SQLite Operations)
// ----------------------------------------------------
/// Singleton class to manage database connection and CRUD operations.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;
  static const String tableName = 'employees';

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Initializes the database connection.
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'employee_database.db');

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Creates the database table.
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT,
        gender TEXT,
        fatherName TEXT,
        nrcNumber TEXT,
        dateOfBirth TEXT,
        age INTEGER,
        occupation TEXT,
        householdStatus TEXT,
        householdMembers TEXT,
        householdSize TEXT,
        income TEXT,
        salaryRange TEXT,
        monthlyExpenditure TEXT,
        savings TEXT,
        remarks TEXT
      )
    ''');
  }

  // Inserts a new employee record into the database.
  Future<int> insertEmployee(Employee employee) async {
    final db = await instance.database;
    return await db.insert(
      tableName,
      employee.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // You would add other methods here (e.g., getEmployees, updateEmployee, deleteEmployee)
}
