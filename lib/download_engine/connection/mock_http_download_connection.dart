import 'package:brisk/download_engine/connection/base_http_download_connection.dart';
import 'package:brisk/download_engine/client/mock_http_client_proxy.dart';
import 'package:http/src/client.dart';

/// A mock implementation used for the download engine development
class MockHttpDownloadConnection extends BaseHttpDownloadConnection {
  MockHttpDownloadConnection({
    required super.downloadItem,
    required super.startByte,
    required super.endByte,
    required super.connectionNumber,
    required super.settings,
  });

  @override
  Client buildClient() {
    return MockHttpClientProxy.build();
  }
}
