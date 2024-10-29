class FileInfo {
  final bool supportsPause;
  final String fileName;
  final int contentLength;
  String url;

  FileInfo(this.supportsPause, this.fileName, this.contentLength, [this.url = ""]);
}
