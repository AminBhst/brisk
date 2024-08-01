import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:brisk/download_engine/http_client/base_http_client_wrapper.dart';
import 'package:brisk/download_engine/segment.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as path;

const mockDownloadUrl = 'http://brisk.mock';

String testFilePath = path.join(
  Directory.current.path,
  "assets/test",
  "Mozilla.Firefox.zip",
);

/// A mock client that behaves like a server and serves a local file in a streaming
/// fashion. Used for the development of the download engine.
class MockHttpClient extends BaseHttpClientWrapper {
  bool _closed = false;

  MockClient build() {
    super.client = MockClient.streaming(
      (request, _) => _handleRequest(request),
    );
    return super.client as MockClient;
  }

  Future<http.StreamedResponse> _handleRequest(http.BaseRequest request) async {
    final file = File(testFilePath);
    if (!file.existsSync()) {
      // return http.Response('File not found', 404);
    }

    final fileBytes = file.readAsBytesSync();
    final totalLength = fileBytes.length;
    final rangeHeader = request.headers['range']!;

    if (rangeHeader == null) {
      // return http.Response.bytes(fileBytes, 200,
      //     headers: {'Content-Length': totalLength.toString()});
    }

    final segment = _parseRangeHeader(rangeHeader, totalLength)!;
    if (segment == null) {
      // return http.Response('Invalid Range', 416);
    }

    final bytes = fileBytes.sublist(segment.startByte, segment.endByte);
    final byteStream = _mockDownloadStream(bytes);
    return http.StreamedResponse(byteStream, 206);
  }

  static Segment? _parseRangeHeader(String rangeHeader, int totalLength) {
    final match = RegExp(r'bytes=(\d*)-(\d*)').firstMatch(rangeHeader);
    if (match == null) {
      return null;
    }

    final startStr = match.group(1);
    final endStr = match.group(2);

    int start;
    int end;

    if (startStr != null && startStr.isNotEmpty) {
      start = int.parse(startStr);
    } else {
      start = 0;
    }

    if (endStr != null && endStr.isNotEmpty) {
      end = int.parse(endStr);
    } else {
      end = totalLength - 1;
    }

    if (start > end || start < 0 || end - 1 >= totalLength) {
      return null;
    }

    return Segment(start, end);
  }

  /// Yields the file bytes in a random delayed fashion, simulating how a real
  /// download stream works
  Stream<List<int>> _mockDownloadStream(List<int> bytes) async* {
    final random = Random();
    final chunkSize = 12000;
    for (int i = 0; i < bytes.length; i += chunkSize) {
      if (this._closed) {
        break;
      }
      final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
      yield bytes.sublist(i, end);
      final rand = random.nextInt(500);
      if (rand % 3 != 0 || rand % 2 != 0) continue;
      final delay = Duration(milliseconds: 100);
      await Future.delayed(delay);
    }
    yield [];
  }

  @override
  void close() {
    this._closed = true;
  }
}

// void main() async {
//   // final client = MockHttpClient.build();
//   // Example: Requesting the byte range 0-99
//   final request = http.Request('GET', Uri.parse('http://example.com'))
//     ..headers['Range'] = 'bytes=0-65945577';
//   final response = await client.send(request);
//   await for (final bytes in response.stream) {
//     print(bytes); // Print or process the bytes from the specified range
//     client.close();
//   }
// }
