import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class NetworkDiscovery {
  static const int discoveryPort = 8888;
  static const String serverType = 'FILE_SERVER_DISCOVERY';

  static Future<String?> discoverServer({int timeoutSeconds = 5}) async {
    try {
      final RawDatagramSocket socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        discoveryPort,
      );
      socket.broadcastEnabled = true;

      // Send discovery broadcast
      final discoveryMessage = jsonEncode({
        'type': 'CLIENT_DISCOVERY',
        'client': 'flutter_app',
      });

      socket.send(
        discoveryMessage.codeUnits,
        InternetAddress('255.255.255.255'),
        discoveryPort,
      );

      // Listen for responses
      final Completer<String?> completer = Completer();
      final timer = Timer(Duration(seconds: timeoutSeconds), () {
        socket.close();
        if (!completer.isCompleted) completer.complete(null);
      });

      socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final Datagram? datagram = socket.receive();
          if (datagram != null) {
            try {
              final message = jsonDecode(String.fromCharCodes(datagram.data));
              if (message['type'] == serverType) {
                final serverIp = datagram.address.address;
                final serverPort = message['port'] ?? 5000;
                socket.close();
                timer.cancel();
                completer.complete('http://$serverIp:$serverPort');
                print("complete : $serverIp:$serverPort");
              }
            } catch (e) {
              print('Error parsing discovery response: $e');
            }
          }
        }
      });

      return completer.future;
    } catch (e) {
      print('Discovery error: $e');
      return null;
    }
  }

  static Future<String?> findServerByScanning() async {
    try {
      // Get local IP address
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            final baseIp = addr.address.substring(
              0,
              addr.address.lastIndexOf('.'),
            );

            // Scan common IP ranges
            for (int i = 1; i <= 254; i++) {
              final testIp = '$baseIp.$i';
              final url = 'http://$testIp:5000/discover';

              try {
                final response = await http
                    .get(Uri.parse(url))
                    .timeout(Duration(milliseconds: 500));

                if (response.statusCode == 200) {
                  final data = jsonDecode(response.body);
                  if (data['server_name'] == 'Employee File Server') {
                    return 'http://$testIp:5000';
                  }
                }
              } catch (e) {
                // Continue scanning
              }
            }
          }
        }
      }
    } catch (e) {
      print('Scanning error: $e');
    }
    return null;
  }
}
