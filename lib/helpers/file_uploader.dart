import 'dart:io';
import 'dart:convert';
// import 'dart:nativewrappers/_internal/vm/bin/vmservice_io.dart';
import 'package:http/http.dart' as http;
import 'package:mee_yatt_htar/helpers/assets.dart';
import 'package:mee_yatt_htar/helpers/database_helper.dart';
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
    var response = await request.send();

    if (response.statusCode == 200) {
      print("✅ Upload successful!");
      AppConstants.isMobile
          ? DatabaseHelper.instance.cleanChangesSqlite()
          : DatabaseHelper.instance.cleanChanges();
      var responseBody = await response.stream.bytesToString();
      var json = jsonDecode(responseBody);
      // if (!json['data_provided_from_android']) {
      if (json['has_changes'] || json['has_also_changes']) {
        for (var ch in json['changes']) {
          Employee emp = Employee.fromMap(ch['data']);
          if (ch['type'] == "update") {
            await downloadAndStoreFile(baseServerURL, "${emp.imagePath}");
            await DatabaseHelper.instance.updateEmployee(emp);
          }
          if (ch['type'] == "create") {
            final image = await downloadAndStoreFile(
              baseServerURL,
              "${emp.imagePath}",
            );
            if (image != null) {
              await DatabaseHelper.instance.insertEmployee(emp);
            }
          }
          if (ch['type'] == "delete") {
            await DatabaseHelper.instance.deleteEmployee(emp);
          }
        }
        // }
      }
    } else {
      var responseBody = await response.stream.bytesToString();
      print("Server response: $responseBody");
    }
  } catch (e) {
    print("⚠️ Error uploading files: $e");
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
    // print('📥 Downloading from: $url');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Ensure directory exists
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
