import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mee_yatt_htar/helpers/change_tracker.dart';
import 'package:mee_yatt_htar/helpers/database_helper.dart';

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
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            print(
              'Found local IP: ${addr.address} on interface: ${interface.name}',
            );
            return addr.address;
          }
        }
      }

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
  static Future<void> sendJsonToServer(
    String? serverUrl,
    // Map<String, dynamic> jsonData,
  ) async {
    try {
      List<Map<String, dynamic>> changes = await ChangeTracker.readAll();
      Map<String, dynamic> jsonData = {
        "device": Platform.isAndroid
            ? "android"
            : (Platform.isWindows ? "window" : "Linux"),
        "changes": changes,
      };
      final response = await http.post(
        Uri.parse('$serverUrl/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(jsonData),
      );

      print('➡️ Sending data to $serverUrl/sync ...');
      print('📦 Payload: ${jsonEncode(jsonData)}');

      if (response.statusCode == 200) {
        print('✅ Server Response: ${response.body}');
      } else {
        print(
          '⚠️ Server responded with ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Failed to send JSON data: $e');
    }
  }
}
