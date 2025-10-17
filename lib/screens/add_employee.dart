import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mee_yatt_htar/helpers/assets.dart';
import 'package:mee_yatt_htar/helpers/database_helper.dart';
import 'package:mee_yatt_htar/helpers/employee.dart';
import 'package:mee_yatt_htar/screens/subs/autocomplete.dart';
import 'package:path_provider/path_provider.dart';

// -----------------------------------------------------------------------------
// 1. TRAINING CHIPS INPUT WIDGET
// -----------------------------------------------------------------------------

class TrainingChipsInput extends StatefulWidget {
  final ValueChanged<List<String>> onChipsChanged;
  final List<String> initialCourses;

  const TrainingChipsInput({
    super.key,
    required this.onChipsChanged,
    this.initialCourses = const [],
  });

  @override
  State<TrainingChipsInput> createState() => _TrainingChipsInputState();
}

class _TrainingChipsInputState extends State<TrainingChipsInput> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late List<String> _courseChips;

  @override
  void initState() {
    super.initState();
    _courseChips = List.from(widget.initialCourses);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addChip(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isNotEmpty && !_courseChips.contains(trimmedName)) {
      setState(() {
        _courseChips.add(trimmedName);
        _inputController.clear();
        widget.onChipsChanged(_courseChips);
      });
      _focusNode.requestFocus();
    } else if (trimmedName.isNotEmpty) {
      _inputController.clear();
      _focusNode.requestFocus();
    }
  }

  void _removeChip(String name) {
    setState(() {
      _courseChips.remove(name);
      widget.onChipsChanged(_courseChips);
    });
  }

  Widget _buildChip(String courseName) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
      child: Chip(
        label: Text(courseName),
        backgroundColor: Colors.teal.shade100,
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: () => _removeChip(courseName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_courseChips.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              children: _courseChips.map(_buildChip).toList(),
            ),
          ),
        TextFormField(
          controller: _inputController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: 'သင်တန်းအမည် ထည့်သွင်းပါ',
            hintText: 'ဥပမာ: ေရ ှာင်းကကြီး',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.teal),
              onPressed: () => _addChip(_inputController.text),
            ),
          ),
          onFieldSubmitted: _addChip,
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 2. ADD EMPLOYEE SCREEN
// ------------------------------------------

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
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

  final TextEditingController _educationDescConrtoller =
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

  final ImagePicker _picker = ImagePicker();
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    // Initialize controllers list for easy disposal
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
      _educationDescConrtoller,
    ]);
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
            ],
          ),
        );
      },
    );
  }

  Future<String?> _saveImagePermanently(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${_fullNameController.text.replaceAll(' ', '_')}.png';
      final newPath = '${directory.path}/$fileName';
      final File newImage = await imageFile.copy(newPath);
      return newImage.path;
    } catch (e) {
      print('Error saving image: $e');
      return null;
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

  // Core saving logic
  Future<void> _saveEmployee() async {
    if (!_validateForm()) return;

    try {
      // Save Image (if one was picked)
      String? finalImagePath;
      if (_imageFile != null) {
        finalImagePath = await _saveImagePermanently(_imageFile!);
      }

      // Create the Employee object
      final newEmployee = Employee(
        fullName: _fullNameController.text.trim(),
        gender: _gender,
        fatherName: _fatherNameController.text.trim(),
        motherName: _motherNameController.text.trim(),
        nrcNumber: _nrcNumberController.text.trim(),
        dateOfBirth: _dateOfBirthController.text,
        age: int.tryParse(_ageController.text),
        educationLevel: _educationLevel,
        educationDesc: _educationDescConrtoller.text.trim(),
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

      // Insert into the database
      final id = await DatabaseHelper.instance.insertEmployee(newEmployee);

      if (!mounted) return;

      if (id > 0) {
        _showSuccessSnackBar('Employee added successfully! ID: $id');
        _clearFields();
      } else {
        _showErrorSnackBar('Failed to save employee record.');
      }
    } catch (e) {
      _showErrorSnackBar('Error saving employee: $e');
    }
  }

  void _clearFields() {
    for (final controller in _controllers) {
      controller.clear();
    }

    setState(() {
      _selectedDate = null;
      _imageFile = null;
      _gender = null;
      _educationLevel = null;
      _bloodType = null;
      _assignedBranch = null;
      _currentSalaryRange = null;
      _trainingCoursesList = [];
    });
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
    List<String>? suggestions,
  }) {
    // Determine if it should be the Autocomplete version
    final bool useAutocomplete = suggestions != null && suggestions.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.fieldSpacing),
      child: useAutocomplete
          ? AutocompleteTextField(
              // key: UniqueKey(),
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
      padding: const EdgeInsets.symmetric(vertical: AppConstants.fieldSpacing),
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
      padding: const EdgeInsets.symmetric(vertical: AppConstants.fieldSpacing),
      child: DropdownButtonFormField<T>(
        initialValue: value,
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _saveEmployee,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text("Add Employee"),
        ),
        const SizedBox(height: 10),
        TextButton(onPressed: _clearFields, child: const Text("Clear Fields")),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Add New Employee")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
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
            _buildTextField(
              _educationDescConrtoller,
              "Education Description",
              "eg. Secondary passed",
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

            // Training Section
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.fieldSpacing,
              ),
              child: TrainingChipsInput(
                key: UniqueKey(),
                onChipsChanged: _updateTrainingList,
                initialCourses: _trainingCoursesList,
              ),
            ),

            _buildTextField(_remarksController, "Remarks", "Any notes"),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }
}
