import 'package:brisk/download_engine/base_http_download_connection.dart';
import 'package:brisk/download_engine/http_client/base_http_client_wrapper.dart';
import 'package:brisk/download_engine/http_client/http_client_wrapper.dart';
import 'package:http/src/client.dart';
import 'package:http/http.dart' as http;

class HttpDownloadConnection extends BaseHttpDownloadConnection {
  HttpDownloadConnection({
    required super.downloadItem,
    required super.startByte,
    required super.endByte,
    required super.connectionNumber,
    required super.settings,
  });

  @override
  BaseHttpClientWrapper buildClientWrapper() {
    return HttpClientWrapper();
  }
}
