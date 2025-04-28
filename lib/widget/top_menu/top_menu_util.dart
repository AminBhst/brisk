import 'package:brisk/db/hive_util.dart';
import 'package:brisk/provider/download_request_provider.dart';
import 'package:brisk/provider/pluto_grid_util.dart';
import 'package:brisk_download_engine/brisk_download_engine.dart';

bool isDownloadButtonEnabled(DownloadRequestProvider provider) {
  final selectedRowIds = PlutoGridUtil.selectedRowIds;
  final completedDownloadSelected = selectedRowIds
      .map((id) => HiveUtil.instance.downloadItemsBox.get(id))
      .toList()
      .any((download) =>
          download != null &&
          download.status == DownloadStatus.assembleComplete);
  return (selectedRowIds.isEmpty || completedDownloadSelected)
      ? false
      : (provider.downloads.values
              .where((item) => selectedRowIds.contains(item.downloadItem.id))
              .every((item) => item.buttonAvailability.startButtonEnabled) ||
          provider.downloads.values.isEmpty);
}

bool isPauseButtonEnabled(DownloadRequestProvider provider) {
  final selectedRowIds = PlutoGridUtil.selectedRowIds;
  return (selectedRowIds.isEmpty || provider.downloads.values.isEmpty)
      ? false
      : provider.downloads.values
          .where((item) => selectedRowIds.contains(item.downloadItem.id))
          .every((item) => item.buttonAvailability.pauseButtonEnabled);
}
