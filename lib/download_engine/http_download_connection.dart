import 'package:brisk/download_engine/base_http_download_connection.dart';
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
  http.Client buildClient() {
    return http.Client();
  }
}
