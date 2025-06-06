import 'package:brisk_download_engine/src/download_engine/client/custom_base_client.dart';
import 'package:http/http.dart';
import 'package:rhttp/rhttp.dart';

class RhttpClientProxy with CustomBaseClient {
  final RhttpClient client;
  CancelToken cancelToken = CancelToken();

  RhttpClientProxy._(this.client);

  static Future<RhttpClientProxy> create({
    ClientSettings? settings,
    List<Interceptor>? interceptors,
  }) async {
    final client = await RhttpClient.create(
      settings: (settings ?? const ClientSettings()).digest(),
      interceptors: interceptors,
    );
    return RhttpClientProxy._(client);
  }

  factory RhttpClientProxy.createSync({
    ClientSettings? settings,
    List<Interceptor>? interceptors,
  }) {
    final client = RhttpClient.createSync(
      settings: (settings ?? const ClientSettings()).digest(),
      interceptors: interceptors,
    );
    return RhttpClientProxy._(client);
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    try {
      cancelToken = CancelToken();
      final response = await client.requestStream(
        cancelToken: cancelToken,
        method: HttpMethod(request.method.toUpperCase()),
        url: request.url.toString(),
        headers: HttpHeaders.rawMap(request.headers),
        body: HttpBody.bytes(await request.finalize().toBytes()),
      );

      final responseHeaderMap = response.headerMap;

      return StreamedResponse(
        response.body,
        response.statusCode,
        contentLength: switch (responseHeaderMap['content-length']) {
          String s => int.parse(s),
          null => null,
        },
        request: request,
        headers: responseHeaderMap,
        isRedirect: false,
        persistentConnection: true,
        reasonPhrase: null,
      );
    } on RhttpException catch (e, st) {
      Error.throwWithStackTrace(
        RhttpWrappedClientException(e.toString(), request.url, e),
        st,
      );
    } catch (e, st) {
      Error.throwWithStackTrace(ClientException(e.toString(), request.url), st);
    }
  }

  @override
  Future<void> cancelRequest() async {
    await cancelToken.cancel();
  }

  @override
  void close() {
    client.dispose(cancelRunningRequests: true);
  }
}

class RhttpWrappedClientException extends ClientException {
  final RhttpException rhttpException;

  RhttpWrappedClientException(super.message, super.uri, this.rhttpException);

  @override
  String toString() => rhttpException.toString();
}

extension on ClientSettings {
  ClientSettings digest() {
    ClientSettings settings = this;
    if (throwOnStatusCode) {
      settings = settings.copyWith(throwOnStatusCode: false);
    }

    return settings;
  }
}
