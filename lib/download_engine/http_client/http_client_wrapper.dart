import 'package:brisk/download_engine/http_client/base_http_client_wrapper.dart';

class HttpClientWrapper extends BaseHttpClientWrapper {
  @override
  void close() {
    super.client.close();
  }
}
