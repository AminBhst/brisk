import 'dart:io';

import 'package:brisk_download_engine/src/download_engine/client/http_client_settings.dart';
import 'package:brisk_download_engine/src/download_engine/client/client_type.dart';
import 'package:brisk_download_engine/src/download_engine/client/custom_base_client.dart';
import 'package:brisk_download_engine/src/download_engine/client/dart_http_client.dart';
import 'package:brisk_download_engine/src/download_engine/client/rhttp_client_proxy.dart';
import 'package:brisk_download_engine/src/download_engine/setting/proxy_setting.dart';
import 'package:dartx/dartx.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:rhttp/rhttp.dart';

class HttpClientBuilder {
  static bool _rhttpInitialized = false;

  static Future<CustomBaseClient> buildClient([
    HttpClientSettings? clientSettings,
  ]) async {
    final proxySetting = clientSettings?.proxySetting;
    final clientType = clientSettings?.clientType ?? ClientType.dartHttp;
    if (clientType == ClientType.dartHttp) {
      if (proxySetting == null || !proxySetting.proxyEnabled) {
        return DartHttpClient(Client());
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
      return DartHttpClient(IOClient(httpClient));
    }
    if (clientType == ClientType.rHttp) {
      if (!_rhttpInitialized) {
        _rhttpInitialized = true;
        try {
          await Rhttp.init();
        } catch (_) {}
      }
      if (proxySetting == null || !proxySetting.proxyEnabled) {
        return RhttpClientProxy.createSync();
      }
      final proxyAddress =
          "${proxySetting.proxyAddress}:${proxySetting.proxyPort}";
      return RhttpClientProxy.createSync(
        settings: ClientSettings(
          proxySettings: ProxySettings.proxy(proxyAddress),
        ),
      );
    }
    throw Exception("Unknown client type");
  }
}
