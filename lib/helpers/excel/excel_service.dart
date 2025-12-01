import 'package:file_picker/file_picker.dart';
import 'package:mee_yatt_htar/helpers/assets.dart';
import 'package:mee_yatt_htar/helpers/employee.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ExcelExportService {
  // Available columns for export
  static final List<Map<String, dynamic>> availableColumns = [
    {'key': 'fullName', 'title': 'Full Name', 'selected': true},
    {'key': 'gender', 'title': 'Gender', 'selected': true},
    {'key': 'fatherName', 'title': 'Father Name', 'selected': true},
    {'key': 'motherName', 'title': 'Mother Name', 'selected': true},
    {'key': 'nrcNumber', 'title': 'NRC Number', 'selected': true},
    {'key': 'dateOfBirth', 'title': 'Date of Birth', 'selected': true},
    {'key': 'age', 'title': 'Age', 'selected': true},
    {'key': 'educationLevel', 'title': 'Education Level', 'selected': true},
    {
      'key': 'educationDesc',
      'title': 'Education Description',
      'selected': true,
    },
    {'key': 'bloodType', 'title': 'Blood Type', 'selected': true},
    {'key': 'address', 'title': 'Address', 'selected': true},
    {'key': 'assignedBranch', 'title': 'Assigned Branch', 'selected': true},
    {
      'key': 'firstAssignedPosition',
      'title': 'First Assigned Position',
      'selected': true,
    },
    {
      'key': 'firstAssignedDate',
      'title': 'First Assigned Date',
      'selected': true,
    },
    {'key': 'currentPosition', 'title': 'Current Position', 'selected': true},
    {
      'key': 'currentSalaryRange',
      'title': 'Current Salary Range',
      'selected': true,
    },
    {
      'key': 'currentPositionAssignDate',
      'title': 'Current Position Assign Date',
      'selected': true,
    },
    {'key': 'currentSalary', 'title': 'Current Salary', 'selected': true},
    {'key': 'trainingCourses', 'title': 'Training Courses', 'selected': true},
    {'key': 'remarks', 'title': 'Remarks', 'selected': true},
    {'key': 'createdAt', 'title': 'Created At', 'selected': false},
    {'key': 'updatedAt', 'title': 'Updated At', 'selected': false},
  ];

  // Replace your current export methods with these:

  // Export employees to Excel with selected columns
  static Future<ExportResult> exportToExcel({
    required List<Employee> employees,
    required List<Map<String, dynamic>> selectedColumns,
    String fileName = 'employee_data',
  }) async {
    try {
      // Check storage permission
      if (AppConstants.isMobile) {
        var status = await Permission.storage.request();
        var storage = await Permission.manageExternalStorage.request();
        if (!status.isGranted && !storage.isGranted) {
          return ExportResult(
            success: false,
            message: 'Storage permission required',
            filePath: null,
          );
        }
      }

      if (employees.isEmpty) {
        return ExportResult(
          success: false,
          message: 'No data to export',
          filePath: null,
        );
      }

      if (selectedColumns.isEmpty) {
        return ExportResult(
          success: false,
          message: 'Please select at least one column to export',
          filePath: null,
        );
      }

      // Create Excel workbook
      var excel = Excel.createExcel();
      var sheet = excel['Employee Data'];

      // Add headers
      List<TextCellValue> headers = selectedColumns
          .map((col) => TextCellValue(col['title'] as String))
          .toList();

      sheet.appendRow(headers);

      // Add data rows
      for (var employee in employees) {
        List<CellValue> rowData = [];

        for (var column in selectedColumns) {
          String key = column['key'];
          dynamic value = _getEmployeeValue(employee, key);
          rowData.add(TextCellValue(value.toString()));
        }

        sheet.appendRow(rowData);
      }

      // Set column widths
      _setColumnWidths(sheet, selectedColumns.length);

      // LET USER CHOOSE SAVE LOCATION
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select folder to save Excel file',
      );

      if (selectedDirectory == null) {
        return ExportResult(
          success: false,
          message: 'Export cancelled - no folder selected',
          filePath: null,
        );
      }

      final String fullFileName =
          '${fileName}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final String filePath = '$selectedDirectory/$fullFileName';

      // Get bytes and save
      final List<int>? fileBytes = excel.save();
      if (fileBytes == null) {
        return ExportResult(
          success: false,
          message: 'Failed to generate Excel file',
          filePath: null,
        );
      }

      final File file = File(filePath);
      await file.writeAsBytes(fileBytes, flush: true);

      return ExportResult(
        success: true,
        message:
            'Successfully exported ${employees.length} records to Excel\nLocation: $selectedDirectory',
        filePath: filePath,
        recordCount: employees.length,
        columnCount: selectedColumns.length,
      );
    } catch (e) {
      // print('Export error: $e');
      return ExportResult(
        success: false,
        message: 'Export failed: ${e.toString()}',
        filePath: null,
      );
    }
  }

  // Quick export with directory selection
  static Future<ExportResult> quickExport({
    required List<Employee> employees,
    String fileName = 'employee_data',
  }) async {
    final selectedColumns = availableColumns
        .where((col) => col['selected'] == true)
        .toList();
    return await exportToExcel(
      employees: employees,
      selectedColumns: selectedColumns,
      fileName: fileName,
    );
  }

  // CORRECTED: Set column widths properly
  static void _setColumnWidths(Sheet sheet, int columnCount) {
    try {
      for (int i = 0; i < columnCount; i++) {
        double width = 15.0; // Default width

        // Set different widths based on expected content
        if (i < availableColumns.length) {
          String columnKey = availableColumns[i]['key'];
          switch (columnKey) {
            case 'fullName':
            case 'address':
            case 'educationDesc':
            case 'trainingCourses':
            case 'remarks':
              width = 25.0; // Wider for long text
              break;
            case 'nrcNumber':
            case 'assignedBranch':
            case 'currentPosition':
            case 'currentSalaryRange':
            case 'firstAssignedPosition':
              width = 20.0; // Medium width
              break;
            case 'fatherName':
            case 'motherName':
            case 'educationLevel':
              width = 18.0; // Standard width
              break;
            case 'gender':
            case 'dateOfBirth':
            case 'age':
            case 'bloodType':
            case 'currentSalary':
            case 'firstAssignedDate':
            case 'currentPositionAssignDate':
              width = 12.0; // Narrower for short content
              break;
            case 'createdAt':
            case 'updatedAt':
              width = 15.0; // Date columns
              break;
            default:
              width = 15.0;
          }
        }

        // Set column width using the correct method
        // The Excel package uses this method for setting column widths
        sheet.setColumnWidth(i, width);
      }
    } catch (e) {
      // print('Column width setting error: $e');
      // Continue without column widths - file will still be created
    }
  }

  // Alternative implementation with individual cell assignment
  static Future<ExportResult> exportToExcelAlternative({
    required List<Employee> employees,
    required List<Map<String, dynamic>> selectedColumns,
    String fileName = 'employee_data',
  }) async {
    try {
      // Check storage permission
      if (AppConstants.isMobile) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          return ExportResult(
            success: false,
            message: 'Storage permission required',
            filePath: null,
          );
        }
      }

      if (employees.isEmpty) {
        return ExportResult(
          success: false,
          message: 'No data to export',
          filePath: null,
        );
      }

      if (selectedColumns.isEmpty) {
        return ExportResult(
          success: false,
          message: 'Please select at least one column to export',
          filePath: null,
        );
      }

      // Create Excel workbook
      var excel = Excel.createExcel();
      var sheet = excel['Employee Data'];

      // Add headers using individual cell assignment
      for (int colIndex = 0; colIndex < selectedColumns.length; colIndex++) {
        sheet
            .cell(CellIndex.indexByString("${_getColumnLetter(colIndex)}1"))
            .value = TextCellValue(
          selectedColumns[colIndex]['title'] as String,
        );
      }

      // Add data rows
      for (int rowIndex = 0; rowIndex < employees.length; rowIndex++) {
        var employee = employees[rowIndex];

        for (int colIndex = 0; colIndex < selectedColumns.length; colIndex++) {
          String key = selectedColumns[colIndex]['key'];
          dynamic value = _getEmployeeValue(employee, key);

          sheet
              .cell(
                CellIndex.indexByString(
                  "${_getColumnLetter(colIndex)}${rowIndex + 2}",
                ),
              )
              .value = TextCellValue(
            value.toString(),
          );
        }
      }

      // Set column widths
      _setColumnWidths(sheet, selectedColumns.length);

      // Save file
      final String fullFileName =
          '${fileName}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/$fullFileName';

      final List<int>? fileBytes = excel.save();
      if (fileBytes == null) {
        return ExportResult(
          success: false,
          message: 'Failed to generate Excel file',
          filePath: null,
        );
      }
      if (AppConstants.isDesktop) {
        String? filePath = await FilePicker.platform.saveFile(
          dialogTitle: "Please select a folder to save excel data.",
          fileName: fullFileName,
        );
        if (filePath != null) {
          final file = File(filePath);
          await file.writeAsBytes(fileBytes, flush: true);
        }
      } else {
        final File file = File(filePath);
        await file.writeAsBytes(fileBytes, flush: true);
      }
      return ExportResult(
        success: true,
        message:
            'Successfully exported ${employees.length} records to Excel\nFile: $fullFileName',
        filePath: filePath,
        recordCount: employees.length,
        columnCount: selectedColumns.length,
      );
    } catch (e) {
      // print('Export error: $e');
      return ExportResult(
        success: false,
        message: 'Export failed: ${e.toString()}',
        filePath: null,
      );
    }
  }

  // Helper to convert column index to Excel column letter (A, B, C, ...)
  static String _getColumnLetter(int index) {
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if (index < letters.length) {
      return letters[index];
    } else {
      // Handle columns beyond Z (AA, AB, etc.)
      final firstLetter = letters[(index ~/ letters.length) - 1];
      final secondLetter = letters[index % letters.length];
      return '$firstLetter$secondLetter';
    }
  }

  // // Quick export with default selected columns
  // static Future<ExportResult> quickExport({
  //   required List<Employee> employees,
  //   String fileName = 'employee_data',
  // }) async {
  //   final selectedColumns = availableColumns
  //       .where((col) => col['selected'] == true)
  //       .toList();
  //   return await exportToExcel(
  //     employees: employees,
  //     selectedColumns: selectedColumns,
  //     fileName: fileName,
  //   );
  // }

  // Helper function to get employee value by key
  static dynamic _getEmployeeValue(Employee employee, String key) {
    switch (key) {
      case 'fullName':
        return employee.fullName ?? '';
      case 'gender':
        return employee.gender ?? '';
      case 'fatherName':
        return employee.fatherName ?? '';
      case 'motherName':
        return employee.motherName ?? '';
      case 'nrcNumber':
        return employee.nrcNumber ?? '';
      case 'dateOfBirth':
        return employee.dateOfBirth ?? '';
      case 'age':
        return employee.age?.toString() ?? '';
      case 'educationLevel':
        return employee.educationLevel ?? '';
      case 'educationDesc':
        return employee.educationDesc ?? '';
      case 'bloodType':
        return employee.bloodType ?? '';
      case 'address':
        return employee.address ?? '';
      case 'assignedBranch':
        return employee.assignedBranch ?? '';
      case 'firstAssignedPosition':
        return employee.firstAssignedPosition ?? '';
      case 'firstAssignedDate':
        return employee.firstAssignedDate ?? '';
      case 'currentPosition':
        return employee.currentPosition ?? '';
      case 'currentSalaryRange':
        return employee.currentSalaryRange ?? '';
      case 'currentPositionAssignDate':
        return employee.currentPositionAssignDate ?? '';
      case 'currentSalary':
        return employee.currentSalary ?? '';
      case 'trainingCourses':
        if (employee.trainingCourses != null) {
          if (employee.trainingCourses is String) {
            return employee.trainingCourses;
          } else {
            return (employee.trainingCourses as List<dynamic>).join(', ');
          }
        }
        return '';
      case 'remarks':
        return employee.remarks ?? '';
      case 'createdAt':
        return employee.createdAt ?? '';
      case 'updatedAt':
        return employee.updatedAt ?? '';
      default:
        return '';
    }
  }

  // Get default selected columns
  static List<Map<String, dynamic>> getDefaultSelectedColumns() {
    return availableColumns.where((col) => col['selected'] == true).toList();
  }

  // Update column selection
  static void updateColumnSelection(List<Map<String, dynamic>> newSelection) {
    availableColumns.clear();
    availableColumns.addAll(newSelection);
  }

  // Reset to default selection
  static void resetToDefaultSelection() {
    for (var column in availableColumns) {
      column['selected'] = _getDefaultSelection(column['key']);
    }
  }

  static bool _getDefaultSelection(String key) {
    // Define which columns should be selected by default
    final defaultSelected = [
      'fullName',
      'gender',
      'nrcNumber',
      'dateOfBirth',
      'age',
      'educationLevel',
      'assignedBranch',
      'currentPosition',
      'currentSalary',
    ];
    return defaultSelected.contains(key);
  }
}

class ExportResult {
  final bool success;
  final String message;
  final String? filePath;
  final int? recordCount;
  final int? columnCount;

  ExportResult({
    required this.success,
    required this.message,
    this.filePath,
    this.recordCount,
    this.columnCount,
  });

  @override
  String toString() {
    return 'ExportResult(success: $success, message: $message, filePath: $filePath, recordCount: $recordCount, columnCount: $columnCount)';
  }
}
