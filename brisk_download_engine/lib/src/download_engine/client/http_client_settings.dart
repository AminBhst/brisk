import 'package:brisk_download_engine/src/download_engine/client/client_type.dart';
import 'package:brisk_download_engine/src/download_engine/setting/proxy_setting.dart';

class HttpClientSettings {
  ProxySetting? proxySetting;
  ClientType clientType;

  HttpClientSettings({
    this.proxySetting,
    this.clientType = ClientType.dartHttp,
  });
}
