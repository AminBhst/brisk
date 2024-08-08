import 'dart:io';
import 'package:dartx/dartx.dart';
import 'package:path/path.dart';

List<File> getTempFilesSorted(Directory tempDir) {
  return tempDir.listSync().map((o) => o as File).toList()
    ..sort(sortByByteRanges);
}

int getTotalWrittenBytesLength(
  Directory tempDir,
  int connectionNumber,
) {
  return getTempFilesSorted(tempDir)
      .where(
        (file) => tempFileBelongsToThisConnection(file, connectionNumber),
      )
      .map((file) => basename(file.path))
      .reduce((f1, f2) => addTempFilesLength(f1, f2).toString())
      .toInt();
}

int addTempFilesLength(String firstFileName, String secondFileName) {
  return getTempFileLength(firstFileName) + getTempFileLength(secondFileName);
}

int getTempFileLength(String tempFileName) {
  return getEndByteFromTempFileName(tempFileName) -
      getStartByteFromTempFileName(tempFileName) +
      1;
}

bool tempFileBelongsToThisConnection(File file, int connectionNumber) {
  return getConnectionNumberFromTempFileName(basename(file.path)) ==
      connectionNumber;
}

int sortByByteRanges(FileSystemEntity a, FileSystemEntity b) {
  final aName = basename(a.path);
  final bName = basename(b.path);
  final aStartByte = getStartByteFromTempFileName(aName);
  final bStartByte = getStartByteFromTempFileName(bName);
  return aStartByte.compareTo(bStartByte);
}

int getStartByteFromTempFileName(String tempFileName) {
  return int.parse(
    tempFileName.substring(
      tempFileName.indexOf("#") + 1,
      tempFileName.indexOf("-"),
    ),
  );
}

int getStartByteFromTempFile(File tempFile) {
  return getStartByteFromTempFileName(basename(tempFile.path));
}

int getEndByteFromTempFile(File tempFile) {
  return getEndByteFromTempFileName(basename(tempFile.path));
}

int getEndByteFromTempFileName(String fileName) {
  return int.parse(fileName.substring(fileName.indexOf("-") + 1));
}

int getConnectionNumberFromTempFileName(String fileName) {
  return int.parse(fileName.substring(0, fileName.indexOf("#")));
}
