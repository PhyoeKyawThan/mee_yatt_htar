import 'dart:io';
import 'dart:convert';
// import 'dart:nativewrappers/_internal/vm/bin/vmservice_io.dart';
import 'package:http/http.dart' as http;
import 'package:mee_yatt_htar/helpers/assets.dart';
import 'package:mee_yatt_htar/helpers/database_helper.dart';
// import 'package:mee_yatt_htar/helpers/assets.dart';
// import 'package:mee_yatt_htar/helpers/database_helper.dart';
import 'package:path/path.dart'; // For basename
import 'package:http_parser/http_parser.dart';
import 'package:sqflite/sqflite.dart'; // For MediaType

Future<void> uploadMultipleFiles(
  List<String> filePaths,
  Map<String, dynamic> jsonData,
  String? serverUrl,
) async {
  serverUrl = serverUrl != null
      ? "$serverUrl/make_sync"
      : "http://127.0.0.1:5000/make_sync";
  var uri = Uri.parse(serverUrl);
  var request = http.MultipartRequest("POST", uri);

  // --- Add multiple image or file uploads ---
  for (String filePath in filePaths) {
    File file = File(filePath);
    // print("Changes" + changes);
    if (await file.exists()) {
      var stream = http.ByteStream(file.openRead());
      var length = await file.length();
      var multipartFile = http.MultipartFile(
        'files[]', // backend expects this field
        stream,
        length,
        filename: basename(file.path),
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
      print("Server response: $responseBody");
    } else {
      print("❌ Upload failed with status code: ${response.statusCode}");
      var responseBody = await response.stream.bytesToString();
      print("Server response: $responseBody");
    }
  } catch (e) {
    print("⚠️ Error uploading files: $e");
  }
}
