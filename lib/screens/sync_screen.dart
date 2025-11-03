import 'package:flutter/material.dart';
// import 'package:mee_yatt_htar/helpers/assets.dart';
// import 'package:mee_yatt_htar/helpers/file_server.dart';
// import 'package:mee_yatt_htar/helpers/file_uploader.dart';
import 'package:mee_yatt_htar/helpers/sync_helper.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreen();
}

class _SyncScreen extends State<SyncScreen> {
  String _syncText = "This is default sync text";
  Future<void> _handleSync() async {
    // FileServer fs = FileServer();
    // String? fileServerURL = await fs.start();
    String? address = await SyncHelper.getPythonSyncServer();
    await SyncHelper.sendJsonToServer(address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_syncText),
            SizedBox(height: 20),
            TextButton(
              onPressed: _handleSync,
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 175, 215, 235),
                // foregroundColor: Colors.white,
              ),
              child: Text(
                "Sync",
                style: TextStyle(color: const Color.fromARGB(255, 3, 17, 0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
