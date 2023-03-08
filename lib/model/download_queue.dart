import 'package:hive/hive.dart';

part 'download_queue.g.dart';

@HiveType(typeId: 1)
class DownloadQueue extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<int>? downloadItemsIds;

  DownloadQueue({required this.name, this.downloadItemsIds});
}
