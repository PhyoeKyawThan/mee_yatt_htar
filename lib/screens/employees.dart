import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mee_yatt_htar/helpers/database_helper.dart';
import 'package:mee_yatt_htar/helpers/employee.dart';
// import 'package:intl/intl.dart';
import 'package:mee_yatt_htar/screens/add_employee.dart';
import 'package:mee_yatt_htar/screens/edit_employee.dart';
import 'package:sqflite/sqflite.dart';

// -----------------------------------------------------------------------------
// 1. EMPLOYEE DETAIL SCREEN
// -----------------------------------------------------------------------------
class EmployeeDetailScreen extends StatelessWidget {
  final Employee employee;
  final Function()? onEmployeeUpdated;

  const EmployeeDetailScreen({
    super.key,
    required this.employee,
    this.onEmployeeUpdated,
  });

  Future<void> _refreshEmployeeData(BuildContext context) async {
    try {
      final updatedEmployee = await DatabaseHelper.instance.getEmployeeById(
        employee.id!,
      );

      if (updatedEmployee != null) {
        // Simply push a new instance of the same screen with updated data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmployeeDetailScreen(
              employee: updatedEmployee,
              onEmployeeUpdated: onEmployeeUpdated,
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
        builder: (context) => EditEmployeeScreen(employee: employee),
      ),
    ).then((result) {
      // Refresh if employee was updated
      if (result == true) {
        _refreshEmployeeData(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(employee.fullName),
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
      body: RefreshIndicator(
        onRefresh: () => _refreshEmployeeData(context),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              _buildProfileImage(),
              const SizedBox(height: 20),

              // Personal Information
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
              _buildInfoRow(
                'NRC Number',
                employee.nrcNumber ?? 'Not specified',
              ),
              _buildInfoRow(
                'Date of Birth',
                employee.dateOfBirth ?? 'Not specified',
              ),
              _buildInfoRow('Age', employee.age?.toString() ?? 'Not specified'),
              _buildInfoRow(
                'Education Level',
                employee.educationLevel ?? 'Not specified',
              ),
              _buildInfoRow(
                'Blood Type',
                employee.bloodType ?? 'Not specified',
              ),
              _buildInfoRow('Address', employee.address ?? 'Not specified'),

              const SizedBox(height: 20),

              // Employment Information
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
                'Salary Range',
                employee.currentSalaryRange ?? 'Not specified',
              ),
              _buildInfoRow(
                'Current Salary',
                employee.currentSalary ?? 'Not specified',
              ),

              const SizedBox(height: 20),

              // Training Courses
              if (employee.trainingCourses.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Training Courses'),
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
                    const SizedBox(height: 20),
                  ],
                ),

              // Remarks
              if (employee.remarks != null && employee.remarks!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Remarks'),
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
                ),

              // Add some extra space at the bottom for better pull-to-refresh
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: employee.imagePath != null
            ? FileImage(File(employee.imagePath!)) as ImageProvider
            : const AssetImage('assets/default_avatar.png'),
        child: employee.imagePath == null
            ? const Icon(Icons.person, size: 60, color: Colors.grey)
            : null,
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. EMPLOYEE LIST ITEM WIDGET
// -----------------------------------------------------------------------------

class EmployeeListItem extends StatelessWidget {
  final Employee employee;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const EmployeeListItem({
    super.key,
    required this.employee,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
                  Navigator.of(dialogContext).pop(); // Close the dialog
                },
              ),
              TextButton(
                // Use a distinct color for the delete action
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Close the dialog first
                  DatabaseHelper.instance.deleteEmployee(employee);
                  onDelete();
                },
              ),
            ],
          );
        },
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: employee.imagePath != null
              ? FileImage(File(employee.imagePath!)) as ImageProvider
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
}

// -----------------------------------------------------------------------------
// 3. FILTER BOTTOM SHEET
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
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Employees',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Gender Filter
          _buildFilterSection('Gender', [
            _buildFilterChip('Male', 'Male'),
            _buildFilterChip('Female', 'Female'),
          ]),

          // Education Level Filter
          _buildFilterSection('Education Level', [
            _buildFilterChip('High School', 'High School'),
            _buildFilterChip('Bachelor', 'Bachelor'),
            _buildFilterChip('Master', 'Master'),
            _buildFilterChip('PhD', 'PhD'),
          ]),

          // Branch Filter
          _buildFilterSection('Branch', [
            _buildFilterChip('Branch A', 'Branch A'),
            _buildFilterChip('Branch B', 'Branch B'),
            _buildFilterChip('Branch C', 'Branch C'),
          ]),

          // Salary Range Filter
          _buildFilterSection('Salary Range', [
            _buildFilterChip('100k-200k', '100k-200k'),
            _buildFilterChip('200k-400k', '200k-400k'),
            _buildFilterChip('400k-600k', '400k-600k'),
            _buildFilterChip('600k+', '600k+'),
          ]),

          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, List<Widget> chips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(spacing: 8.0, runSpacing: 4.0, children: chips),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _currentFilters.selectedValues.contains(value);
    return FilterChip(
      label: Text(label),
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
// 4. FILTER OPTIONS MODEL
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
// 5. MAIN EMPLOYEE LIST SCREEN
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

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    try {
      final employees = await DatabaseHelper.instance.getEmployees();
      setState(() {
        _allEmployees = employees;
        _filteredEmployees = employees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to load employees: $e');
    }
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    final searchTerm = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredEmployees = _allEmployees.where((employee) {
        // Apply search filter
        final matchesSearch =
            searchTerm.isEmpty ||
            employee.fullName.toLowerCase().contains(searchTerm) ||
            employee.currentPosition?.toLowerCase().contains(searchTerm) ==
                true ||
            employee.assignedBranch?.toLowerCase().contains(searchTerm) ==
                true ||
            employee.nrcNumber?.toLowerCase().contains(searchTerm) == true;

        // Apply other filters
        final matchesFilters = _currentFilters.matches(employee);

        return matchesSearch && matchesFilters;
      }).toList();
    });
  }

  void _showFilterBottomSheet() {
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeDetailScreen(employee: employee),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name, position, branch, or NRC...',
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
      // DatabaseHelper.instance.sampleInsert();
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _allEmployees.isEmpty
                  ? 'No employees found'
                  : 'No employees match your filters',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            // if (_allEmployees.isEmpty)
            //   TextButton(
            //     onPressed: () {
            //       // Navigate to add employee screen
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => const AddEmployeeScreen()),
            //         ),
            //       ).then((_) => _loadEmployees());
            //     },
            //     child: const Text('Add First Employee'),
            //   ),
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
            onDelete: () {
              setState(() {
                _filteredEmployees.removeAt(index);
              });
            },
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
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          const SizedBox(height: 8),
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
