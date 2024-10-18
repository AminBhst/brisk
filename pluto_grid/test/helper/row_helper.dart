import 'dart:math';

import 'package:pluto_grid/pluto_grid.dart';

class RowHelper {
  /// cell value format : '$columnFieldName value $rowIdx'
  static List<PlutoRow> count(
    int count,
    List<PlutoColumn>? columns, {
    bool checked = false,
    int start = 0,
  }) {
    return Iterable<int>.generate(count).map((rowIdx) {
      rowIdx += start;

      return PlutoRow(
        sortIdx: rowIdx,
        cells: Map.fromIterable(
          columns!,
          key: (dynamic column) => column.field.toString(),
          value: (dynamic column) {
            if ((column as PlutoColumn).type.isText) {
              return cellOfTextColumn(column, rowIdx);
            } else if (column.type.isDate) {
              return cellOfDateColumn(column, rowIdx);
            } else if (column.type.isTime) {
              return cellOfTimeColumn(column, rowIdx);
            } else if (column.type.isSelect) {
              return cellOfTimeColumn(column, rowIdx);
            } else if (column.type.isNumber || column.type.isCurrency) {
              return cellOfNumberColumn(column, rowIdx);
            }

            throw Exception('Column is not implemented.');
          },
        ),
        checked: checked,
      );
    }).toList();
  }

  static PlutoCell cellOfTextColumn(PlutoColumn column, int rowIdx) {
    return PlutoCell(value: '${column.field} value $rowIdx');
  }

  static PlutoCell cellOfDateColumn(PlutoColumn column, int rowIdx) {
    return PlutoCell(
      value: DateTime.now()
          .add(Duration(
            days: Random().nextInt(365),
          ))
          .toString(),
    );
  }

  static PlutoCell cellOfTimeColumn(PlutoColumn column, int rowIdx) {
    return PlutoCell(value: '00:00');
  }

  static PlutoCell cellOfSelectColumn(PlutoColumn column, int rowIdx) {
    return PlutoCell(
      value: (column.type.select.items.toList()..shuffle()).first,
    );
  }

  static PlutoCell cellOfNumberColumn(PlutoColumn column, int rowIdx) {
    return PlutoCell(value: Random().nextInt(10000));
  }

  static double resolveRowTotalHeight(double rowHeight) {
    return rowHeight + PlutoGridSettings.rowBorderWidth;
  }
}
