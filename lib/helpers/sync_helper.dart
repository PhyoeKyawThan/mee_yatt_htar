import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SyncHelper {
  static final SyncHelper instance = SyncHelper._privateConstructor();
  SyncHelper._privateConstructor();

  // Get local IP address
  static Future<String?> getLocalIpAddress() async {
    try {
      // For Android/iOS - get local IP from network interfaces
      final interfaces = await NetworkInterface.list();

      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          // Prefer IPv4 and non-loopback addresses
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            print(
              'Found local IP: ${addr.address} on interface: ${interface.name}',
            );
            return addr.address;
          }
        }
      }

      // Fallback: try to get IP from external service
      return await _getIpFromExternalService();
    } catch (e) {
      print('Error getting local IP: $e');
      return await _getIpFromExternalService();
    }
  }

  // Get IP from external service as fallback
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

  // Check if server is reachable
  static Future<bool> isServerReachable(String serverUrl) async {
    try {
      final response = await http
          .get(Uri.parse('$serverUrl/discover'))
          .timeout(Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (e) {
      print('Server not reachable: $e');
      return false;
    }
  }

  // Get network segment for local scanning
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

  // Scan local network for servers
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

  static Future<String?> _checkServerAtIp(String ip, int timeoutMs) async {
    try {
      final url = 'http://$ip:5000/discover';
      final response = await http
          .get(Uri.parse(url))
          .timeout(Duration(milliseconds: timeoutMs));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['server_name'] == 'Employee File Server') {
          print('Found server at: $ip');
          return 'http://$ip:5000';
        }
      }
    } catch (e) {
      // Ignore timeout and connection errors during scanning
    }
    return null;
  }

  // Test server connection with detailed info
  static Future<Map<String, dynamic>> testServerConnection(
    String serverUrl,
  ) async {
    try {
      final stopwatch = Stopwatch()..start();
      final response = await http
          .get(Uri.parse('$serverUrl/discover'))
          .timeout(Duration(seconds: 5));
      stopwatch.stop();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'serverUrl': serverUrl,
          'serverName': data['server_name'],
          'responseTime': '${stopwatch.elapsedMilliseconds}ms',
          'timestamp': DateTime.now().toIso8601String(),
        };
      } else {
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}',
          'serverUrl': serverUrl,
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString(), 'serverUrl': serverUrl};
    }
  }

  // Get network info summary
  static Future<Map<String, dynamic>> getNetworkInfo() async {
    final localIp = await getLocalIpAddress();
    final networkSegment = await getNetworkSegment();

    return {
      'localIp': localIp,
      'networkSegment': networkSegment,
      'timestamp': DateTime.now().toIso8601String(),
      'platform': Platform.operatingSystem,
    };
  }

  // Simple network availability check
  static Future<bool> hasNetworkConnection() async {
    try {
      // Try to connect to a reliable server
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get Wi-Fi SSID (Android only)
  static Future<String?> getWifiSsid() async {
    try {
      if (Platform.isAndroid) {
        // You would need the wifi_flutter package for this
        // For now, return null
        return null;
      }
    } catch (e) {
      print('Error getting WiFi SSID: $e');
    }
    return null;
  }
}
