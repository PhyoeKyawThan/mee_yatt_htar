import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mee_yatt_htar/helpers/database_helper.dart';
import 'package:mee_yatt_htar/helpers/employee.dart';
import 'package:mee_yatt_htar/screens/add_employee.dart';
import 'package:mee_yatt_htar/screens/edit_employee.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart' as path;

// -----------------------------------------------------------------------------
// RESPONSIVE LAYOUT CONSTANTS
// -----------------------------------------------------------------------------
class LayoutConstants {
  static bool get isDesktop =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  static double get cardPadding => isDesktop ? 24.0 : 16.0;
  static double get sectionSpacing => isDesktop ? 32.0 : 20.0;
  static double get itemSpacing => isDesktop ? 12.0 : 8.0;
  static double get avatarRadius => isDesktop ? 80.0 : 60.0;
  static double get fontSizeTitle => isDesktop ? 24.0 : 18.0;
  static double get fontSizeSubtitle => isDesktop ? 16.0 : 14.0;
  static double get fontSizeBody => isDesktop ? 15.0 : 14.0;
}

// -----------------------------------------------------------------------------
// 1. EMPLOYEE DETAIL SCREEN - RESPONSIVE
// -----------------------------------------------------------------------------
class EmployeeDetailScreen extends StatelessWidget {
  final Employee employee;
  final Function()? onEmployeeUpdated;
  final String? imagePath;

  const EmployeeDetailScreen({
    super.key,
    required this.employee,
    this.onEmployeeUpdated,
    this.imagePath,
  });

  Future<void> _refreshEmployeeData(BuildContext context) async {
    try {
      final updatedEmployee = await DatabaseHelper.instance.getEmployeeById(
        employee.id!,
      );

      if (updatedEmployee != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmployeeDetailScreen(
              employee: updatedEmployee,
              onEmployeeUpdated: onEmployeeUpdated,
              imagePath: path.join(
                path.dirname("$imagePath"),
                updatedEmployee.imagePath,
              ),
            ),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee data refreshed'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error refreshing data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToEditScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditEmployeeScreen(employee: employee, imagePath: imagePath),
      ),
    ).then((result) {
      if (result == true) {
        _refreshEmployeeData(context);
      }
    });
  }

  String calculateCurrentAge(String? birthDateString) {
    if (birthDateString == null || birthDateString.isEmpty) {
      return 'Not specified';
    }

    try {
      final parts = birthDateString.split('/');
      if (parts.length < 3) return 'Invalid date';

      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2].length == 2 ? '20${parts[2]}' : parts[2]);

      final birthDate = DateTime(year, month, day);
      final today = DateTime.now();

      int years = today.year - birthDate.year;
      int months = today.month - birthDate.month;
      int days = today.day - birthDate.day;

      if (days < 0) {
        final prevMonth = DateTime(today.year, today.month, 0);
        days += prevMonth.day;
        months--;
      }

