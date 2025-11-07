// import 'package:flutter/material.dart';
// import 'package:mee_yatt_htar/helpers/excel/excel_service.dart';

// Future<void> _showColumnSelectionDialog(BuildContext context) async {
//   List<Map<String, dynamic>> selectedColumns = List.from(
//     ExcelExportService.availableColumns,
//   );

//   await showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return StatefulBuilder(
//         builder: (context, setState) {
//           return AlertDialog(
//             title: const Text('Select Columns to Export'),
//             content: SizedBox(
//               width: double.maxFinite,
//               child: ListView(
//                 shrinkWrap: true,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       TextButton(
//                         onPressed: () {
//                           setState(() {
//                             for (var column in selectedColumns) {
//                               column['selected'] = true;
//                             }
//                           });
//                         },
//                         child: const Text('Select All'),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           setState(() {
//                             for (var column in selectedColumns) {
//                               column['selected'] = false;
//                             }
//                           });
//                         },
//                         child: const Text('Deselect All'),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           setState(() {
//                             ExcelExportService.resetToDefaultSelection();
//                             selectedColumns = List.from(
//                               ExcelExportService.availableColumns,
//                             );
//                           });
//                         },
//                         child: const Text('Reset to Default'),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   ...selectedColumns.map((column) {
//                     return CheckboxListTile(
//                       title: Text(column['title']),
//                       value: column['selected'],
//                       onChanged: (bool? value) {
//                         setState(() {
//                           column['selected'] = value ?? false;
//                         });
//                       },
//                     );
//                   }).toList(),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   ExcelExportService.updateColumnSelection(selectedColumns);
//                   Navigator.of(context).pop();
//                   _exportToExcelWithSelectedColumns();
//                 },
//                 child: const Text('Export'),
//               ),
//             ],
//           );
//         },
//       );
//     },
//   );
// }
