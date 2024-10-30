import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:brisk_auto_updater/downloader/file_info.dart';
import 'package:brisk_auto_updater/provider/download_progress_provider.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class UpdateDownloader {
  static List<List<int>> buffer = [];
  static int totalReceivedBytes = 0;
  static String? downloadUrl =
      "https://github.com/AliML111/brisk/releases/download/v2.0.1/Brisk-v2.0.1-linux-x86_64.tar.xz";

  static const Map<String, String> userAgentHeader = {
    "User-Agent":
        "Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko;",
  };

  static http.Client client = http.Client();

  static void installUpdate(
    BuildContext context, {
    required Function onInstallComplete,
    bool reset = false,
  }) async {
    print("Inside download");
    final provider = Provider.of<DownloadProgressProvider>(
      context,
      listen: false,
    );
    if (reset) {
      client.close();
    }
    provider.setProgress(0);
    if (downloadUrl != null) {
      sendDownloadRequest(provider, onInstallComplete);
      return;
    }
    final latestTag = await getJsonResponse(
      "https://api.github.com/repos/AminBhst/brisk/releases/latest",
    );
    print("god json response");
    final version = latestTag["tag_name"];
    for (final asset in latestTag["assets"]) {
      if (asset["name"] == "Brisk-$version-windows-x86_64.exe") {
        downloadUrl = asset["browser_download_url"];
        break;
      }
    }
    if (downloadUrl == null) {
      throw Exception(
        "Failed to find download URL. Please install the new version manually",
      );
    }
    sendDownloadRequest(provider, onInstallComplete);
  }

  static void sendDownloadRequest(
    DownloadProgressProvider provider,
    Function onInstallComplete,
  ) async {
    totalReceivedBytes = 0;
    print("Sending download request...");
    final fileInfo = await requestFileInfo(downloadUrl!);
    client = http.Client();
    buffer.clear();
    final request = http.Request('GET', Uri.parse(downloadUrl!));
    request.headers.addAll({
      userAgentHeader.keys.first: userAgentHeader.values.first,
      "Range": "bytes=0-${fileInfo!.contentLength}",
    });
    try {
      final response = client.send(request);
      response.asStream().cast<http.StreamedResponse>().listen((response) {
        response.stream.listen(
          (chunk) {
            totalReceivedBytes += chunk.length;
            buffer.add(chunk);
            provider.setProgress(totalReceivedBytes / fileInfo.contentLength);
          },
          onDone: () => onComplete(provider).then((_) => onInstallComplete()),
          onError: _onError,
        );
      }).onError(_onError);
    } catch (e) {
      _onError(e);
    }
  }

  static Future<void> onComplete(DownloadProgressProvider provider) async {
    /// TODO handle different OS
    try {
      String executablePath = Platform.resolvedExecutable;
      final package = _writeToUin8List(buffer);
      final archive = Platform.isWindows
          ? ZipDecoder().decodeBytes(package)
          : TarDecoder().decodeBytes(XZDecoder().decodeBytes(package));

      for (final file in archive) {
        if (file.name.startsWith("updater/") ||
            file.name.startsWith("updater\\")) {
          continue;
        }
        var filename = join(
          Directory(executablePath).parent.parent.path,
          file.name,
        );
        if (file.isFile) {
          final fileToWrite = File(filename);
          if (!fileToWrite.existsSync()) {
            fileToWrite.createSync(recursive: true);
          }
          fileToWrite.writeAsBytesSync(file.content as List<int>);
        } else {
          await Directory(filename).create(recursive: true);
        }
      }
    } catch (e) {
      provider.setProgress(0);
      provider.setError(e.toString());
    }
  }

  static Uint8List _writeToUin8List(List<List<int>> chunks) {
    int start = 0;
    var len = 0;
    for (var c in chunks) {
      len += c.length;
    }
    final bytes = Uint8List(len);
    for (var chunk in chunks) {
      bytes.setRange(start, start + chunk.length, chunk);
      start += chunk.length;
    }
    return bytes;
  }

  static void _onError(e) {
    buffer.clear();
  }

  static Future<FileInfo?> requestFileInfo(
    String url, {
    ignoreException = false,
  }) async {
    return await sendFileInfoRequest(
      url,
      ignoreException: ignoreException,
    ).catchError((e) async {
      final fileInfo = await sendFileInfoRequest(
        url,
        ignoreException: ignoreException,
        useGet: true,
      );
      return fileInfo;
    });
  }

  /// TODO handle errors in UI
  static Future<FileInfo?> sendFileInfoRequest(
    String url, {
    bool ignoreException = false,
    bool useGet = false,
  }) async {
    final request = http.Request(
      useGet ? "GET" : "HEAD",
      Uri.parse(url),
    );
    request.headers.addAll(userAgentHeader);
    final client = http.Client();
    var response = client.send(request);
    Completer<FileInfo?> completer = Completer();

    try {
      response
          .asStream()
          .timeout(Duration(seconds: 10))
          .listen((streamedResponse) {
        try {
          final headers = streamedResponse.headers;
          var filename = extractFilenameFromHeaders(headers);
          if (headers["content-length"] == null ||
              !streamedResponse.statusCode.toString().startsWith("2")) {
            if (ignoreException) {
              completer.complete(null);
              return;
            }
            completer.completeError(
                Exception("Could not retrieve result from the given URL"));
            return;
          }
          final contentLength = int.parse(headers["content-length"]!);
          filename = Uri.decodeComponent(filename!);
          final data = FileInfo(
            false,
            filename,
            contentLength,
          );
          completer.complete(data);
        } finally {
          if (useGet) {
            client.close();
          }
        }
      }).onError((e) {
        completer.completeError(
          Exception("Could not retrieve result from the given URL"),
        );
      });
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future;
  }

  static String? extractFilenameFromHeaders(Map<String, String> headers) {
    final contentDisposition = headers['content-disposition'];
    if (contentDisposition == null) return null;
    List<String> tokens = contentDisposition.split(";");
    String? filename;
    for (var i = 0; i < tokens.length; i++) {
      if (tokens[i].contains('filename')) {
        filename = !tokens[i].contains('"')
            ? tokens[i].substring(tokens[i].indexOf("=") + 1, tokens[i].length)
            : tokens[i]
                .substring(tokens[i].indexOf("=") + 2, tokens[i].length - 1);
      }
    }
    if (filename != null && filename.startsWith("UTF-8''")) {
      filename = filename.replaceAll("UTF-8''", "");
    }
    return filename;
  }

  static Future<dynamic> getJsonResponse(String url) async {
    Completer<dynamic> completer = Completer();
    client = http.Client();
    final response = http.Client().get(Uri.parse(url));
    response.asStream().listen((event) {
      final json = jsonDecode(String.fromCharCodes(event.bodyBytes));
      completer.complete(json);
      return;
    }).onError((e) {
      print(e);
      completer.completeError(e);
    });
    return completer.future;
  }
}
