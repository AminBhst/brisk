import 'package:brisk/download_engine/base_http_download_connection.dart';
import 'package:brisk/download_engine/http_client/base_http_client_wrapper.dart';
import 'package:brisk/download_engine/mock/mock_http_client.dart';
import 'package:http/src/client.dart';

/// A mock download connection used for the download engine development
class MockHttpDownloadConnection extends BaseHttpDownloadConnection {
  MockHttpDownloadConnection({
    required super.downloadItem,
    required super.startByte,
    required super.endByte,
    required super.connectionNumber,
    required super.settings,
  });

  @override
  BaseHttpClientWrapper buildClientWrapper() {
    final clientWrapper = MockHttpClient();
    clientWrapper.build();
    return clientWrapper;
  }
}
