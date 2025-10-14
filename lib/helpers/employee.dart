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
    // Deserialize the JSON string back into a List<String>
    List<String> courses = [];
    if (map['trainingCourses'] != null) {
      final decoded = jsonDecode(map['trainingCourses'] as String);
      courses = List<String>.from(decoded);
    }

    return Employee(
      id: map['id'] as int?,
      fullName: map['fullName'] as String,
      gender: map['gender'] as String?,
      fatherName: map['fatherName'] as String?,
      motherName: map['motherName'] as String?,
      nrcNumber: map['nrcNumber'] as String?,
      dateOfBirth: map['dateOfBirth'] as String?,
      age: map['age'] as int?,
      educationLevel: map['educationLevel'] as String?,
      bloodType: map['bloodType'] as String?,
      address: map['address'] as String?,
      assignedBranch: map['assignedBranch'] as String?,
      firstAssignedPosition: map['firstAssignedPosition'] as String?,
      firstAssignedDate: map['firstAssignedDate'] as String?,
      currentPosition: map['currentPosition'] as String?,
      currentSalaryRange: map['currentSalaryRange'] as String?,
      currentPositionAssignDate: map['currentPositionAssignDate'] as String?,
      currentSalary: map['currentSalary'] as String?,
      trainingCourses: courses, // Use the deserialized list
      remarks: map['remarks'] as String?,
      imagePath: map['imagePath'] as String?,
    );
  }
}
