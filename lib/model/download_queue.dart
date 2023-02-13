import 'download_item.dart';

class DownloadQueue {
  final int id;
  final String queueName;
  List<DownloadItem> queue;

  DownloadQueue({
    required this.id,
    required this.queueName,
    this.queue = const [],
  });
}
