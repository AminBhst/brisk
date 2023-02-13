import 'dart:async';

import 'package:brisk/model/download_item.dart';

import '../model/file_metadata.dart';
import 'package:http/http.dart' as http;

const urlRegex = '(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]'
    '+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]'
    '{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]'
    '+\.[^\s]{2,})';

bool checkDownloadPauseSupport(Map<String, String> headers) {
  var value = headers['Accept-Ranges'] ?? headers['accept-ranges'];
  return value != null && value == 'bytes';
}

String? extractFilenameFromHeaders(Map<String, String> headers) {
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
  return filename;
}

String extractFileNameFromUrl(String url) {
  final slashIndex = url.lastIndexOf('/');
  final dotIndex = url.lastIndexOf('.');
  return (url.substring(dotIndex).contains('?'))
      ? url.substring(slashIndex + 1, url.lastIndexOf('?'))
      : url.substring(slashIndex + 1);
}

bool isUrlValid(String url) {
  return RegExp(urlRegex).hasMatch(url);
}

List<int> calculateByteStartAndByteEnd(
    int totalSegments, int segmentNumber, contentLength) {
  final isLastSegment = totalSegments == segmentNumber;
  final segmentLength = (contentLength / totalSegments).floor();
  final byteStart = ((segmentNumber - 1) * segmentLength).toInt();
  final byteEnd = isLastSegment ? contentLength : byteStart + segmentLength - 1;
  return [byteStart, byteEnd];
}

/// Sends a HEAD request to the url given in the [downloadItem] object.
/// Determines pause/resume functionality support by the server,
/// total file size and the content-type of the request.
Future<FileInfo> requestFileInfo(DownloadItem downloadItem) async {
  final request = http.Request("HEAD", Uri.parse(downloadItem.downloadUrl));
  final client = http.Client();
  var response = client.send(request);
  Completer<FileInfo> completer = Completer();
  response.asStream().listen((streamedResponse) {
    final headers = streamedResponse.headers;
    final filename = extractFilenameFromHeaders(headers);
    if (filename != null) {
      downloadItem.fileName = filename;
    }
    if (headers["content-length"] == null) {
      throw Exception({"Could not retrieve result from the given URL"});
    }
    downloadItem.contentLength = int.parse(headers["content-length"]!);
    final supportsPause = checkDownloadPauseSupport(headers);
    final data = FileInfo(
      supportsPause,
      downloadItem.fileName,
      downloadItem.contentLength,
    );
    completer.complete(data);
  }, onError: (e) => completer.completeError(e), cancelOnError: true);
  return completer.future;
}
