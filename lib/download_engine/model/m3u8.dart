import 'dart:typed_data';

import 'package:brisk/constants/http_constants.dart';
import 'package:brisk/download_engine/segment/segment_status.dart';
import 'package:brisk/download_engine/util/m3u8_util.dart';
import 'package:brisk/setting/proxy/proxy_setting.dart';
import 'package:brisk/util/http_client_builder.dart';

class M3U8 {
  final String url;
  final List<StreamInf> streamInfos;
  final List<M3U8Segment> segments;
  final int mediaSequence;
  final M3U8EncryptionDetails encryptionDetails;
  final int totalDuration;
  final String stringContent;
  String? refererHeader;

  String get fileName {
    if (url.contains("/")) {
      return url.substring(url.lastIndexOf('/') + 1);
    }
    return url;
  }

  M3U8({
    required this.url,
    required this.segments,
    required this.mediaSequence,
    required this.encryptionDetails,
    required this.streamInfos,
    required this.totalDuration,
    required this.stringContent,
    this.refererHeader,
  });

  bool get isMasterPlaylist => segments.isEmpty && streamInfos.isNotEmpty;

  static Future<M3U8?> fromUrl(
    String url, {
    ProxySetting? proxySetting = null,
    String? refererHeader,
  }) async {
    final client = HttpClientBuilder.buildClient(proxySetting);
    try {
      final headers = userAgentHeader;
      if (refererHeader != null) {
        headers.addAll({"referer": refererHeader});
      }
      final response = await client.get(
        Uri.parse(url),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final body = response.body;
        return await M3U8.fromString(body, url)
          ?..refererHeader = refererHeader;
      } else {
        print("Failed to fetch m3u8... status code ${response.statusCode}");
        throw Exception('Failed to fetch m3u8!');
      }
    } catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<M3U8?> fromString(
    String content,
    String url, {
    ProxySetting? proxySetting = null,
    bool fetchKeys = true,
    String? refererHeader,
  }) async {
    final lines = content.split("\n");
    int mediaSequence = 0;
    M3U8EncryptionDetails encryptionDetails = M3U8EncryptionDetails();
    bool reachedSegments = false;
    int currSegmentNum = -1;
    int currStreamInfNum = -1;
    Map<int, M3U8Segment> segments = {};
    Map<int, StreamInf> streamInfos = {};
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.startsWith("#EXT-X-STREAM-INF:")) {
        currStreamInfNum++;
        final urlLine = lines[i + 1];
        streamInfos[currStreamInfNum] = (streamInfos[currStreamInfNum] ??
            StreamInf())
          ..url = urlLine.trim();
        final resolutionPattern = RegExp(r'RESOLUTION=(\d+x\d+)');
        final matchRes = resolutionPattern.firstMatch(line);
        if (matchRes != null) {
          final resolution = matchRes.group(1);
          streamInfos[currStreamInfNum] = (streamInfos[currStreamInfNum] ??
              StreamInf())
            ..resolution = resolution;
        }
        final frameRatePattern = RegExp(r'FRAME-RATE=([\d.]+)');
        final matchFrameRate = frameRatePattern.firstMatch(line);
        if (matchFrameRate != null) {
          final frameRate = matchFrameRate.group(1);
          streamInfos[currStreamInfNum] = (streamInfos[currStreamInfNum] ??
              StreamInf())
            ..frameRate = frameRate;
        }
      } else if (line.startsWith("#EXT-X-MEDIA-SEQUENCE:")) {
        mediaSequence = int.tryParse(line.substring(22)) ?? 0;
      } else if (line.startsWith("#EXT-X-KEY")) {
        final attrs = parseAttributes(line);
        final currEncryptionDetails = M3U8EncryptionDetails(
          encryptionKeyUrl: attrs["URI"],
          encryptionMethod:
              M3U8EncryptionMethodParser.fromString(attrs["METHOD"]!),
          iv: attrs["IV"],
        );
        if (reachedSegments) {
          segments[currSegmentNum] = (segments[currSegmentNum] ?? M3U8Segment())
            ..encryptionDetails = currEncryptionDetails;
        } else {
          encryptionDetails = currEncryptionDetails;
        }
      } else if (line.startsWith("#EXTINF:")) {
        currSegmentNum++;
        final extInfValue = line.substring(8, line.length - 2);
        reachedSegments = true;
        segments[currSegmentNum] = (segments[currSegmentNum] ?? M3U8Segment())
          ..extInf = extInfValue
          ..sequenceNumber = currSegmentNum;
      } else if (line.startsWith("http")) {
        segments[currSegmentNum] = (segments[currSegmentNum] ?? M3U8Segment())
          ..url = line;
      }
    }
    final totalDuration = segments.isEmpty
        ? 0
        : segments.values
            .map((m) => double.tryParse(m.extInf) ?? 0)
            .reduce((sum, duration) => sum + duration)
            .toInt();
    final m3u8 = M3U8(
      segments: segments.values.toList(),
      mediaSequence: mediaSequence,
      encryptionDetails: encryptionDetails,
      streamInfos: streamInfos.values.toList(),
      totalDuration: totalDuration,
      stringContent: content,
      url: url,
    );
    if (m3u8.isMasterPlaylist) {
      for (var streamInf in m3u8.streamInfos) {
        var streamUrl = streamInf.url;
        if (streamUrl == null) continue;
        if (!streamUrl.contains("http")) {
          streamUrl = "${url.substring(0, url.lastIndexOf("/"))}/$streamUrl";
          streamInf.m3u8 = await M3U8.fromUrl(
            streamUrl,
            proxySetting: proxySetting,
            refererHeader: refererHeader,
          );
        }
      }
    }
    if (!fetchKeys) {
      return m3u8;
    }
    if (m3u8.encryptionDetails.encryptionMethod ==
        M3U8EncryptionMethod.AES_128) {
      m3u8.encryptionDetails.keyBytes = await fetchDecryptionKey(
        m3u8.encryptionDetails.encryptionKeyUrl!,
        proxySetting: proxySetting,
      );
    }
    for (var segment in m3u8.segments) {
      if (segment.encryptionDetails == null ||
          segment.encryptionDetails!.encryptionKeyUrl == null ||
          segment.encryptionDetails!.encryptionKeyUrl!.isEmpty) {
        continue;
      }
      segment.encryptionDetails!.keyBytes = await fetchDecryptionKey(
        segment.encryptionDetails!.encryptionKeyUrl!,
        proxySetting: proxySetting,
      );
    }

