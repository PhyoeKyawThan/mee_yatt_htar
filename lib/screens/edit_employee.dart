import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mee_yatt_htar/helpers/assets.dart';
import 'package:mee_yatt_htar/helpers/database_helper.dart';
import 'package:mee_yatt_htar/helpers/employee.dart';
import 'package:intl/intl.dart';
import 'package:mee_yatt_htar/screens/add_employee.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mee_yatt_htar/screens/subs/autocomplete.dart';
import 'package:path_provider/path_provider.dart';

// -----------------------------------------------------------------------------
// 1. EDIT EMPLOYEE SCREEN - RESPONSIVE
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
  final TextEditingController _educationDescController =
      TextEditingController();

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
      _educationDescController,
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
    _educationDescController.text = employee.educationDesc ?? '';
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
    if (AppConstants.isDesktop) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Choose Image Source',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildImageSourceButton(
                        Icons.photo_library,
                        'Gallery',
                        () {
                          Navigator.of(context).pop();
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                      _buildImageSourceButton(Icons.camera_alt, 'Camera', () {
                        Navigator.of(context).pop();
                        _pickImage(ImageSource.camera);
                      }),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_imageFile != null || _originalImagePath != null)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _imageFile = null;
                        });
                      },
                      child: const Text(
                        'Remove Photo',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    } else {
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
                if (_imageFile != null || _originalImagePath != null)
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
  }

  Widget _buildImageSourceButton(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        IconButton(icon: Icon(icon, size: 40), onPressed: onTap),
        const SizedBox(height: 8),
        Text(label),
      ],
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
        educationDesc: _educationDescController.text.trim(),
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

  // Widget builders
  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        width: AppConstants.imageSize,
        height: AppConstants.imageSize,
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
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo,
                      size: AppConstants.isDesktop ? 60 : 50,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add Photo',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: AppConstants.isDesktop ? 16 : 14,
                      ),
                    ),
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
    List<String>? suggestions,
  }) {
    final bool useAutocomplete = suggestions != null && suggestions.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppConstants.fieldSpacing),
      child: useAutocomplete
          ? AutocompleteTextField(
              controller: controller,
              label: label,
              hint: hint,
              suggestions: suggestions!,
              isReadOnly: isReadOnly,
            )
          : TextField(
              controller: controller,
              readOnly: isReadOnly,
              keyboardType:
                  keyboardType ??
                  (isNumber ? TextInputType.number : TextInputType.text),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: label,
                hintText: hint,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: AppConstants.isDesktop ? 20 : 16,
                ),
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
      padding: EdgeInsets.symmetric(vertical: AppConstants.fieldSpacing),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () => _selectDate(context, flag),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
          hintText: hint,
          suffixIcon: const Icon(Icons.calendar_today),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: AppConstants.isDesktop ? 20 : 16,
          ),
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
      padding: EdgeInsets.symmetric(vertical: AppConstants.fieldSpacing),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: hintText,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: AppConstants.isDesktop ? 20 : 16,
          ),
        ),
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              displayString(item),
              style: TextStyle(fontSize: AppConstants.fontSizeBody),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppConstants.fieldSpacing),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gender',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeBody,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text(
                        "Male",
                        style: TextStyle(fontSize: AppConstants.fontSizeBody),
                      ),
                      value: "Male",
                      groupValue: _gender,
                      onChanged: (String? value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text(
                        "Female",
                        style: TextStyle(fontSize: AppConstants.fontSizeBody),
                      ),
                      value: "Female",
                      groupValue: _gender,
                      onChanged: (String? value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(height: AppConstants.sectionSpacing),
        ElevatedButton(
          onPressed: _updateEmployee,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            padding: EdgeInsets.symmetric(
              vertical: AppConstants.isDesktop ? 16 : 12,
            ),
          ),
          child: Text(
            "Update Employee",
            style: TextStyle(fontSize: AppConstants.fontSizeBody),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            "Cancel",
            style: TextStyle(fontSize: AppConstants.fontSizeBody),
          ),
        ),
        SizedBox(height: AppConstants.sectionSpacing),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(children: _buildFormFields()),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: AppConstants.formMaxWidth),
          child: Column(
            children: [
              // Image picker centered at top
              _buildImagePicker(),
              SizedBox(height: AppConstants.sectionSpacing),

              // Two-column layout for form fields
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column - Personal Information
                  Expanded(child: Column(children: _buildPersonalInfoFields())),

                  SizedBox(width: AppConstants.sectionSpacing),

                  // Right column - Employment Information
                  Expanded(
                    child: Column(children: _buildEmploymentInfoFields()),
                  ),
                ],
              ),

              // Training and Remarks (full width)
              ..._buildAdditionalFields(),

              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      _buildImagePicker(),
      SizedBox(height: AppConstants.sectionSpacing),
      ..._buildPersonalInfoFields(),
      ..._buildEmploymentInfoFields(),
      ..._buildAdditionalFields(),
      _buildActionButtons(),
    ];
  }

  List<Widget> _buildPersonalInfoFields() {
    return [
      _buildTextField(_fullNameController, "Full Name", "Mg Hla Mg"),
      _buildGenderSelection(),
      _buildTextField(_fatherNameController, "Father's Name", "U Hla"),
      _buildTextField(_motherNameController, "Mother's Name", "eg. Daw Mya"),
      _buildTextField(_nrcNumberController, "NRC Number", "12/KaMaNa(N)123456"),
      _buildDateField(_dateOfBirthController, "Date of Birth", "DD/MM/YYYY", 0),
      _buildTextField(_ageController, "Age", "e.g. 30", isReadOnly: true),
      _buildDropdownFormField<String>(
        hintText: "Select Education Level",
        items: AppConstants.educationLevels,
        value: _educationLevel,
        onChanged: (value) => setState(() => _educationLevel = value),
        displayString: (item) => item,
      ),
      _buildTextField(
        _educationDescController,
        "Education Description",
        "eg. Secondary Passed",
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
    ];
  }

  List<Widget> _buildEmploymentInfoFields() {
    return [
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
        suggestions: AppConstants.positionSuggestions,
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
        suggestions: AppConstants.positionSuggestions,
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
    ];
  }

  List<Widget> _buildAdditionalFields() {
    return [
      Padding(
        padding: EdgeInsets.symmetric(vertical: AppConstants.fieldSpacing),
        child: TrainingChipsInput(
          onChipsChanged: _updateTrainingList,
          initialCourses: _trainingCoursesList,
        ),
      ),
      _buildTextField(_remarksController, "Remarks", "Any notes"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Edit Employee",
          style: TextStyle(fontSize: AppConstants.fontSizeTitle),
        ),
        actions: [
          if (AppConstants.isDesktop)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _updateEmployee,
              tooltip: 'Save Changes',
            ),
        ],
      ),
      body: AppConstants.isDesktop
          ? _buildDesktopLayout()
          : _buildMobileLayout(),
    );
  }
}
