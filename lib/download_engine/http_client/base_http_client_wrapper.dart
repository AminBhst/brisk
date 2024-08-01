import 'package:http/http.dart' as http;

abstract class BaseHttpClientWrapper {

  late http.Client client;

  void close();
}