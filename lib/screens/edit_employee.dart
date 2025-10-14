import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mee_yatt_htar/helpers/database_helper.dart';
import 'package:mee_yatt_htar/helpers/employee.dart';
import 'package:intl/intl.dart';
import 'package:mee_yatt_htar/screens/add_employee.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

// -----------------------------------------------------------------------------
// 1. EDIT EMPLOYEE SCREEN
// -----------------------------------------------------------------------------

class EditEmployeeScreen extends StatefulWidget {
  final Employee employee;

  const EditEmployeeScreen({super.key, required this.employee});

  @override
  State<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
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

  // State variables
  String? _gender;
  String? _educationLevel;
  String? _bloodType;
  String? _assignedBranch;
  String? _currentSalaryRange;
  List<String> _trainingCoursesList = [];
  DateTime? _selectedDate;
  File? _imageFile;
  String? _originalImagePath;

  final ImagePicker _picker = ImagePicker();
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _prefillData();
  }

  void _initializeControllers() {
    _controllers.addAll([
      _fullNameController,
      _fatherNameController,
      _motherNameController,
      _nrcNumberController,
      _dateOfBirthController,
      _ageController,
      _occupationController,
      _addressController,
      _firstAssignedPositionController,
      _firstAssignedDateController,
      _currentPositionController,
      _currentPositionAssignDateController,
      _currentSalaryController,
      _remarksController,
    ]);
  }

  void _prefillData() {
    final employee = widget.employee;

    // Personal Information
    _fullNameController.text = employee.fullName;
    _gender = employee.gender;
    _fatherNameController.text = employee.fatherName ?? '';
    _motherNameController.text = employee.motherName ?? '';
    _nrcNumberController.text = employee.nrcNumber ?? '';
    _dateOfBirthController.text = employee.dateOfBirth ?? '';
    _ageController.text = employee.age?.toString() ?? '';
    _educationLevel = employee.educationLevel;
    _bloodType = employee.bloodType;
    _addressController.text = employee.address ?? '';

    // Employment Information
    _assignedBranch = employee.assignedBranch;
    _firstAssignedPositionController.text =
        employee.firstAssignedPosition ?? '';
    _firstAssignedDateController.text = employee.firstAssignedDate ?? '';
    _currentPositionController.text = employee.currentPosition ?? '';
    _currentSalaryRange = employee.currentSalaryRange;
    _currentPositionAssignDateController.text =
        employee.currentPositionAssignDate ?? '';
    _currentSalaryController.text = employee.currentSalary ?? '';

    // Training and Remarks
    _trainingCoursesList = List.from(employee.trainingCourses);
    _remarksController.text = employee.remarks ?? '';

    // Image
    _originalImagePath = employee.imagePath;
    if (employee.imagePath != null) {
      _imageFile = File(employee.imagePath!);
    }

    // Parse dates if they exist
    _parseExistingDates();
  }

  void _parseExistingDates() {
    final dateFormat = DateFormat('dd/MM/yyyy');

    try {
      if (widget.employee.dateOfBirth != null &&
          widget.employee.dateOfBirth!.isNotEmpty) {
        _selectedDate = dateFormat.parse(widget.employee.dateOfBirth!);
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Image handling methods
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        imageQuality: 70,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
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
              if (_imageFile != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _imageFile = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _saveImagePermanently(File? imageFile) async {
    if (imageFile == null) return _originalImagePath;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${_fullNameController.text.replaceAll(' ', '_')}.png';
      final newPath = '${directory.path}/$fileName';
      final File newImage = await imageFile.copy(newPath);
      return newImage.path;
    } catch (e) {
      print('Error saving image: $e');
      return _originalImagePath;
    }
  }

  // Date handling methods
  Future<void> _selectDate(BuildContext context, int flag) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate && mounted) {
      setState(() {
        _selectedDate = picked;
        final dateFormat = DateFormat('dd/MM/yyyy');

        switch (flag) {
          case 0: // Date of Birth
            _dateOfBirthController.text = dateFormat.format(picked);
            _ageController.text = _calculateAge(picked).toString();
            break;
          case 1: // First Assigned Date
            _firstAssignedDateController.text = dateFormat.format(picked);
            break;
          case 2: // Current Position Assign Date
            _currentPositionAssignDateController.text = dateFormat.format(
              picked,
            );
            break;
        }
      });
    }
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Validation methods
  bool _validateForm() {
    if (_fullNameController.text.isEmpty) {
      _showErrorSnackBar('Please enter the full name.');
      return false;
    }

    if (_nrcNumberController.text.isEmpty) {
      _showErrorSnackBar('Please enter the NRC number.');
      return false;
    }

    return true;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  // Core update logic
  Future<void> _updateEmployee() async {
    if (!_validateForm()) return;

    try {
      // Save Image (if one was picked or changed)
      String? finalImagePath;
      if (_imageFile != null && _imageFile!.path != _originalImagePath) {
        finalImagePath = await _saveImagePermanently(_imageFile!);
      } else {
        finalImagePath = _originalImagePath;
      }

      // Create the updated Employee object
      final updatedEmployee = Employee(
        id: widget.employee.id, // Preserve the original ID
        fullName: _fullNameController.text.trim(),
        gender: _gender,
        fatherName: _fatherNameController.text.trim(),
        motherName: _motherNameController.text.trim(),
        nrcNumber: _nrcNumberController.text.trim(),
        dateOfBirth: _dateOfBirthController.text,
        age: int.tryParse(_ageController.text),
        educationLevel: _educationLevel,
        bloodType: _bloodType,
        address: _addressController.text.trim(),
        assignedBranch: _assignedBranch,
        firstAssignedPosition: _firstAssignedPositionController.text.trim(),
        firstAssignedDate: _firstAssignedDateController.text,
        currentPosition: _currentPositionController.text.trim(),
        currentSalaryRange: _currentSalaryRange,
        currentPositionAssignDate: _currentPositionAssignDateController.text,
        currentSalary: _currentSalaryController.text.trim(),
        trainingCourses: _trainingCoursesList,
        remarks: _remarksController.text.trim(),
        imagePath: finalImagePath,
      );

      // Update in the database
      final rowsAffected = await DatabaseHelper.instance.updateEmployee(
        updatedEmployee,
      );

      if (!mounted) return;

      if (rowsAffected > 0) {
        _showSuccessSnackBar('Employee updated successfully!');
        Navigator.of(context).pop(true); // Return success flag
      } else {
        _showErrorSnackBar('Failed to update employee record.');
      }
    } catch (e) {
      _showErrorSnackBar('Error updating employee: $e');
    }
  }

  void _updateTrainingList(List<String> newList) {
    setState(() {
      _trainingCoursesList = newList;
    });
  }

  // Widget builders (similar to AddEmployeeScreen)
  Widget _buildImagePicker() {
    return GestureDetector(
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
            : _originalImagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(File(_originalImagePath!), fit: BoxFit.cover),
              )
            : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                    Text('Add Photo', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isReadOnly = false,
    bool isNumber = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        keyboardType:
            keyboardType ??
            (isNumber ? TextInputType.number : TextInputType.text),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
          hintText: hint,
        ),
      ),
    );
  }

  Widget _buildDateField(
    TextEditingController controller,
    String label,
    String hint,
    int flag,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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

  Widget _buildDropdownFormField<T>({
    required String hintText,
    required List<T> items,
    required T? value,
    required ValueChanged<T?> onChanged,
    required String Function(T item) displayString,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: hintText,
        ),
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(displayString(item)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Row(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Edit Employee"),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _updateEmployee),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Photo Upload
            _buildImagePicker(),
            const SizedBox(height: 20),

            // Personal Details Section
            _buildTextField(_fullNameController, "Full Name", "Mg Hla Mg"),
            _buildGenderSelection(),
            _buildTextField(_fatherNameController, "Father's Name", "U Hla"),
            _buildTextField(
              _motherNameController,
              "Mother's Name",
              "eg. Daw Mya",
            ),
            _buildTextField(
              _nrcNumberController,
              "NRC Number",
              "12/KaMaNa(N)123456",
            ),
            _buildDateField(
              _dateOfBirthController,
              "Date of Birth",
              "DD/MM/YYYY",
              0,
            ),
            _buildTextField(_ageController, "Age", "e.g. 30", isReadOnly: true),

            _buildDropdownFormField<String>(
              hintText: "Select Education Level",
              items: AppConstants.educationLevels,
              value: _educationLevel,
              onChanged: (value) => setState(() => _educationLevel = value),
              displayString: (item) => item,
            ),

            _buildDropdownFormField<String>(
              hintText: "Select Blood Group",
              items: AppConstants.bloodTypes,
              value: _bloodType,
              onChanged: (value) => setState(() => _bloodType = value),
              displayString: (item) => item,
            ),

            _buildTextField(
              _addressController,
              "Address",
              "eg. No . 1 U Ba Road Hinthaa",
            ),

            // Employment Details Section
            _buildDropdownFormField<String>(
              hintText: "Select Assigned Branch",
              items: AppConstants.assignedBranches,
              value: _assignedBranch,
              onChanged: (value) => setState(() => _assignedBranch = value),
              displayString: (item) => item,
            ),

            _buildTextField(
              _firstAssignedPositionController,
              "First assigned Position",
              "junior content writer",
            ),
            _buildDateField(
              _firstAssignedDateController,
              "First Assigned Date",
              "DD/MM/YY",
              1,
            ),
            _buildTextField(
              _currentPositionController,
              "Current Position",
              "Senior Write",
            ),

            _buildDropdownFormField<String>(
              hintText: "Select Salary Range",
              items: AppConstants.salaryRanges,
              value: _currentSalaryRange,
              onChanged: (value) => setState(() => _currentSalaryRange = value),
              displayString: (item) => item,
            ),

            _buildDateField(
              _currentPositionAssignDateController,
              "Current Position Assigned Date",
              "MM/DD/YY",
              2,
            ),
            _buildTextField(
              _currentSalaryController,
              "Current Salary",
              "eg. 100000",
              isNumber: true,
            ),

            // Training Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TrainingChipsInput(
                onChipsChanged: _updateTrainingList,
                initialCourses: _trainingCoursesList,
              ),
            ),

            _buildTextField(_remarksController, "Remarks", "Any notes"),

            // Action Buttons
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updateEmployee,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "Update Employee",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. UPDATE EMPLOYEE DETAIL SCREEN WITH EDIT FUNCTIONALITY
// -----------------------------------------------------------------------------
