import 'dart:async';
import 'dart:convert';

import 'package:brisk/constants/setting_options.dart';
import 'package:brisk/model/download_item.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../constants/setting_type.dart';
import '../db/hive_util.dart';
import '../model/file_metadata.dart';
import '../model/setting.dart';
import '../widget/base/confirmation_dialog.dart';

// Removed usage because of status 400 in google drive. also it doesn't seem necessary anyway
const Map<String, String> contentType_MultiPartByteRanges = {
  'content-type': 'multipart/byteranges;'
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
  List<DownloadItem> downloadItems,
) async {
  List<FileInfo> fileInfos = [];
  for (final item in downloadItems) {
    final fileInfo = await requestFileInfo(item, ignoreException: true)
        .onError((error, stackTrace) => null);
    if (fileInfo == null) continue;
    fileInfo.url = item.downloadUrl;
    fileInfos.add(fileInfo);
  }
  return fileInfos;
}

/// Sends a HEAD request to the url given in the [downloadItem] object.
/// Determines pause/resume functionality support by the server,
/// total file size and the content-type of the request.
/// TODO handle status codes other than 200
Future<FileInfo?> requestFileInfo(DownloadItem downloadItem,
    {bool ignoreException = false}) async {
  final request = http.Request("HEAD", Uri.parse(downloadItem.downloadUrl));
  final client = http.Client();
  var response = client.send(request);
  Completer<FileInfo?> completer = Completer();
  response.asStream().timeout(Duration(seconds: 10)).listen((streamedResponse) {
    final headers = streamedResponse.headers;
    var filename = extractFilenameFromHeaders(headers);
    if (filename != null) {
      downloadItem.fileName = filename;
    }
    if (headers["content-length"] == null) {
      if (ignoreException) {
        completer.complete(null);
        return;
      }
      throw Exception({"Could not retrieve result from the given URL"});
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
  },
      onError: ignoreException ? (e) => completer.completeError(e) : null,
      cancelOnError: !ignoreException);
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

// TODO Refactor and fix version check logic
void checkForUpdate(BuildContext context) async {
  var lastUpdateCheck = HiveUtil.getSetting(SettingOptions.lastUpdateCheck);
  if (lastUpdateCheck == null) {
    lastUpdateCheck = Setting(
      name: "lastUpdateCheck",
      value: "0",
      settingType: SettingType.system.name,
    );
    await HiveUtil.instance.settingBox.add(lastUpdateCheck);
  }
  if (int.parse(lastUpdateCheck.value) + 86400000 >
      DateTime.now().millisecondsSinceEpoch) return;

  final json = await checkLatestBriskRelease();
  if (json == null || json['tag_name'] == null) return;

  String tagName = json['tag_name'];
  tagName = tagName.replaceAll(".", "").replaceAll("v", "");
  String latestVersion = (json['tag_name'] as String).replaceAll("v", "");
  final packageInfo = await PackageInfo.fromPlatform();
  if (_isNewVersionAvailable(latestVersion, packageInfo)) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title:
            "New version of Brisk is available. Do you want to download the latest version?",
        onConfirmPressed: () => launchUrlString(
          "https://github.com/AminBhst/brisk/releases/latest",
        ),
      ),
    );
    lastUpdateCheck.value = DateTime.now().millisecondsSinceEpoch.toString();
    await lastUpdateCheck.save();
  }
}

bool _isNewVersionAvailable(String latestVersion, PackageInfo packageInfo) {
  final latestSplit = latestVersion.split(".");
  final currentSplit = packageInfo.version.split(".");
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
