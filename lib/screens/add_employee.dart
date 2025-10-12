import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
// Note: You must ensure 'mee_yatt_htar/helpers/assets.dart'
// and 'mee_yatt_htar/helpers/employee.dart' are available in your project.
// For this example to run without errors, these package imports are assumed to exist.

// Placeholder data structures (since real ones aren't provided)
const List<String> educationLevel = [
  'High School',
  'Bachelor',
  'Master',
  'PhD',
];
const List<String> bloodTypes = [
  'A+',
  'A-',
  'B+',
  'B-',
  'O+',
  'O-',
  'AB+',
  'AB-',
];
const List<String> assignedBranch = ['Branch A', 'Branch B', 'Branch C'];
const List<String> salaryRange = [
  '100k-200k',
  '200k-400k',
  '400k-600k',
  '600k+',
];

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
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

  File? _imageFile;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 1000,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      if (!mounted) return;

      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
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

  Future<void> _selectDate(BuildContext context, int flag) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      if (!mounted) return;

      setState(() {
        _selectedDate = picked;
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
            break;
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

  void _clearFields() {
    _fullNameController.clear();
    _fatherNameController.clear();
    _motherNameController.clear();
    _nrcNumberController.clear();
    _dateOfBirthController.clear();
    _ageController.clear();
    _occupationController.clear();
    _addressController.clear();
    _firstAssignedPositionController.clear();
    _firstAssignedDateController.clear();
    _currentPositionController.clear();
    _currentPositionAssignDateController.clear();
    _currentSalaryController.clear();
    _remarksController.clear();
    setState(() {
      _selectedDate = null;
      _imageFile = null;
      _gender = null;
      _educationLevel = null;
      _bloodType = null;
      _assignedBranch = null;
      _currentSalaryRange = null;
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
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 50,
                                color: Colors.grey,
                              ),
                              Text(
                                'Add Photo',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              buildTextField(_fullNameController, "Full Name", "Mg Hla Mg"),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Male"),
                      value: "Male",
                      groupValue: _gender,
                      onChanged: (String? value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Female"),
                      value: "Female",
                      groupValue: _gender,
                      onChanged: (String? value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                    ),
                  ),
                ],
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
              buildDateField(
                _dateOfBirthController,
                "Date of Birth",
                "DD/MM/YYYY",
                0,
              ),
              buildTextField(
                _ageController,
                "Age",
                "e.g. 30",
                isReadOnly: true,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: DropdownButtonFormField<String>(
                  value: _educationLevel,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Select Education Level",
                  ),
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
                child: DropdownButtonFormField<String>(
                  value: _bloodType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Select Blood Group",
                  ),
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
                child: DropdownButtonFormField<String>(
                  value: _assignedBranch,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Select Assigned Branch",
                  ),
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
                child: DropdownButtonFormField<String>(
                  value: _currentSalaryRange,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Select Salary Range",
                  ),
                  items: salaryRange.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _currentSalaryRange = value;
                    });
                  },
                ),
              ),
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
                isNumber: true,
              ),
              buildTextField(_remarksController, "Remarks", "Any notes"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Implement your employee saving logic here
                },
                child: const Text("Add Employee"),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _clearFields,
                child: const Text("Clear Fields"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isReadOnly = false,
    bool isNumber = false,
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
        readOnly: true,
        onTap: () => _selectDate(context, flag),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
          hintText: hint,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
      ),
    );
  }
}
