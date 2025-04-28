class ProxySetting {
  String proxyAddress;
  String proxyPort;
  String? username;
  String? password;
  bool proxyEnabled;

  ProxySetting({
    required this.proxyAddress,
    required this.proxyPort,
    this.proxyEnabled = false,
    this.username,
    this.password,
  });
}
