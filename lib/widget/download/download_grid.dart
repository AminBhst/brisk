import 'package:brisk/constants/file_type.dart';
import 'package:brisk/provider/download_request_provider.dart';
import 'package:brisk/provider/pluto_grid_state_manager_provider.dart';
import 'package:brisk/util/file_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

import 'download_progress_window.dart';

class DownloadGrid extends StatelessWidget {
  List<PlutoColumn> columns = [
    PlutoColumn(
      readOnly: true,
      hide: true,
      width: 80,
      title: 'Id',
      field: 'id',
      type: PlutoColumnType.number(),
    ),
    PlutoColumn(
      enableRowChecked: true,
      width: 300,
      title: 'File Name',
      field: 'file_name',
      type: PlutoColumnType.text(),
      renderer: (rendererContext) {
        final fileName = rendererContext.row.cells["file_name"]!.value;
        final fileType = FileUtil.detectFileType(fileName);
        return Row(
          children: [
            SizedBox(
              width: fileType == DLFileType.program ? 25 : 30,
              height: fileType == DLFileType.program ? 25 : 30,
              child: SvgPicture.asset(
                FileUtil.resolveFileTypeIconPath(fileType),
                color: FileUtil.resolveFileTypeIconColor(fileType),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                rendererContext.row.cells[rendererContext.column.field]!.value
                    .toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    ),
    PlutoColumn(
      readOnly: true,
      width: 90,
      title: 'Size',
      field: 'size',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      readOnly: true,
      width: 100,
      title: 'Progress',
      field: 'progress',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
        readOnly: true,
        width: 140,
        title: "Status",
        field: "status",
        type: PlutoColumnType.text()),
    PlutoColumn(
      readOnly: true,
      enableSorting: false,
      width: 122,
      title: 'Transfer Rate',
      field: 'transfer_rate',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      readOnly: true,
      width: 100,
      title: 'Time Left',
      field: 'time_left',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      readOnly: true,
      width: 100,
      title: 'Start Date',
      field: 'start_date',
      type: PlutoColumnType.date(),
    ),
    PlutoColumn(
      readOnly: true,
      width: 120,
      title: 'Finish Date',
      field: 'finish_date',
      type: PlutoColumnType.date(),
    ),
    PlutoColumn(
      readOnly: true,
      hide: true,
      width: 120,
      title: 'File Type',
      field: 'file_type',
      type: PlutoColumnType.text(),
    )
  ];

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<DownloadRequestProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;
    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: size.height - 70,
        width: size.width * 0.8,
        decoration: const BoxDecoration(color: Colors.black26),
        child: PlutoGrid(
          key: UniqueKey(),
          mode: PlutoGridMode.selectWithOneTap,
          configuration: const PlutoGridConfiguration(
            style: PlutoGridStyleConfig.dark(
              activatedBorderColor: Colors.transparent,
              borderColor: Colors.black26,
              gridBorderColor: Colors.black54,
              activatedColor: Colors.black26,
              gridBackgroundColor: Color.fromRGBO(40, 46, 58, 1),
              rowColor: Color.fromRGBO(49, 56, 72, 1),
              checkedColor: Colors.blueGrey,
            ),
          ),
          onRowDoubleTap: (event) {
            final id = event.row.cells["id"]!.value;
            if (provider.downloads[id] != null) {
              showDialog(
                context: context,
                builder: (_) => DownloadProgressWindow(id),
              );
            }
          },
          columns: columns,
          rows: [],
          onLoaded: (event) {
            PlutoGridStateManagerProvider.plutoStateManager
                ?.setShowLoading(true);
            PlutoGridStateManagerProvider.setStateManager(event.stateManager);
            PlutoGridStateManagerProvider.plutoStateManager
                ?.setSelectingMode(PlutoGridSelectingMode.row);
            provider.fetchRows();
          },
        ),
      ),
    );
  }
}
