// database_helper.dart
import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'employee.dart'; // Import the model class
import 'package:mysql_client/mysql_client.dart';

class DatabaseHelper {
  static final bool isMobile = Platform.isAndroid || Platform.isIOS;
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Database instances
  static Database? _sqliteDatabase;
  static MySQLConnection? _mysqlConnection;

  DatabaseHelper._privateConstructor();

  // Initialize the appropriate database based on platform
  Future<void> initialize() async {
    if (isMobile) {
      await _initSQLiteDatabase();
    } else {
      await _initMySQLConnection();
    }
  }

  // SQLite initialization
  Future<Database> _initSQLiteDatabase() async {
    if (_sqliteDatabase != null) return _sqliteDatabase!;

    String path = join(await getDatabasesPath(), 'employee_records.db');
    _sqliteDatabase = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreateSQLite,
    );
    return _sqliteDatabase!;
  }

  Future _onCreateSQLite(Database db, int version) async {
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

  Future<MySQLConnection> _initMySQLConnection({int retryCount = 2}) async {
    for (int attempt = 0; attempt <= retryCount; attempt++) {
      try {
        if (_mysqlConnection != null) {
          if (_mysqlConnection!.connected) {
            // Test the connection
            await _mysqlConnection!.execute("SELECT 1");
            return _mysqlConnection!;
          } else {
            await _mysqlConnection!.close();
            _mysqlConnection = null;
          }
        }

        _mysqlConnection = await MySQLConnection.createConnection(
          host: '127.0.0.1',
          port: 3306,
          userName: 'domak',
          password: 'domak90@',
          databaseName: 'employee_records',
        );

        await _mysqlConnection!.connect();

        // Set longer timeout to prevent quick disconnections
        await _mysqlConnection!.execute("SET SESSION wait_timeout=28800");
        await _mysqlConnection!.execute(
          "SET SESSION interactive_timeout=28800",
        );

        await _initializeMySQLDatabase();
        return _mysqlConnection!;
      } catch (e) {
        print('Connection attempt $attempt failed: $e');

        // Clean up on failure
        if (_mysqlConnection != null) {
          await _mysqlConnection!.close();
          _mysqlConnection = null;
        }

        // Wait before retry (except on last attempt)
        if (attempt < retryCount) {
          await Future.delayed(Duration(seconds: 1));
        }
      }
    }

    throw Exception(
      'Failed to establish MySQL connection after $retryCount attempts',
    );
  }

  Future<void> _initializeMySQLDatabase() async {
    final conn = await _initMySQLConnection();
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS employees (
        id INT AUTO_INCREMENT PRIMARY KEY,
        fullName VARCHAR(255) NOT NULL,
        gender VARCHAR(50),
        fatherName VARCHAR(255),
        motherName VARCHAR(255),
        nrcNumber VARCHAR(100),
        dateOfBirth VARCHAR(100),
        age INT,
        educationLevel VARCHAR(255),
        educationDesc TEXT,
        bloodType VARCHAR(10),
        address TEXT,
        assignedBranch VARCHAR(255),
        firstAssignedPosition VARCHAR(255),
        firstAssignedDate VARCHAR(100),
        currentPosition VARCHAR(255),
        currentSalaryRange VARCHAR(255),
        currentPositionAssignDate VARCHAR(100),
        currentSalary VARCHAR(100),
        trainingCourses TEXT,
        remarks TEXT,
        imagePath TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      )
    ''');
  }

  // --- Unified CRUD Operations ---

  // Insert an employee record
  Future<int> insertEmployee(Employee employee) async {
    if (isMobile) {
      return await _insertEmployeeSQLite(employee);
    } else {
      return await _insertEmployeeMySQL(employee);
    }
  }

  // Delete an employee record
  Future<int> deleteEmployee(Employee employee) async {
    if (isMobile) {
      return await _deleteEmployeeSQLite(employee);
    } else {
      return await _deleteEmployeeMySQL(employee);
    }
  }

  // Get employee by ID
  Future<Employee?> getEmployeeById(int id) async {
    if (isMobile) {
      return await _getEmployeeByIdSQLite(id);
    } else {
      return await _getEmployeeByIdMySQL(id);
    }
  }

  // Get all employees
  Future<List<Employee>> getEmployees() async {
    if (isMobile) {
      return await _getEmployeesSQLite();
    } else {
      return await _getEmployeesMySQL();
    }
  }

  // Update employee
  Future<int> updateEmployee(Employee employee) async {
    if (isMobile) {
      return await _updateEmployeeSQLite(employee);
    } else {
      return await _updateEmployeeMySQL(employee);
    }
  }

  // Search employees
  Future<List<Employee>> searchEmployees(String query) async {
    if (isMobile) {
      return await _searchEmployeesSQLite(query);
    } else {
      return await _searchEmployeesMySQL(query);
    }
  }

  // --- SQLite-specific implementations ---

  Future<int> _insertEmployeeSQLite(Employee employee) async {
    Database db = await _initSQLiteDatabase();
    return await db.insert(
      'employees',
      employee.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> _deleteEmployeeSQLite(Employee employee) async {
    Database db = await _initSQLiteDatabase();
    return await db.delete(
      'employees',
      where: 'id = ?',
      whereArgs: [employee.id],
    );
  }

  Future<Employee?> _getEmployeeByIdSQLite(int id) async {
    final db = await _initSQLiteDatabase();
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

  Future<List<Employee>> _getEmployeesSQLite() async {
    Database db = await _initSQLiteDatabase();
    final List<Map<String, dynamic>> maps = await db.query('employees');

    return List.generate(maps.length, (i) {
      return Employee.fromMap(maps[i]);
    });
  }

  Future<int> _updateEmployeeSQLite(Employee employee) async {
    final db = await _initSQLiteDatabase();
    return await db.update(
      'employees',
      employee.toMap(),
      where: 'id = ?',
      whereArgs: [employee.id],
    );
  }

  Future<List<Employee>> _searchEmployeesSQLite(String query) async {
    final db = await _initSQLiteDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: 'fullName LIKE ?',
      whereArgs: ['%$query%'],
    );

    return List.generate(maps.length, (i) {
      return Employee.fromMap(maps[i]);
    });
  }

  // --- MySQL-specific implementations ---

  Future<int> _insertEmployeeMySQL(Employee employee) async {
    final conn = await _initMySQLConnection();
    final result = await conn.execute(
      '''
      INSERT INTO employees (
        fullName, gender, fatherName, motherName, nrcNumber, dateOfBirth, age,
        educationLevel, educationDesc, bloodType, address, assignedBranch,
        firstAssignedPosition, firstAssignedDate, currentPosition, currentSalaryRange,
        currentPositionAssignDate, currentSalary, trainingCourses, remarks, imagePath
      ) VALUES (:fullName, :gender, :fatherName, :motherName, :nrcNumber, 
      :dateOfBirth, :age, 
      :educationLevel, :educationDesc, :bloodType, :address, :assignBranch, :firstAssignPosition, 
      :firstAssignDate, :currentPosition, :currentSalaryRange, :currentPossitionAssignDate, :currentSalary, :trainingCourses, :remarks, :imagePath)
      ''',
      {
        "fullName": employee.fullName,
        "gender": employee.gender,
        "fatherName": employee.fatherName,
        "motherName": employee.motherName,
        "nrcNumber": employee.nrcNumber,
        "dateOfBirth": employee.dateOfBirth,
        "age": employee.age,
        "educationLevel": employee.educationLevel,
        "educationDesc": employee.educationDesc,
        "bloodType": employee.bloodType,
        "address": employee.address,
        "assignBranch": employee.assignedBranch,
        "firstAssignPosition": employee.firstAssignedPosition,
        "firstAssignDate": employee.firstAssignedDate,
        "currentPosition": employee.currentPosition,
        "currentSalaryRange": employee.currentSalaryRange,
        "currentPossitionAssignDate": employee.currentPositionAssignDate,
        "currentSalary": employee.currentSalary,
        "trainingCourses": employee.trainingCourses != null
            ? jsonEncode(employee.trainingCourses)
            : null,
        "remarks": employee.remarks,
        "imagePath": employee.imagePath,
      },
    );

    return result.lastInsertID.toInt();
  }

  Future<int> _deleteEmployeeMySQL(Employee employee) async {
    final conn = await _initMySQLConnection();
    final result = await conn.execute('DELETE FROM employees WHERE id = :id', {
      "id": employee.id,
    });

    return result.affectedRows.toInt();
  }

  Future<Employee?> _getEmployeeByIdMySQL(int id) async {
    final conn = await _initMySQLConnection();
    final result = await conn.execute(
      'SELECT * FROM employees WHERE id = :id',
      {"id": id},
    );

    if (result.rows.isNotEmpty) {
      final row = result.rows.first;
      return _rowToEmployee(row);
    }
    return null;
  }

  Future<List<Employee>> _getEmployeesMySQL() async {
    final conn = await _initMySQLConnection();
    final result = await conn.execute(
      'SELECT * FROM employees ORDER BY id DESC',
    );

    return result.rows.map(_rowToEmployee).toList();
  }

  Future<int> _updateEmployeeMySQL(Employee employee) async {
    final conn = await _initMySQLConnection();
    final result = await conn.execute(
      '''
      UPDATE employees SET
        fullName = :fullName, 
        gender = :gender, fatherName = :fatherName, motherName = :motherName, 
        nrcNumber = :nrcNumber, dateOfBirth = :dateOfBirth, age = :age, 
        educationLevel = :educationLevel, educationDesc = :educationDesc, 
        bloodType = :bloodType, address = :address, assignedBranch = :assignBranch, 
        firstAssignedPosition = :firstAssignPosition, firstAssignedDate = :firstAssignDate,
        currentPosition = :currentPosition, currentSalaryRange = :currentSalaryRange, 
        currentPositionAssignDate = :currentPossitionAssignDate, currentSalary = :currentSalary, 
        trainingCourses = :trainingCourses, remarks = :remarks, imagePath = :imagePath
      WHERE id = :id
      ''',
      {
        "id": employee.id,
        "fullName": employee.fullName,
        "gender": employee.gender,
        "fatherName": employee.fatherName,
        "motherName": employee.motherName,
        "nrcNumber": employee.nrcNumber,
        "dateOfBirth": employee.dateOfBirth,
        "age": employee.age,
        "educationLevel": employee.educationLevel,
        "educationDesc": employee.educationDesc,
        "bloodType": employee.bloodType,
        "address": employee.address,
        "assignBranch": employee.assignedBranch,
        "firstAssignPosition": employee.firstAssignedPosition,
        "firstAssignDate": employee.firstAssignedDate,
        "currentPosition": employee.currentPosition,
        "currentSalaryRange": employee.currentSalaryRange,
        "currentPossitionAssignDate": employee.currentPositionAssignDate,
        "currentSalary": employee.currentSalary,
        "trainingCourses": employee.trainingCourses != null
            ? jsonEncode(employee.trainingCourses)
            : null,
        "remarks": employee.remarks,
        "imagePath": employee.imagePath,
      },
    );

    return result.affectedRows.toInt();
  }

  Future<List<Employee>> _searchEmployeesMySQL(String query) async {
    final conn = await _initMySQLConnection();
    final result = await conn.execute(
      'SELECT * FROM employees WHERE fullName LIKE :searchString ORDER BY id DESC',
      {"searchString": "%$query%"},
    );

    return result.rows.map(_rowToEmployee).toList();
  }

  // Helper method to convert MySQL row to Employee
  Employee _rowToEmployee(ResultSetRow row) {
    return Employee.fromMap({
      'id': row.colByName('id'),
      'fullName': row.colByName('fullName'),
      'gender': row.colByName('gender'),
      'fatherName': row.colByName('fatherName'),
      'motherName': row.colByName('motherName'),
      'nrcNumber': row.colByName('nrcNumber'),
      'dateOfBirth': row.colByName('dateOfBirth'),
      'age': row.colByName('age'),
      'educationLevel': row.colByName('educationLevel'),
      'educationDesc': row.colByName('educationDesc'),
      'bloodType': row.colByName('bloodType'),
      'address': row.colByName('address'),
      'assignedBranch': row.colByName('assignedBranch'),
      'firstAssignedPosition': row.colByName('firstAssignedPosition'),
      'firstAssignedDate': row.colByName('firstAssignedDate'),
      'currentPosition': row.colByName('currentPosition'),
      'currentSalaryRange': row.colByName('currentSalaryRange'),
      'currentPositionAssignDate': row.colByName('currentPositionAssignDate'),
      'currentSalary': row.colByName('currentSalary'),
      'trainingCourses': row.colByName('trainingCourses'),
      'remarks': row.colByName('remarks'),
      'imagePath': row.colByName('imagePath'),
    });
  }

  // --- Common methods ---

  Future<void> uploadEmployees() async {
    try {
      List<Employee> employees = await getEmployees();

      List<Map<String, dynamic>> employeeList = [];

      for (var employee in employees) {
        var employeeMap = employee.toMap();

        if (employee.imagePath != null && employee.imagePath!.isNotEmpty) {
          try {
            File imageFile = File(employee.imagePath!);
            if (await imageFile.exists()) {
              List<int> imageBytes = await imageFile.readAsBytes();
              String base64Image = base64Encode(imageBytes);
              employeeMap['imageData'] = base64Image;
              employeeMap['imageMimeType'] = 'image/jpeg';
            }
          } catch (e) {
            print("Error reading image for ${employee.fullName}: $e");
          }
        }

        employeeList.add(employeeMap);
      }

      String jsonBody = jsonEncode(employeeList);

      final url = Uri.parse('http://192.168.79.153:5000/upload');
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

  // Sample insert method
  Future<void> sampleInsert() async {
    if (isMobile) {
      await _sampleInsertSQLite();
    } else {
      await _sampleInsertMySQL();
    }
  }

  Future<void> _sampleInsertSQLite() async {
    final db = await _initSQLiteDatabase();
    await db.rawInsert("""
      INSERT INTO employees (
        fullName, gender, fatherName, motherName, nrcNumber, dateOfBirth, age,
        educationLevel, educationDesc, bloodType, address, firstAssignedPosition,
        firstAssignedDate, currentPosition, currentPositionAssignDate, currentSalary,
        trainingCourses, remarks, imagePath
      ) VALUES (
        'Aung Kyaw Moe', 'Male', 'U Kyaw Win', 'Daw Mya Mya', '12/PaKaNa(N)123456',
        '12/05/1995', 30, 'ဝိဇ္ဇာ', 'UCSH 4th yr', 'B+', 'No.23, 5th Street, Yangon',
        'Junior Developer', '2019-03-01', 'Senior Developer', '10/02/2024', '950000',
        '["Flutter Development", "Database Management", "Leadership Training"]',
        'Excellent performance in recent project',
        '/storage/emulated/0/Android/data/com.example.mee_yatt_htar/files/images/aungkyawmoe.jpg'
      )
    """);
  }

  Future<void> _sampleInsertMySQL() async {
    final conn = await _initMySQLConnection();
    await conn.execute("""
      INSERT INTO employees (
        fullName, gender, fatherName, motherName, nrcNumber, dateOfBirth, age,
        educationLevel, educationDesc, bloodType, address, firstAssignedPosition,
        firstAssignedDate, currentPosition, currentPositionAssignDate, currentSalary,
        trainingCourses, remarks, imagePath
      ) VALUES (
        'Aung Kyaw Moe', 'Male', 'U Kyaw Win', 'Daw Mya Mya', '12/PaKaNa(N)123456',
        '12/05/1995', 30, 'ဝိဇ္ဇာ', 'UCSH 4th yr', 'B+', 'No.23, 5th Street, Yangon',
        'Junior Developer', '2019-03-01', 'Senior Developer', '10/02/2024', '950000',
        '["Flutter Development", "Database Management", "Leadership Training"]',
        'Excellent performance in recent project',
        '/storage/emulated/0/Android/data/com.example.mee_yatt_htar/files/images/aungkyawmoe.jpg'
      )
    """);
  }

  // Close connections
  Future<void> close() async {
    if (_sqliteDatabase != null) {
      await _sqliteDatabase!.close();
      _sqliteDatabase = null;
    }

    if (_mysqlConnection != null) {
      await _mysqlConnection!.close();
      _mysqlConnection = null;
    }
  }
}
