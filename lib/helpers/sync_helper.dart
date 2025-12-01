import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mee_yatt_htar/helpers/assets.dart';
// import 'package:mee_yatt_htar/helpers/change_tracker.dart';
import 'package:mee_yatt_htar/helpers/database_helper.dart';
import 'package:mee_yatt_htar/helpers/debug_notifier.dart';
import 'package:mee_yatt_htar/helpers/file_uploader.dart';
// import 'package:sqflite/sqlite_api.dart';

class SyncHelper {
  static final SyncHelper instance = SyncHelper._privateConstructor();
  SyncHelper._privateConstructor();

  // =============================
  // Get local IP address
  // =============================
  static Future<String?> getLocalIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list();

      for (var interface in interfaces) {
        // Only consider Wi-Fi interface
        if (interface.name != 'wlan0') continue;

        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            print(
              'Found local IP: ${addr.address} on interface: ${interface.name}',
            );
            return addr.address;
          }
        }
      }

      // fallback
      return await _getIpFromExternalService();
    } catch (e) {
      print('Error getting local IP: $e');
      return await _getIpFromExternalService();
    }
  }

  // =============================
  // Get external IP (fallback)
  // =============================
  static Future<String?> _getIpFromExternalService() async {
    try {
      final response = await http
          .get(Uri.parse('https://api.ipify.org'))
          .timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      print('Error getting IP from external service: $e');
    }
    return null;
  }

  // =============================
  // Check if server is reachable
  // =============================
  static Future<bool> isServerReachable(String serverUrl) async {
    try {
      final response = await http
          .get(Uri.parse('$serverUrl/'))
          .timeout(Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (e) {
      print('Server not reachable: $e');
      return false;
    }
  }

  // =============================
  // Get network segment
  // =============================
  static Future<String?> getNetworkSegment() async {
    try {
      final localIp = await getLocalIpAddress();
      if (localIp != null) {
        final parts = localIp.split('.');
        if (parts.length == 4) {
          return '${parts[0]}.${parts[1]}.${parts[2]}';
        }
      }
    } catch (e) {
      print('Error getting network segment: $e');
    }
    return null;
  }

  // =============================
  // Scan local network for servers
  // =============================
  static Future<List<String>> scanLocalNetwork({int timeoutMs = 500}) async {
    final List<String> foundServers = [];
    final networkSegment = await getNetworkSegment();

    if (networkSegment == null) {
      return foundServers;
    }

    print('Scanning network segment: $networkSegment.xxx');

    final tasks = <Future>[];

    for (int i = 1; i <= 254; i++) {
      final ip = '$networkSegment.$i';
      tasks.add(
        _checkServerAtIp(ip, timeoutMs).then((serverUrl) {
          if (serverUrl != null) {
            foundServers.add(serverUrl);
          }
        }),
      );
    }

    await Future.wait(tasks, eagerError: false);
    return foundServers;
  }

  // =============================
  // Internal: Check server
  // =============================
  static Future<String?> _checkServerAtIp(String ip, int timeoutMs) async {
    try {
      final url = 'http://$ip:5000/';
      final response = await http
          .get(Uri.parse(url))
          .timeout(Duration(milliseconds: timeoutMs));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["acknowledgement"] == "open_sesame") {
          final serverUrl = data["url"] ?? 'http://$ip:5000';
          print('✅ Found Python Sync Server at: $serverUrl');
          return serverUrl;
        }
      }
    } catch (e) {
      // Ignore connection errors
    }
    return null;
  }

  static Future<String?> getPythonSyncServer() async {
    print('🔍 Searching for Python Sync Server...');
    final servers = await scanLocalNetwork(timeoutMs: 1000);
    if (servers.isEmpty) {
      print('❌ No Python server found on the local network.');
      return null;
    }

    // Optional: verify which one is reachable
    for (final server in servers) {
      if (await isServerReachable(server)) {
        print('🌐 Using sync server: $server');
        return server;
      }
    }

    print('❌ No reachable server responded.');
    return null;
  }

  // =============================
  // NEW METHOD: Send JSON to Server
  // =============================
  static Future<void> sendJsonToServer(String? serverUrl) async {
    // try {
    DebugNotifier.update("Checking changes");
    await Future.delayed(const Duration(seconds: 1));
    List<Map<String, dynamic>> changes = AppConstants.isMobile
        ? await DatabaseHelper.instance.getChangeSqlite()
        : await DatabaseHelper.instance.getChanges();
    ;
    Map<String, dynamic> jsonData = {
      "device": Platform.isAndroid
          ? "android"
          : (Platform.isWindows ? "Window" : "Linux"),
      "changes": changes,
    };
    DebugNotifier.update(
      changes.isNotEmpty ? "Found changes" : "Noting change",
    );
    await Future.delayed(const Duration(seconds: 1));
    List<String> images = [];
    for (var e in changes) {
      if (e['type'] != null) {
        images.add(e['data']['imagePath']);
      }
    }
    await uploadMultipleFiles(images, jsonData, serverUrl);
  }
}
