// employee.dart
import 'dart:convert';

class Employee {
  int? id;
  final String fullName;
  final String? gender;
  final String? fatherName;
  final String? motherName;
  final String? nrcNumber;
  final String? dateOfBirth;
  final int? age;
  final String? educationLevel;
  final String? educationDesc;
  final String? bloodType;
  final String? address;
  final String? assignedBranch;
  final String? firstAssignedPosition;
  final String? firstAssignedDate;
  final String? currentPosition;
  final String? currentSalaryRange;
  final String? currentPositionAssignDate;
  final String? currentSalary;
  final List<String> trainingCourses; // The List<String>
  final String? remarks;
  final String? imagePath; // Path to the stored image file

  Employee({
    this.id,
    required this.fullName,
    this.gender,
    this.fatherName,
    this.motherName,
    this.nrcNumber,
    this.dateOfBirth,
    this.age,
    this.educationLevel,
    this.educationDesc,
    this.bloodType,
    this.address,
    this.assignedBranch,
    this.firstAssignedPosition,
    this.firstAssignedDate,
    this.currentPosition,
    this.currentSalaryRange,
    this.currentPositionAssignDate,
    this.currentSalary,
    required this.trainingCourses,
    this.remarks,
    this.imagePath,
  });

  // Convert an Employee object into a Map (for saving to DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'gender': gender,
      'fatherName': fatherName,
      'motherName': motherName,
      'nrcNumber': nrcNumber,
      'dateOfBirth': dateOfBirth,
      'age': age,
      'educationLevel': educationLevel,
      'educationDesc': educationDesc,
      'bloodType': bloodType,
      'address': address,
      'assignedBranch': assignedBranch,
      'firstAssignedPosition': firstAssignedPosition,
      'firstAssignedDate': firstAssignedDate,
      'currentPosition': currentPosition,
      'currentSalaryRange': currentSalaryRange,
      'currentPositionAssignDate': currentPositionAssignDate,
      'currentSalary': currentSalary,
      // Convert the List<String> to a JSON string for storage
      'trainingCourses': jsonEncode(trainingCourses),
      'remarks': remarks,
      'imagePath': imagePath,
    };
  }

  // Create an Employee object from a Map (for reading from DB)
  factory Employee.fromMap(Map<String, dynamic> map) {
    // Safe conversion helpers
    int safeInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    String safeString(dynamic value) => value?.toString() ?? '';

    List<String> safeStringList(dynamic value) {
      if (value == null) return <String>[];
      if (value is String) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is List) {
            return List<String>.from(decoded.map((e) => e.toString()));
          }
        } catch (e) {
          return <String>[];
        }
      }
      if (value is List) {
        return List<String>.from(value.map((e) => e.toString()));
      }
      return <String>[];
    }

    return Employee(
      id: safeInt(map['id']),
      fullName: safeString(map['fullName']),
      gender: safeString(map['gender']),
      fatherName: safeString(map['fatherName']),
      motherName: safeString(map['motherName']),
      nrcNumber: safeString(map['nrcNumber']),
      dateOfBirth: safeString(map['dateOfBirth']),
      age: safeInt(map['age']),
      educationLevel: safeString(map['educationLevel']),
      educationDesc: safeString(map['educationDesc']),
      bloodType: safeString(map['bloodType']),
      address: safeString(map['address']),
      assignedBranch: safeString(map['assignedBranch']),
      firstAssignedPosition: safeString(map['firstAssignedPosition']),
      firstAssignedDate: safeString(map['firstAssignedDate']),
      currentPosition: safeString(map['currentPosition']),
      currentSalaryRange: safeString(map['currentSalaryRange']),
      currentPositionAssignDate: safeString(map['currentPositionAssignDate']),
      currentSalary: safeString(map['currentSalary']),
      trainingCourses: safeStringList(map['trainingCourses']),
      remarks: safeString(map['remarks']),
      imagePath: safeString(map['imagePath']),
    );
  }
}
