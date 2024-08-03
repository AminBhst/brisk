import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:path/path.dart' as path;
import 'package:brisk/download_engine/segment.dart';

const mockDownloadUrl = 'http://brisk.mock';

String testFilePath = path.join(
  Directory.current.path,
  "assets/test",
  "Mozilla.Firefox.zip",
);

class MockHttpClientProxy implements BaseClient {
  late Client client;

  bool _closed = false;

  MockHttpClientProxy();

  void build() {
    this.client = MockClient.streaming(_handleRequest);
  }

  Future<StreamedResponse> _handleRequest(
    BaseRequest request,
    ByteStream bodyStream,
  ) async {
    final file = File(testFilePath);
    if (!file.existsSync()) {
      // return http.Response('File not found', 404);
    }
    final fileBytes = file.readAsBytesSync();
    final totalLength = fileBytes.length;
    final rangeHeader = request.headers['Range']!;
    final segment = _parseRangeHeader(rangeHeader, totalLength);
    final bytes = fileBytes.sublist(segment.startByte, segment.endByte);
    final byteStream = _mockDownloadStream(bytes);
    return StreamedResponse(byteStream, 206);
  }

  static Segment _parseRangeHeader(String rangeHeader, int totalLength) {
    final match = RegExp(r'bytes=(\d*)-(\d*)').firstMatch(rangeHeader)!;
    final startStr = match.group(1);
    final endStr = match.group(2);
    int start = int.parse(startStr!);
    int end = int.parse(endStr!);
    return Segment(start, end);
  }

  /// Yields the file bytes in a randomly delayed fashion, simulating how a real
  /// download stream works
  Stream<List<int>> _mockDownloadStream(List<int> bytes) async* {
    final random = Random();
    final chunkSize = 12001;
    for (int i = 0; i < bytes.length; i += chunkSize) {
      print("THIS.CLOSED : ${this._closed}");
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

  @override
  Future<Response> delete(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return client.delete(url, headers: headers, body: body, encoding: encoding);
  }

  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) {
    return client.get(url, headers: headers);
  }

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) {
    return client.head(url, headers: headers);
  }

  @override
  Future<Response> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return client.patch(url, headers: headers, body: body, encoding: encoding);
  }

  @override
  Future<Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return client.post(url, headers: headers, body: body, encoding: encoding);
  }

  @override
  Future<Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return client.put(url, headers: headers, body: body, encoding: encoding);
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) {
    return client.read(url, headers: headers);
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) {
    return client.readBytes(url, headers: headers);
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return client.send(request);
  }
}
