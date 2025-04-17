import 'dart:async';
import 'dart:convert';

import 'package:brisk/constants/setting_options.dart';
import 'package:brisk/model/download_item.dart';
import 'package:brisk/setting/proxy/proxy_setting.dart';
import 'package:brisk/util/http_client_builder.dart';
import 'package:dartx/dartx.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../constants/setting_type.dart';
import '../db/hive_util.dart';
import '../model/file_metadata.dart';
import '../model/setting.dart';

// Removed usage because of status 400 in google drive. also it doesn't seem necessary anyway
const Map<String, String> contentType_MultiPartByteRanges = {
  'content-type': 'multipart/byteranges;'
};

const Map<String, String> userAgentHeader = {
  "User-Agent":
      "Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko;",
};

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
  if (filename != null && filename.startsWith("UTF-8''")) {
    filename = filename.replaceAll("UTF-8''", "");
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
  return Uri.tryParse(url)?.hasAbsolutePath ?? false;
}

List<int> calculateByteStartAndByteEnd(
    int totalSegments, int segmentNumber, contentLength) {
  final isLastSegment = totalSegments == segmentNumber;
  final segmentLength = (contentLength / totalSegments).floor();
  final byteStart = ((segmentNumber - 1) * segmentLength).toInt();
  final byteEnd = isLastSegment ? contentLength : byteStart + segmentLength - 1;
  return [byteStart, byteEnd];
}

Future<List<FileInfo>?> requestFileInfoBatch(
  List<DownloadItem> downloadItems, {
  ProxySetting? proxySetting = null,
}) async {
  List<FileInfo> fileInfos = [];
  for (final item in downloadItems) {
    final fileInfo = await requestFileInfo(
      item,
      proxySetting,
      ignoreException: true,
    ).onError((error, stackTrace) => null);
    if (fileInfo == null) continue;
    fileInfo.url = item.downloadUrl;
    fileInfos.add(fileInfo);
  }
  return fileInfos;
}

Future<FileInfo?> requestFileInfo(
  DownloadItem downloadItem,
  ProxySetting? proxySetting, {
  ignoreException = false,
}) async {
  return await sendFileInfoRequest(
    downloadItem,
    ignoreException: ignoreException,
  ).catchError((e) async {
    final fileInfo = await sendFileInfoRequest(
      downloadItem,
      ignoreException: ignoreException,
      proxySetting: proxySetting,
      useGet: true,
    );
    return fileInfo;
  });
}

/// Sends a HEAD request to the url given in the [downloadItem] object.
/// Determines pause/resume functionality support by the server,
/// total file size and the content-type of the request.
/// TODO handle status codes other than 200
Future<FileInfo?> sendFileInfoRequest(
  DownloadItem downloadItem, {
  ProxySetting? proxySetting = null,
  bool ignoreException = false,
  bool useGet = false,
}) async {
  Completer<FileInfo?> completer = Completer();
  final request = http.Request(
    useGet ? "GET" : "HEAD",
    Uri.parse(downloadItem.downloadUrl),
  );
  request.headers.addAll(userAgentHeader);
  final client = HttpClientBuilder.buildClient(proxySetting);
  try {
    client
        .send(request)
        .asStream()
        .timeout(Duration(seconds: 10))
        .listen((streamedResponse) {
      try {
        final headers = streamedResponse.headers;
        var filename = extractFilenameFromHeaders(headers);
        if (filename != null) {
          downloadItem.fileName = filename;
        }
        if (headers["content-length"] == null ||
            !streamedResponse.statusCode.toString().startsWith("2")) {
          if (ignoreException) {
            completer.complete(null);
            return;
          }
          completer.completeError(
              Exception("Failed to retrieve result from the given URL"));
          return;
        }
        downloadItem.contentLength = int.parse(headers["content-length"]!);
        downloadItem.fileName = Uri.decodeComponent(downloadItem.fileName);
        final supportsPause = checkDownloadPauseSupport(headers);
        final data = FileInfo(
          supportsPause,
          downloadItem.fileName,
          downloadItem.contentLength,
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

Future<dynamic> checkLatestBriskRelease() async {
  Completer<dynamic> completer = Completer();
  final response = http.Client().get(
    Uri.parse("https://api.github.com/repos/AminBhst/brisk/releases/latest"),
  );
  response.asStream().listen((event) {
    final json = jsonDecode(String.fromCharCodes(event.bodyBytes));
    completer.complete(json);
    return;
  });
  return completer.future;
}

Future<Pair<bool, String>> isNewBriskVersionAvailable({
  bool ignoreLastUpdateCheck = false,
}) async {
  var lastUpdateCheck = HiveUtil.getSetting(SettingOptions.lastUpdateCheck);
  if (lastUpdateCheck == null) {
    lastUpdateCheck = Setting(
      name: "lastUpdateCheck",
      value: "0",
      settingType: SettingType.system.name,
    );
    await HiveUtil.instance.settingBox.add(lastUpdateCheck);
  }
  if (!ignoreLastUpdateCheck &&
      int.parse(lastUpdateCheck.value) + 86400000 >
          DateTime.now().millisecondsSinceEpoch) return Pair(false, "");

  final json = await checkLatestBriskRelease();
  if (json["message"].toString().contains("rate limit")) {
    throw Exception("GitHub API rate limit exceeded. Please try again later.");
  }
  if (json == null || json['tag_name'] == null) return Pair(false, "");

  String tagName = json['tag_name'];
  tagName = tagName.replaceAll(".", "").replaceAll("v", "");
  String latestVersion = (json['tag_name'] as String).replaceAll("v", "");
  final packageInfo = await PackageInfo.fromPlatform();
  lastUpdateCheck = HiveUtil.getSetting(SettingOptions.lastUpdateCheck)!;
  lastUpdateCheck.value = DateTime.now().millisecondsSinceEpoch.toString();
  await lastUpdateCheck.save();
  return Pair(
    isNewVersionAvailable(latestVersion, packageInfo.version),
    latestVersion,
  );
}

bool isNewVersionAvailable(String latestVersion, String targetVersion) {
  final latestSplit = latestVersion.split(".");
  final currentSplit = targetVersion.split(".");
  for (int i = 0; i < latestSplit.length; i++) {
    final splitVersion = int.parse(latestSplit[i]);
    final splitCurrent = int.parse(currentSplit[i]);
    if (splitVersion > splitCurrent) {
      return true;
    }
    if (i == latestSplit.length - 1) {
      return false;
    }
  }
  return false;
}
