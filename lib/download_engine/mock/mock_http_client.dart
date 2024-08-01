import 'dart:async';
import 'dart:io';
import 'dart:math';
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

class MockHttpClient {

  static MockClient build() {
    return MockClient.streaming((request, bodyStream) => _handler(request));
  }

  static Future<http.StreamedResponse> _handler(
    http.BaseRequest request,
  ) async {
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

    final length = segment.endByte - segment.startByte + 1;
    final bytes = fileBytes.sublist(segment.startByte, segment.endByte);
    final byteStream = _mockDownloadStream(bytes);

    final headers = {
      'Range': 'bytes=${segment.startByte}-${segment.endByte}',
      'Content-Length': length.toString(),
    };


    return http.StreamedResponse(
      byteStream,
      206,
      headers: headers,
    );

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

  static Stream<List<int>> _mockDownloadStream(List<int> bytes) async* {
    final random = Random();
    final chunkSize = 8191; // Number of bytes to emit at a time
    for (int i = 0; i < bytes.length; i += chunkSize) {
      final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
      yield bytes.sublist(i, end);
      // Simulate a random delay
      final delay = Duration(
        milliseconds: 100,
      ); // Random delay between 0 and 500 ms
      await Future.delayed(delay);
    }
  }


  // static Future<List<int>> _mockDownloadStream(List<int> bytes) async {
  //   final random = Random();
  //   final chunkSize = 8191; // Number of bytes to emit at a time
  //   final completer = Completer();
  //   for (int i = 0; i < bytes.length; i += chunkSize) {
  //     final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
  //     final byteList = bytes.sublist(i, end);
  //     // Simulate a random delay
  //     final delay = Duration(
  //       milliseconds: 100,
  //     ); // Random delay between 0 and 500 ms
  //     await Future.delayed(delay);
  //     return completer.complete(byteList);
  //   }
  // }

}

// void main() async {
//   final client = MockHttpClient(testFilePath);
//   // Example: Requesting the byte range 0-99
//   final request = http.Request('GET', Uri.parse('http://example.com'))
//     ..headers['Range'] = 'bytes=0-65945577';
//
//   final response = await client.send(request);
//
//   print(response.headers);
//   await for (final bytes in response.stream) {
//     print(bytes); // Print or process the bytes from the specified range
//   }
// }
