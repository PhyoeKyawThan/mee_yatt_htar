import 'package:flutter/material.dart';
import 'package:mee_yatt_htar/helpers/sync_helper.dart';

// Example usage in a widget
class NetworkInfoWidget extends StatefulWidget {
  @override
  _NetworkInfoWidgetState createState() => _NetworkInfoWidgetState();
}

class _NetworkInfoWidgetState extends State<NetworkInfoWidget> {
  String? localIp;
  bool isScanning = false;
  List<String> servers = [];

  @override
  void initState() {
    super.initState();
    _loadNetworkInfo();
  }

  Future<void> _loadNetworkInfo() async {
    final ip = await SyncHelper.getLocalIpAddress();
    setState(() {
      localIp = ip;
    });
  }

  Future<void> _scanNetwork() async {
    setState(() {
      isScanning = true;
      servers.clear();
    });

    final foundServers = await SyncHelper.scanLocalNetwork();

    setState(() {
      servers = foundServers;
      isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(Icons.network_check),
          title: Text('Local IP Address'),
          subtitle: Text(localIp ?? 'Unknown'),
          trailing: IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadNetworkInfo,
          ),
        ),

        ListTile(
          leading: Icon(Icons.search),
          title: Text('Network Scan'),
          subtitle: isScanning
              ? Text('Scanning for servers...')
              : Text('Found ${servers.length} servers'),
          trailing: isScanning
              ? CircularProgressIndicator()
              : IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: _scanNetwork,
                ),
        ),

        if (servers.isNotEmpty) ...[
          Padding(padding: EdgeInsets.all(16), child: Text('Found Servers:')),
          ...servers
              .map(
                (server) => ListTile(
                  leading: Icon(Icons.computer, color: Colors.green),
                  title: Text(server),
                  onTap: () {
                    // Connect to this server
                  },
                ),
              )
              .toList(),
        ],
      ],
    );
  }
}