    return m3u8;
  }

  static Map<String, String> parseAttributes(String attributesLine) {
    final attributes = <String, String>{};
    final regex = RegExp(r'(\w+)="([^"]+)"|(\w+)=([^,]+)');
    for (final match in regex.allMatches(attributesLine)) {
      if (match.group(1) != null && match.group(2) != null) {
        attributes[match.group(1)!] = match.group(2)!;
      } else if (match.group(3) != null && match.group(4) != null) {
        attributes[match.group(3)!] = match.group(4)!;
      }
    }
    return attributes;
  }
}

class StreamInf {
  String? resolution;
  String? frameRate;
  String? url;
  M3U8? m3u8;

  String get fileName {
    if (url == null) return "";
    if (url!.contains("/")) {
      return url!.substring(url!.lastIndexOf('/') + 1);
    }
    return url!;
  }

  StreamInf({
    this.resolution,
    this.frameRate,
    this.url,
    this.m3u8,
  });
}

class M3U8Segment {
  String url;
  int sequenceNumber;
  String extInf;
  int? connectionNumber;
  SegmentStatus segmentStatus = SegmentStatus.INITIAL;

  /// Encryption details for m3u8 files with key rotation
  M3U8EncryptionDetails? encryptionDetails;

  M3U8EncryptionMethod get encryptionMethod => encryptionDetails != null
      ? encryptionDetails!.encryptionMethod
      : M3U8EncryptionMethod.NONE;

  M3U8Segment({
    this.url = "",
    this.sequenceNumber = 0,
    this.extInf = "",
    this.encryptionDetails,
    this.segmentStatus = SegmentStatus.INITIAL,
  });

  @override
  String toString() {
    return "Sequence Number $sequenceNumber Url: $url";
  }

  @override
  bool operator ==(Object other) {
    return other is M3U8Segment &&
        other.sequenceNumber == this.sequenceNumber &&
        other.url == this.url;
  }
}

enum M3U8EncryptionMethod {
  NONE,
  AES_128,
  SAMPLE_AES,
}

extension M3U8EncryptionMethodParser on M3U8EncryptionMethod {
  static M3U8EncryptionMethod fromString(String str) {
    if (str == "AES-128") {
      return M3U8EncryptionMethod.AES_128;
    } else if (str == "SAMPLE-AES") {
      return M3U8EncryptionMethod.SAMPLE_AES;
    } else
      return M3U8EncryptionMethod.NONE;
  }
}

class M3U8EncryptionDetails {
  final M3U8EncryptionMethod encryptionMethod;
  final String? encryptionKeyUrl;
  final String? iv;
  Uint8List? keyBytes;

  M3U8EncryptionDetails({
    this.encryptionMethod = M3U8EncryptionMethod.NONE,
    this.encryptionKeyUrl,
    this.iv,
    this.keyBytes,
  });
}
