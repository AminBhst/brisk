import 'dart:io';

import 'package:brisk/download_engine/segment/segment_status.dart';
import 'package:brisk/download_engine/util/m3u8_util.dart';

class M3U8 {
  final List<M3U8Segment> segments;
  final int mediaSequence;
  final M3U8EncryptionDetails encryptionDetails;

  M3U8({
    required this.segments,
    required this.mediaSequence,
    required this.encryptionDetails,
  });

  static Future<M3U8?> fromFile(File file) async {
    final lines = file.readAsLinesSync();
    int mediaSequence = 0;
    M3U8EncryptionDetails encryptionDetails = M3U8EncryptionDetails();
    bool reachedSegments = false;
    int currSegmentNum = -1;
    Map<int, M3U8Segment> segments = {};
    for (final line in lines) {
      if (line.startsWith("#EXT-X-MEDIA-SEQUENCE:")) {
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

    final m3u8 = M3U8(
      segments: segments.values.toList(),
      mediaSequence: mediaSequence,
      encryptionDetails: encryptionDetails,
    );
    if (m3u8.encryptionDetails.encryptionMethod ==
        M3U8EncryptionMethod.AES_128) {
      m3u8.encryptionDetails.keyBytes = await fetchDecryptionKey(
        m3u8.encryptionDetails.encryptionKeyUrl!,
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

class M3U8Segment {
  String url;
  int sequenceNumber;
  String extInf;
  int? connectionNumber;
  SegmentStatus segmentStatus;

  /// Encryption details for m3u8 files with key rotation
  M3U8EncryptionDetails? encryptionDetails;

  M3U8EncryptionMethod get encryptionMethod =>
      encryptionDetails != null
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
  List<int>? keyBytes;

  M3U8EncryptionDetails({
    this.encryptionMethod = M3U8EncryptionMethod.NONE,
    this.encryptionKeyUrl,
    this.iv,
    this.keyBytes,
  });
}