      if (months < 0) {
        months += 12;
        years--;
      }
      String dates = "";
      dates += years > 0 ? "$years years, " : "";
      dates += months > 0 ? "$months months, " : "";
      dates += days > 0 ? "$days days" : "";
      return dates;
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          employee.fullName,
          style: TextStyle(fontSize: LayoutConstants.isDesktop ? 20.0 : 18.0),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditScreen(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshEmployeeData(context),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: LayoutConstants.isDesktop
          ? _buildDesktopLayout(context)
          : _buildMobileLayout(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column - Profile Image and Basic Info
          Container(
            width: 300,
            padding: const EdgeInsets.all(20.0),
            margin: const EdgeInsets.only(right: 24.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildProfileImage(),
                SizedBox(height: 20),
                _buildBasicInfoSection(),
              ],
            ),
          ),

          // Right Column - Detailed Information
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Information
                  _buildDesktopSection('Personal Information', [
                    _buildDesktopInfoRow('Full Name', employee.fullName),
                    _buildDesktopInfoRow(
                      'Gender',
                      employee.gender ?? 'Not specified',
                    ),
                    _buildDesktopInfoRow(
                      'Father\'s Name',
                      employee.fatherName ?? 'Not specified',
                    ),
                    _buildDesktopInfoRow(
                      'Mother\'s Name',
                      employee.motherName ?? 'Not specified',
                    ),
                    _buildDesktopInfoRow(
                      'NRC Number',
                      employee.nrcNumber ?? 'Not specified',
                    ),
                    _buildDesktopInfoRow(
                      'Date of Birth',
                      employee.dateOfBirth ?? 'Not specified',
                    ),
                    _buildDesktopInfoRow(
                      'Current Age',
                      calculateCurrentAge(employee.dateOfBirth),
                    ),
                    _buildDesktopInfoRow(
                      'Education Level',
                      employee.educationLevel ?? 'Not specified',
                    ),
                    _buildDesktopInfoRow(
                      'Education Description',
                      employee.educationDesc ?? 'Not Specified',
                    ),
                    _buildDesktopInfoRow(
                      'Blood Type',
                      employee.bloodType ?? 'Not specified',
                    ),
                    _buildDesktopInfoRow(
                      'Address',
                      employee.address ?? 'Not specified',
                    ),
                  ]),

                  SizedBox(height: LayoutConstants.sectionSpacing),

                  // Employment Information
                  _buildDesktopSection('Employment Information', [
                    _buildDesktopInfoRow(
                      'Assigned Branch',
                      employee.assignedBranch ?? 'Not specified',
                    ),
                    _buildDesktopInfoRow(
                      'First Position',
                      employee.firstAssignedPosition ?? 'Not specified',
                    ),
                    _buildDesktopInfoRow(
                      'First Assigned Date',
                      employee.firstAssignedDate ?? 'Not specified',
                    ),
                    _buildDesktopInfoRow(
                      'Current Position',
                      employee.currentPosition ?? 'Not specified',
                    ),
                    _buildDesktopInfoRow(
                      'Position Assign Date',
                      employee.currentPositionAssignDate ?? 'Not specified',
                    ),
                    _buildDesktopInfoRow(
                      'Current position period',
                      calculateCurrentAge(employee.currentPositionAssignDate),
                    ),
                    _buildDesktopInfoRow(
                      'Salary Range',
                      employee.currentSalaryRange ?? 'Not specified',
                    ),
                    _buildDesktopInfoRow(
                      'Current Salary',
                      employee.currentSalary ?? 'Not specified',
                    ),
                  ]),

                  if (employee.trainingCourses.isNotEmpty) ...[
                    SizedBox(height: LayoutConstants.sectionSpacing),
                    _buildTrainingCoursesSection(),
                  ],

                  if (employee.remarks != null &&
                      employee.remarks!.isNotEmpty) ...[
                    SizedBox(height: LayoutConstants.sectionSpacing),
                    _buildRemarksSection(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _refreshEmployeeData(context),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileImage(),
            SizedBox(height: 20),
            // _buildBasicInfoSection(),
            SizedBox(height: 20),
            _buildSectionHeader('Personal Information'),
            _buildInfoRow('Full Name', employee.fullName),
            _buildInfoRow('Gender', employee.gender ?? 'Not specified'),
            _buildInfoRow(
              'Father\'s Name',
              employee.fatherName ?? 'Not specified',
            ),
            _buildInfoRow(
              'Mother\'s Name',
              employee.motherName ?? 'Not specified',
            ),
            _buildInfoRow('NRC Number', employee.nrcNumber ?? 'Not specified'),
            _buildInfoRow(
              'Date of Birth',
              employee.dateOfBirth ?? 'Not specified',
            ),
            _buildInfoRow(
              'Current Age',
              calculateCurrentAge(employee.dateOfBirth),
            ),
            _buildInfoRow(
              'Education Level',
              employee.educationLevel ?? 'Not specified',
            ),
            _buildInfoRow(
              'Education Description',
              employee.educationDesc ?? 'Not Specified',
            ),
            _buildInfoRow('Blood Type', employee.bloodType ?? 'Not specified'),
            _buildInfoRow('Address', employee.address ?? 'Not specified'),

            SizedBox(height: 20),
            _buildSectionHeader('Employment Information'),
            _buildInfoRow(
              'Assigned Branch',
              employee.assignedBranch ?? 'Not specified',
            ),
            _buildInfoRow(
              'First Position',
              employee.firstAssignedPosition ?? 'Not specified',
            ),
            _buildInfoRow(
              'First Assigned Date',
              employee.firstAssignedDate ?? 'Not specified',
            ),
            _buildInfoRow(
              'Current Position',
              employee.currentPosition ?? 'Not specified',
            ),
            _buildInfoRow(
              'Position Assign Date',
              employee.currentPositionAssignDate ?? 'Not specified',
            ),
            _buildInfoRow(
              'Current position period',
              calculateCurrentAge(employee.currentPositionAssignDate),
            ),
            _buildInfoRow(
              'Salary Range',
              employee.currentSalaryRange ?? 'Not specified',
            ),
            _buildInfoRow(
              'Current Salary',
              employee.currentSalary ?? 'Not specified',
            ),

            if (employee.trainingCourses.isNotEmpty) ...[
              SizedBox(height: 20),
              _buildTrainingCoursesSection(),
            ],

            if (employee.remarks != null && employee.remarks!.isNotEmpty) ...[
              SizedBox(height: 20),
              _buildRemarksSection(),
            ],

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: CircleAvatar(
        radius: LayoutConstants.avatarRadius,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: employee.imagePath != null
            ? FileImage(File("$imagePath")) as ImageProvider
            : const AssetImage('assets/default_avatar.png'),
        child: employee.imagePath == null
            ? Icon(
                Icons.person,
                size: LayoutConstants.avatarRadius,
                color: Colors.grey,
              )
            : null,
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        Text(
          employee.fullName,
          style: TextStyle(
            fontSize: LayoutConstants.fontSizeTitle,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        if (employee.currentPosition != null) ...[
          SizedBox(height: 4),
          Text(
            employee.currentPosition!,
            style: TextStyle(
              fontSize: LayoutConstants.fontSizeSubtitle,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (employee.assignedBranch != null) ...[
          SizedBox(height: 4),
          Text(
            employee.assignedBranch!,
            style: TextStyle(
              fontSize: LayoutConstants.fontSizeBody,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildDesktopSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDesktopInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 100, 100, 100),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: LayoutConstants.isDesktop ? 150 : 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: LayoutConstants.fontSizeBody),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingCoursesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Training Courses'),
        SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: employee.trainingCourses
              .map(
                (course) => Chip(
                  label: Text(course),
                  backgroundColor: Colors.blue.shade100,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildRemarksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Remarks'),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(employee.remarks!),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 2. EMPLOYEE LIST ITEM WIDGET - RESPONSIVE
// -----------------------------------------------------------------------------
class EmployeeListItem extends StatelessWidget {
  final Employee employee;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final BuildContext context;
  final String? imageDir;
  const EmployeeListItem({
    super.key,
    required this.employee,
    required this.onTap,
    required this.onDelete,
    required this.context,
    required this.imageDir,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutConstants.isDesktop
        ? _buildDesktopItem(context)
        : _buildMobileItem(context);
  }

  Widget _buildDesktopItem(BuildContext context) {
    String _imagePath = "$imageDir/${employee.imagePath}";
    print(_imagePath);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: employee.imagePath != null
              ? FileImage(File(_imagePath)) as ImageProvider
              : const AssetImage('assets/default_avatar.png'),
          child: employee.imagePath == null
              ? const Icon(Icons.person, color: Colors.grey)
              : null,
        ),
        title: Text(
          employee.fullName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (employee.currentPosition != null)
              Text(
                employee.currentPosition!,
                style: const TextStyle(fontSize: 14),
              ),
            if (employee.assignedBranch != null)
              Text(
                'Branch: ${employee.assignedBranch!}',
                style: const TextStyle(fontSize: 13),
              ),
            if (employee.currentSalary != null)
              Text(
                'Salary: ${employee.currentSalary!}',
                style: const TextStyle(fontSize: 13),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: (onTap),
              tooltip: 'Edit Employee',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: _showDeleteConfirmationDialog,
              tooltip: 'Delete Employee',
            ),
          ],
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildMobileItem(BuildContext context) {
    String _imagePath = "$imageDir/${employee.imagePath}";
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: employee.imagePath != null
              ? FileImage(File(_imagePath)) as ImageProvider
              : const AssetImage('assets/default_avatar.png'),
          child: employee.imagePath == null
              ? const Icon(Icons.person, color: Colors.grey)
              : null,
        ),
        title: Text(
          employee.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (employee.currentPosition != null)
              Text(employee.currentPosition!),
            if (employee.assignedBranch != null)
              Text('Branch: ${employee.assignedBranch!}'),
            if (employee.currentSalaryRange != null)
              Text('Salary: ${employee.currentSalaryRange!}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
        onLongPress: _showDeleteConfirmationDialog,
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Employee'),
          content: Text(
            'Are you sure you want to delete ${employee.fullName}? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onDelete();
              },
            ),
          ],
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// 3. FILTER BOTTOM SHEET / DIALOG - RESPONSIVE
// -----------------------------------------------------------------------------
class FilterBottomSheet extends StatefulWidget {
  final FilterOptions currentFilters;
  final Function(FilterOptions) onApplyFilters;

  const FilterBottomSheet({
    super.key,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late FilterOptions _currentFilters;

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.currentFilters;
  }

  @override
  Widget build(BuildContext context) {
    if (LayoutConstants.isDesktop) {
      return _buildDesktopDialog(context);
    } else {
      return _buildMobileBottomSheet(context);
    }
  }

  Widget _buildDesktopDialog(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  const Text(
                    'Filter Employees',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(child: _buildFilterContent()),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearFilters,
                      child: const Text('Clear All'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileBottomSheet(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: _buildFilterContent(),
      ),
    );
  }

  Widget _buildFilterContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gender Filter
          _buildFilterSection('Gender', [
            _buildFilterChip('Male', 'Male'),
            _buildFilterChip('Female', 'Female'),
          ]),

          // Education Level Filter
          _buildFilterSection('Education Level', [
            _buildFilterChip('ဝိဇ္ဇာ', 'ဝိဇ္ဇာ'),
            _buildFilterChip('သိပ္ပံ', 'သိပ္ပံ'),
            _buildFilterChip('အထက်တန်း', 'အထက်တန်း'),
            _buildFilterChip('အလယ်တန်း', 'အလယ်တန်း'),
            _buildFilterChip('မူလတန်း', 'မူလတန်း'),
            _buildFilterChip('စာရေးတတ်ဖတ်တတ်', 'စာရေးတတ်ဖတ်တတ်'),
          ]),

          // Branch Filter
          _buildFilterSection('Branch', [
            _buildFilterChip('ဟင်္သာတ', 'ဟင်္သာတ'),
            _buildFilterChip('ရေကြည်', 'ရေကြည်'),
            _buildFilterChip('မဲဇလီကုန်း', 'မဲဇလီကုန်း'),
            _buildFilterChip('ဥသျှစ်ပင်', 'ဥသျှစ်ပင်'),
            _buildFilterChip('မင်းဘူး', 'မင်းဘူး'),
            _buildFilterChip('သရက်', 'သရက်'),
          ]),

          // Salary Range Filter
          _buildFilterSection('Salary Range', [
            _buildFilterChip('308000-4000-328000', '308000-4000-328000'),
            _buildFilterChip('275000-4000-295000', '275000-4000-295000'),
            _buildFilterChip('234000-2000-224000', '234000-2000-224000'),
            _buildFilterChip('216000-2000-226000', '216000-2000-226000'),
            _buildFilterChip('198000-2000-208000', '198000-2000-208000'),
            _buildFilterChip('180000-2000-190000', '180000-2000-190000'),
            _buildFilterChip('162000-2000-172000', '162000-2000-172000'),
            _buildFilterChip('144000-2000-154000', '144000-2000-154000'),
          ]),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, List<Widget> chips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        Wrap(spacing: 8.0, runSpacing: 4.0, children: chips),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _currentFilters.selectedValues.contains(value);
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(fontSize: LayoutConstants.isDesktop ? 14 : 12),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _currentFilters.selectedValues.add(value);
          } else {
            _currentFilters.selectedValues.remove(value);
          }
        });
      },
    );
  }

  void _clearFilters() {
    setState(() {
      _currentFilters = FilterOptions();
    });
  }

  void _applyFilters() {
    widget.onApplyFilters(_currentFilters);
    Navigator.of(context).pop();
  }
}

// -----------------------------------------------------------------------------
// 4. FILTER OPTIONS MODEL (Unchanged)
// -----------------------------------------------------------------------------
class FilterOptions {
  Set<String> selectedValues;

  FilterOptions({Set<String>? selectedValues})
    : selectedValues = selectedValues ?? <String>{};

  FilterOptions copyWith({Set<String>? selectedValues}) {
    return FilterOptions(selectedValues: selectedValues ?? this.selectedValues);
  }

  bool get hasActiveFilters => selectedValues.isNotEmpty;

  bool matches(Employee employee) {
    if (selectedValues.isEmpty) return true;

    return selectedValues.any((value) {
      return employee.gender == value ||
          employee.educationLevel == value ||
          employee.assignedBranch == value ||
          employee.currentSalaryRange == value;
    });
  }
}

// -----------------------------------------------------------------------------
// 5. MAIN EMPLOYEE LIST SCREEN - RESPONSIVE
// -----------------------------------------------------------------------------
class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  List<Employee> _allEmployees = [];
  List<Employee> _filteredEmployees = [];
  final TextEditingController _searchController = TextEditingController();
  FilterOptions _currentFilters = FilterOptions();
  bool _isLoading = true;
  Directory? _imageDir;

  @override
  void initState() {
    super.initState();
    _getImageDir();
    _loadEmployees();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getImageDir() async {
    _imageDir = await getApplicationDocumentsDirectory();
    setState(() {});
  }

  Future<void> _loadEmployees() async {
    try {
      final employees = await DatabaseHelper.instance.getEmployees();
      setState(() {
        _allEmployees = employees;
        _filteredEmployees = employees;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to load employees: $e');
      // print(stackTrace);
    }
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    final searchTerm = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredEmployees = _allEmployees.where((employee) {
        final matchesSearch =
            searchTerm.isEmpty ||
            employee.fullName.toLowerCase().contains(searchTerm) ||
            employee.currentPosition?.toLowerCase().contains(searchTerm) ==
                true ||
            employee.assignedBranch?.toLowerCase().contains(searchTerm) ==
                true ||
            employee.educationDesc?.toLowerCase().contains(searchTerm) ==
                true ||
            employee.nrcNumber?.toLowerCase().contains(searchTerm) == true;

        final matchesFilters = _currentFilters.matches(employee);

        return matchesSearch && matchesFilters;
      }).toList();
    });
  }

  void _showFilterDialog() {
    if (LayoutConstants.isDesktop) {
      showDialog(
        context: context,
        builder: (context) => FilterBottomSheet(
          currentFilters: _currentFilters,
          onApplyFilters: (newFilters) {
            setState(() {
              _currentFilters = newFilters;
            });
            _applyFilters();
          },
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => FilterBottomSheet(
          currentFilters: _currentFilters,
          onApplyFilters: (newFilters) {
            setState(() {
              _currentFilters = newFilters;
            });
            _applyFilters();
          },
        ),
      );
    }
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _currentFilters = FilterOptions();
    });
    _applyFilters();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _navigateToEmployeeDetail(Employee employee) {
    String? path = _imageDir?.path;
    String imagePath = "$path/${employee.imagePath}";
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EmployeeDetailScreen(employee: employee, imagePath: imagePath),
      ),
    ).then((_) => _loadEmployees());
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText:
              'Search by name, position, branch, education Description or NRC...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              _applyFilters();
            },
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0)),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    if (!_currentFilters.hasActiveFilters && _searchController.text.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: [
          if (_searchController.text.isNotEmpty)
            Chip(
              label: Text('Search: ${_searchController.text}'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                _searchController.clear();
                _applyFilters();
              },
            ),
          ..._currentFilters.selectedValues.map(
            (value) => Chip(
              label: Text(value),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _currentFilters.selectedValues.remove(value);
                });
                _applyFilters();
              },
            ),
          ),
          if (_currentFilters.hasActiveFilters ||
              _searchController.text.isNotEmpty)
            ActionChip(
              label: const Text('Clear All'),
              onPressed: _clearAllFilters,
              backgroundColor: Colors.grey.shade300,
            ),
        ],
      ),
    );
  }

  Widget _buildEmployeeList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredEmployees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              _allEmployees.isEmpty
                  ? 'No employees found'
                  : 'No employees match your filters',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEmployees,
      child: ListView.builder(
        itemCount: _filteredEmployees.length,
        itemBuilder: (context, index) {
          final employee = _filteredEmployees[index];
          return EmployeeListItem(
            employee: employee,
            onTap: () => _navigateToEmployeeDetail(employee),
            onDelete: () async {
              await DatabaseHelper.instance.deleteEmployee(employee);
              setState(() {
                _filteredEmployees.removeAt(index);
              });
            },

            context: this.context,
            imageDir: _imageDir?.path,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_alt),
                if (_currentFilters.hasActiveFilters)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        _currentFilters.selectedValues.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          SizedBox(height: 8),
          Expanded(child: _buildEmployeeList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEmployeeScreen()),
          ).then((_) => _loadEmployees());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
