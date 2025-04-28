import '../model/download_item_model.dart';

class ConnectionDetails {
  DownloadItemModel downloadItem;
  double downloadProgress;
  int totalReceivedBytes;
  double totalDownloadProgress;
  String transferRate;
  double bytesTransferRate;
  String status;
  String estimatedRemaining;
  bool paused;
  double writeProgress;
  double assembleProgress;
  bool startButtonEnabled;
  bool pauseButtonEnabled;
  int connectionNumber;
  int segmentLength;
  String detailsStatus;
  String message;

  ConnectionDetails({
    required this.downloadItem,
    this.connectionNumber = 0,
    this.downloadProgress = 0,
    this.transferRate = "",
    this.status = "",
    this.estimatedRemaining = "",
    this.paused = false,
    this.writeProgress = 0,
    this.assembleProgress = 0,
    this.startButtonEnabled = false,
    this.pauseButtonEnabled = false,
    this.bytesTransferRate = 0,
    this.totalReceivedBytes = 0,
    this.totalDownloadProgress = 0,
    this.segmentLength = 0,
    this.detailsStatus = "",
    this.message = "",
  });
}
