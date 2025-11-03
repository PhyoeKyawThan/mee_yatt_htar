// file_server.dart
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mime/mime.dart';
// import 'package:path/path.dart' as path;

class FileServer {
  HttpServer? _server;
  int _port = 8080;
  String? _documentDir;

  Future<String> getDocumentDirectory() async {
    if (_documentDir != null) return _documentDir!;

    final directory = await getApplicationDocumentsDirectory();
    _documentDir = directory.path;
    return _documentDir!;
  }

  Future<String?> start() async {
    try {
      if (_server != null) {
        await stop();
      }

      await getDocumentDirectory();

      final cascade = Cascade()
          .add(_imageHandler)
          .add(createStaticHandler(_documentDir!));

      _server = await shelf_io.serve(
        cascade.handler,
        InternetAddress.anyIPv4,
        _port,
      );

      final address = _server!.address;
      final port = _server!.port;

      print('Server running on http://${address.address}:$port');
      return 'http://${address.address}:$port';
    } catch (e) {
      print('Error starting server: $e');
      return null;
    }
  }

  Future<void> stop() async {
    if (_server != null) {
      await _server!.close();
      _server = null;
      print('Server stopped');
    }
  }

  Response _imageHandler(Request request) {
    // Check if this is an image request
    if (!request.requestedUri.path.startsWith('/image/')) {
      return Response.notFound('Not Found');
    }

    final filename = request.requestedUri.path.substring('/image/'.length);
    if (filename.isEmpty) {
      return Response.notFound('Filename required');
    }

    final file = File('$_documentDir/$filename');
    if (!file.existsSync()) {
      return Response.notFound('Image not found');
    }

    // Get file info
    final stat = file.statSync();
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

    // Check if download is requested
    final shouldDownload =
        request.requestedUri.queryParameters['download'] == 'true';

    final headers = <String, String>{
      'Content-Type': mimeType,
      'Content-Length': stat.size.toString(),
      'Last-Modified': HttpDate.format(stat.modified),
    };

    if (shouldDownload) {
      headers['Content-Disposition'] = 'attachment; filename="$filename"';
    } else {
      headers['Content-Disposition'] = 'inline; filename="$filename"';
    }

    // Add CORS headers to allow access from other domains
    headers['Access-Control-Allow-Origin'] = '*';
    headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS';
    headers['Access-Control-Allow-Headers'] = 'Content-Type';

    // Handle OPTIONS request for CORS preflight
    if (request.method == 'OPTIONS') {
      return Response.ok('', headers: headers);
    }

    return Response.ok(file.readAsBytesSync(), headers: headers);
  }

  bool get isRunning => _server != null;

  String? get serverUrl {
    if (_server == null) return null;
    return 'http://${_server!.address.address}:${_server!.port}';
  }
}
