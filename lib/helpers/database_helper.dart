// database_helper.dart
import 'dart:convert';
// import 'dart:io';
// import 'dart:nativewrappers/_internal/vm/lib/developer.dart';

import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
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
        educationDesc TEXT,
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

  Future<int> deleteEmployee(Employee employee) async {
    Database db = await instance.database;
    return await db.delete(
      'employees',
      where: 'id = ?',
      whereArgs: [employee.id],
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

  Future<void> uploadEmployees() async {
    try {
      // 1. Fetch all employees
      List<Employee> employees = await getEmployees();

      // 2. Convert each employee to a Map and then to JSON
      List<Map<String, dynamic>> employeeList = employees
          .map((e) => e.toMap())
          .toList();

      String jsonBody = jsonEncode(employeeList);

      // 3. Send POST request to /upload
      final url = Uri.parse('http://192.168.37.153:5000/upload');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        print("Upload successful: ${response.body}");
      } else {
        print("Upload failed: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error during upload: $e");
    }
  }

  Future<void> sampleInsert() async {
    final db = await instance.database;

    db.rawInsert("""INSERT INTO employees (
    fullName,
    gender,
    fatherName,
    motherName,
    nrcNumber,
    dateOfBirth,
    age,
    educationLevel,
    educationDesc,
    bloodType,
    address,
   
    firstAssignedPosition,
    firstAssignedDate,
    currentPosition,
   
    currentPositionAssignDate,
    currentSalary,
    trainingCourses,
    remarks,
    imagePath
) VALUES (
    'Aung Kyaw Moe',
    'Male',
    'U Kyaw Win',
    'Daw Mya Mya',
    '12/PaKaNa(N)123456',
    '12/05/1995',
    30,
    'ဝိဇ္ဇာ',
    'UCSH 4th yr',
    'B+',
    'No.23, 5th Street, Yangon',
   
    'Junior Developer',
    '2019-03-01',
    'Senior Developer',
    
    '10/02/2024',
    '950000',
    '["Flutter Development", "Database Management", "Leadership Training"]',
    'Excellent performance in recent project',
    '/storage/emulated/0/Android/data/com.example.mee_yatt_htar/files/images/aungkyawmoe.jpg')
""");
    await db.rawInsert("""
INSERT INTO employees (
    fullName,
    gender,
    fatherName,
    motherName,
    nrcNumber,
    dateOfBirth,
    age,
    educationLevel,
    bloodType,
    address,
    
    firstAssignedPosition,
    firstAssignedDate,
    currentPosition,
    
    currentPositionAssignDate,
    currentSalary,
    trainingCourses,
    remarks,
    imagePath
) VALUES (
    'Aung Kyaw Moe',
    'Male',
    'U Kyaw Win',
    'Daw Mya Mya',
    '12/PaKaNa(N)123456',
    '12/05/1995',
    30,
    'ဝိဇ္ဇာ',
    'B+',
    'No.23, 5th Street, Yangon',
    
    'Junior Developer',
    '2019-03-01',
    'Senior Developer',
    '10/02/2024',
    '950000',
    '["Flutter Development", "Database Management", "Leadership Training"]',
    'Excellent performance in recent project',
    '/storage/emulated/0/Android/data/com.example.mee_yatt_htar/files/images/aungkyawmoe.jpg'
);
""");
    await db.rawInsert("""
INSERT INTO employees (
    fullName,
    gender,
    fatherName,
    motherName,
    nrcNumber,
    dateOfBirth,
    age,
    educationLevel,
    bloodType,
    address,
    firstAssignedPosition,
    firstAssignedDate,
    currentPosition,
    currentPositionAssignDate,
    currentSalary,
    trainingCourses,
    remarks,
    imagePath
) VALUES (
    'Su Su Lwin',
    'Female',
    'U Tun Lwin',
    'Daw Nge Nge',
    '9/PaNaLa(N)789012',
    '25/11/1994',
    31,
    'ဝိဇ္ဇာ',
    'O+',
    'No.120, Baho Road, Mandalay',
    'Accountant',
    '2020-01-15',
    'Senior Accountant',
    '01/07/2023',
    '210000',
    '["Finance Management", "Excel Advanced", "Team Leadership"]',
    'Promoted for outstanding accuracy in reports',
    '/storage/emulated/0/Android/data/com.example.mee_yatt_htar/files/images/susulwin.jpg'
);
""");

    // db.execute(sql)
  }

  // You can add update and delete methods as well if needed.
}
