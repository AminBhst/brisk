import 'dart:io';

import 'package:brisk/setting/proxy/proxy_setting.dart';
import 'package:dartx/dartx.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

class HttpClientBuilder {
  static Client buildClient(ProxySetting? proxySetting) {
    if (proxySetting == null || !proxySetting.proxyEnabled) {
      return Client();
    }
    final proxyAddress =
        "${proxySetting.proxyAddress}:${proxySetting.proxyPort}";
    final httpClient = HttpClient()
      ..findProxy = (uri) {
        return "PROXY $proxyAddress";
      };
    if (proxySetting.username != null && proxySetting.username!.isNotBlank) {
      httpClient.addProxyCredentials(
        proxySetting.proxyAddress,
        int.parse(proxySetting.proxyPort),
        '',
        HttpClientBasicCredentials(
          proxySetting.username!,
          proxySetting.password ?? "",
        ),
      );
    }
    return IOClient(httpClient);
  }
}
