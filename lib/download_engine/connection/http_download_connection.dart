import 'package:brisk/constants/types.dart';
import 'package:brisk/download_engine/connection/base_http_download_connection.dart';
import 'package:http/http.dart' as http;

import '../download_status.dart';

class HttpDownloadConnection extends BaseHttpDownloadConnection {
  HttpDownloadConnection({
    required super.downloadItem,
    required super.segment,
    required super.connectionNumber,
    required super.settings,
  });

  @override
  http.Client buildClient() {
    return http.Client();
  }

}
