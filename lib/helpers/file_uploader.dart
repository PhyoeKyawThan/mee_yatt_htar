import 'dart:io';
import 'dart:convert';
// import 'dart:nativewrappers/_internal/vm/bin/vmservice_io.dart';
import 'package:http/http.dart' as http;
import 'package:mee_yatt_htar/helpers/assets.dart';
import 'package:mee_yatt_htar/helpers/database_helper.dart';
import 'package:mee_yatt_htar/helpers/debug_notifier.dart';
import 'package:mee_yatt_htar/helpers/employee.dart';
// import 'package:mee_yatt_htar/helpers/assets.dart';
// import 'package:mee_yatt_htar/helpers/database_helper.dart';
import 'package:path/path.dart' as path; // For basename
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart'; // For MediaType

Future<void> uploadMultipleFiles(
  List<String> filePaths,
  Map<String, dynamic> jsonData,
  String? serverUrl,
) async {
  String baseServerURL = "$serverUrl";
  serverUrl = serverUrl != null
      ? "$serverUrl/make_sync"
      : "http://127.0.0.1:5000/make_sync";
  var uri = Uri.parse(serverUrl);
  var request = http.MultipartRequest("POST", uri);
  final dir = await getApplicationDocumentsDirectory();
  DebugNotifier.update("Preparing files");
  await Future.delayed(const Duration(seconds: 1));
  // --- Add multiple image or file uploads ---
  for (String filePath in filePaths) {
    File file = File("${dir.path}/$filePath");
    // print("Changes" + changes);
    if (await file.exists()) {
      var stream = http.ByteStream(file.openRead());
      var length = await file.length();
      var multipartFile = http.MultipartFile(
        'files[]', // backend expects this field
        stream,
        length,
        filename: path.basename(file.path),
      );
      request.files.add(multipartFile);
    } else {
      print("⚠️ File not found: $filePath");
    }
  }

  // --- Add JSON data (not file) ---
  // Send JSON as a text field or as its own multipart part
  var multipartJson = http.MultipartFile.fromString(
    'json_data', // backend key name
    jsonEncode(jsonData),
    filename: 'data.json',
    contentType: MediaType('application', 'json'),
  );
  request.files.add(multipartJson);

  try {
    DebugNotifier.update("Sending...");
    await Future.delayed(const Duration(seconds: 1));
    var response = await request.send();

    if (response.statusCode == 200) {
      DebugNotifier.update("Success");
      await Future.delayed(const Duration(seconds: 1));
      AppConstants.isMobile
          ? DatabaseHelper.instance.cleanChangesSqlite()
          : DatabaseHelper.instance.cleanChanges();
      var responseBody = await response.stream.bytesToString();
      var json = jsonDecode(responseBody);
      // if (!json['data_provided_from_android']) {
      if (json['has_changes']) {
        DebugNotifier.update("Server db has changes, applying..");
        await Future.delayed(const Duration(seconds: 1));
        for (var ch in json['changes']) {
          Employee emp = Employee.fromMap(ch['data']);
          DebugNotifier.update(
            "Apply(${ch['type']}): ${emp.fullName} - ${emp.currentPosition}",
          );
          await Future.delayed(const Duration(seconds: 1));
          if (ch['type'] == "update") {
            await downloadAndStoreFile(baseServerURL, "${emp.imagePath}");
            await DatabaseHelper.instance.updateEmployee(
              emp,
              is_sync_data: true,
            );
          }
          if (ch['type'] == "create") {
            final image = await downloadAndStoreFile(
              baseServerURL,
              "${emp.imagePath}",
            );
            if (image != null) {
              await DatabaseHelper.instance.insertEmployee(
                emp,
                is_sync_data: true,
              );
            }
          }
          if (ch['type'] == "delete") {
            await DatabaseHelper.instance.deleteEmployee(
              emp,
              is_sync_data: true,
            );
          }
          DebugNotifier.update("Employee(${emp.fullName}): Success");
          await Future.delayed(const Duration(seconds: 1));
        }
        // }
        DebugNotifier.update("Synced Successfully");
        await Future.delayed(const Duration(seconds: 1));
      }
    } else {
      var responseBody = await response.stream.bytesToString();
      var json = jsonDecode(responseBody);
      DebugNotifier.update(
        json['has_also_changes']
            ? "There is also nothing changes on server!"
            : "Server error",
      );
    }
  } catch (e, stackTrace) {
    DebugNotifier.update("Server error while uploading data");
    print(stackTrace);
  }
}

Future<File?> downloadAndStoreFile(String serverUrl, String filename) async {
  try {
    // Get application documents directory
    final dir = await getApplicationDocumentsDirectory();

    // Build local file path
    final filePath = path.join(dir.path, filename);
    final file = File(filePath);

    // 🔍 Check if file already exists
    if (await file.exists()) {
      // print('📂 File already exists at: $filePath');
      return file;
    }

    // Otherwise, download from the server
    final url = Uri.parse('$serverUrl/uploads/$filename');
    DebugNotifier.update("Downloading profile image...");
    // print('📥 Downloading from: $url');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Ensure directory exists
      DebugNotifier.update("Downloaded");
      await Directory(path.dirname(filePath)).create(recursive: true);

      // Write file bytes
      await file.writeAsBytes(response.bodyBytes);
      // print('✅ File downloaded and saved at: $filePath');

      return file;
    } else {
      print('❌ Failed to download file: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('⚠️ Error downloading file: $e');
    return null;
  }
}
