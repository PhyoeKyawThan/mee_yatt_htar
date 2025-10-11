import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Required for DateFormat
import 'package:mee_yatt_htar/helpers/assets.dart';
// Assuming your project structure uses a package path for the database helper
import 'package:mee_yatt_htar/helpers/employee.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  // Controllers for each field
  final TextEditingController _fullNameController = TextEditingController();
  String? _gender;
  String? _educationLevel;
  String? _bloodType;
  String? _assignedBranch;
  String? _currentSalaryRange;
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _nrcNumberController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _firstAssignedPositionController =
      TextEditingController();
  final TextEditingController _firstAssignedDateController =
      TextEditingController();
  final TextEditingController _currentPositionController =
      TextEditingController();
  final TextEditingController _currentPositionAssignDateController =
      TextEditingController();
  final TextEditingController _currentSalaryController =
      TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  DateTime? _selectedDate;

  // Dispose controllers to free up memory
  @override
  void dispose() {
    _fullNameController.dispose();
    // _genderController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _nrcNumberController.dispose();
    _dateOfBirthController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _addressController.dispose();
    _firstAssignedPositionController.dispose();
    _firstAssignedDateController.dispose();
    _currentPositionController.dispose();
    _currentPositionAssignDateController.dispose();
    _currentSalaryController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  // --- Date Picker Logic ---
  Future<void> _selectDate(BuildContext context, int flag) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Use DateFormat for robust date string generation
        switch (flag) {
          case 0:
            _dateOfBirthController.text = DateFormat(
              'dd/MM/yyyy',
            ).format(picked);
            _ageController.text = _calculateAge(picked).toString();
            break;
          case 1:
            _firstAssignedDateController.text = DateFormat(
              'dd/MM/yyyy',
            ).format(picked);
            break;
          case 2:
            _currentPositionAssignDateController.text = DateFormat(
              'dd/MM/yyyy',
            ).format(picked);
        }
      });
    }
  }

  int _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // --- SQLite Save Logic ---
  void _saveEmployee() async {
    // Basic validation
    if (_fullNameController.text.isEmpty ||
        _dateOfBirthController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Full Name and Date of Birth are required.'),
        ),
      );
      return;
    }

    // Create a new Employee object from the controller values (Employee is imported)
    // final newEmployee = Employee(
    //   fullName: _fullNameController.text,
    //   gender: _gender,
    //   fatherName: _fatherNameController.text,
    //   nrcNumber: _nrcNumberController.text,
    //   dateOfBirth: _dateOfBirthController.text,
    //   age: int.tryParse(_ageController.text) ?? 0, // Safely parse age
    //   occupation: _occupationController.text,

    //   remarks: _remarksController.text,
    // );

    try {
      // Call the database helper to insert the employee (DatabaseHelper is imported)
      // int id = await DatabaseHelper.instance.insertEmployee(newEmployee);

      // // Show success message and clear form
      // _clearFields();
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Employee ${newEmployee.fullName} saved! ID: $id'),
      //   ),
      // );
    } catch (e) {
      // Show error message
      print('Database insert failed: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save employee: $e')));
    }
  }

  // Helper to clear all input fields
  void _clearFields() {
    _fullNameController.clear();
    // _genderController.clear();
    _fatherNameController.clear();
    _motherNameController.clear();
    _nrcNumberController.clear();
    _dateOfBirthController.clear();
    _ageController.clear();
    _occupationController.clear();
    _addressController.clear();
    _firstAssignedPositionController.clear();
    _currentPositionController.dispose();
    _currentPositionAssignDateController.dispose();
    _currentSalaryController.clear();
    _remarksController.clear();
    setState(() {
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Add New Employee")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              buildTextField(_fullNameController, "Full Name", "Mg Hla Mg"),
              RadioGroup(
                groupValue: _gender,
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
                child: Row(
                  children: [
                    Radio<String>(value: "Male"),
                    const Text("Male"),
                    Radio<String>(value: "Female"),
                    const Text("Female"),
                  ],
                ),
              ),
              buildTextField(_fatherNameController, "Father's Name", "U Hla"),
              buildTextField(
                _motherNameController,
                "Mother's Name",
                "eg. Daw Mya",
              ),
              buildTextField(
                _nrcNumberController,
                "NRC Number",
                "12/KaMaNa(N)123456",
              ),
              // Date of Birth field
              buildDateField(
                _dateOfBirthController,
                "Date of Birth",
                "DD/MM/YYYY",
                0,
              ),
              // Age field (read-only)
              buildTextField(
                _ageController,
                "Age",
                "e.g. 30",
                isReadOnly: true,
              ),

              // buildDropDownlist(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: DropdownButton(
                  value: _educationLevel,
                  isExpanded: true,
                  hint: Text("Select Education Level"),
                  items: educationLevel.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _educationLevel = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: DropdownButton(
                  value: _bloodType,
                  hint: Text("Select Blood Group"),
                  isExpanded: true,
                  items: bloodTypes.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _bloodType = value;
                    });
                  },
                ),
              ),
              buildTextField(
                _addressController,
                "Address",
                "eg. No . 1 U Ba Road Hinthaa",
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: DropdownButton(
                  value: _assignedBranch,
                  hint: Text("Select Assigned Branch"),
                  isExpanded: true,
                  items: assignedBranch.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _assignedBranch = value;
                    });
                  },
                ),
              ),
              buildTextField(
                _firstAssignedPositionController,
                "First assigned Position",
                "junior content writer",
              ),
              const Text("First Assigned Date"),
              buildDateField(
                _firstAssignedDateController,
                "First Assigned Date",
                "DD/MM/YY",
                1,
              ),
              buildTextField(
                _currentPositionController,
                "Current Position",
                "Senior Write",
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: DropdownButton(
                  value: _currentSalaryRange,
                  hint: Text("Select Salary Range"),
                  isExpanded: true,
                  items: salaryRange.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _assignedBranch = value;
                    });
                  },
                ),
              ),
              const Text("Current Position Assigned Date"),
              buildDateField(
                _currentPositionAssignDateController,
                "Current Position Assigned Date",
                "MM/DD/YY",
                2,
              ),
              buildTextField(
                _currentSalaryController,
                "Current Salary",
                "eg. 100000",
              ),
              buildTextField(_remarksController, "Remarks", "Any notes"),
              const SizedBox(height: 20),
              ElevatedButton(
                // Call the save function on press
                onPressed: _saveEmployee,
                child: const Text("Add"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Generic TextField builder
  Widget buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isReadOnly = false,
    bool isNumber = false, // Use this for numerical inputs
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
          hintText: hint,
        ),
      ),
    );
  }

  // Specific TextField builder for Date Picker
  Widget buildDateField(
    TextEditingController controller,
    String label,
    String hint,
    int flag,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        readOnly: true, // Make the field read-only
        onTap: () => _selectDate(context, flag), // Launch date picker on tap
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Select Date",
          hintText: "DD/MM/YYYY",
          suffixIcon: Icon(Icons.calendar_today), // Add a calendar icon
        ),
        // onChanged is intentionally left out for readOnly fields
      ),
    );
  }
}
