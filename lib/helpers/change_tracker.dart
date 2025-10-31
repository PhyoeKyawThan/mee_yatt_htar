import 'dart:convert';
import 'dart:io';

import 'package:mee_yatt_htar/helpers/assets.dart';

class ChangeTracker {
  static const String _path = "assets/sync/track.json";

  static Future<List<Map<String, dynamic>>> readAll() async {
    try {
      final file = File(_path);

      if (!await file.exists()) {
        await file.create(recursive: true);
        await file.writeAsString(
          jsonEncode({
            "device": AppConstants.isMobile ? "mobile" : "desktop",
            "changes": [],
          }),
        );
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonData = jsonDecode(contents);
      return List<Map<String, dynamic>>.from(jsonData);
    } catch (e) {
      // print("Error reading file: $e");
      return [];
    }
  }

  static Future<void> _writeAll(List<Map<String, dynamic>> data) async {
    final file = File(_path);
    await file.writeAsString(jsonEncode(data), flush: true);
  }

  static Future<void> create(Map<String, dynamic> newItem) async {
    final records = await readAll();
    records.add(newItem);
    await _writeAll(records);
  }

  static Future<Map<String, dynamic>?> read(int index) async {
    final records = await readAll();
    if (index < 0 || index >= records.length) return null;
    return records[index];
  }

  static Future<void> update(
    int index,
    Map<String, dynamic> updatedItem,
  ) async {
    final records = await readAll();
    if (index < 0 || index >= records.length) return;
    records[index] = updatedItem;
    await _writeAll(records);
  }

  static Future<void> delete(int index) async {
    final records = await readAll();
    if (index < 0 || index >= records.length) return;
    records.removeAt(index);
    await _writeAll(records);
  }

  static Future<void> clear() async {
    await _writeAll([]);
  }
}
