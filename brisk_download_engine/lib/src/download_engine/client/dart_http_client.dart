import 'dart:convert';
import 'dart:typed_data';

import 'package:brisk_download_engine/src/download_engine/client/custom_base_client.dart';
import 'package:http/http.dart';

class DartHttpClient extends CustomBaseClient {
  Client client;

  DartHttpClient(this.client);

  @override
  void close() {
    client.close();
  }

  @override
  Future<void> cancelRequest() async {
    close();
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return client.send(request);
  }

  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) {
    return client.get(url, headers: headers);
  }

  @override
  Future<Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return client.post(url, headers: headers, body: body, encoding: encoding);
  }

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) {
    return client.head(url, headers: headers);
  }

  @override
  Future<Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return client.put(url, headers: headers, body: body, encoding: encoding);
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) {
    return client.readBytes(url, headers: headers);
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) {
    return client.read(url, headers: headers);
  }
}
