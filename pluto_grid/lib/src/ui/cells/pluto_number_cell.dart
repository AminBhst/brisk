import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'decimal_input_formatter.dart';
import 'text_cell.dart';

class PlutoNumberCell extends StatefulWidget implements TextCell {
  @override
  final PlutoGridStateManager stateManager;

  @override
  final PlutoCell cell;

  @override
  final PlutoColumn column;

  @override
  final PlutoRow row;

  const PlutoNumberCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    super.key,
  });

  @override
  PlutoNumberCellState createState() => PlutoNumberCellState();
}

class PlutoNumberCellState extends State<PlutoNumberCell>
    with TextCellState<PlutoNumberCell> {
  late final int decimalRange;

  late final bool activatedNegative;

  late final bool allowFirstDot;

  late final String decimalSeparator;

  @override
  late final TextInputType keyboardType;

  @override
  late final List<TextInputFormatter>? inputFormatters;

  @override
  void initState() {
    super.initState();

    final numberColumn = widget.column.type.number;

    decimalRange = numberColumn.decimalPoint;

    activatedNegative = numberColumn.negative;

    allowFirstDot = numberColumn.allowFirstDot;

    decimalSeparator = numberColumn.numberFormat.symbols.DECIMAL_SEP;

    inputFormatters = [
      DecimalTextInputFormatter(
        decimalRange: decimalRange,
        activatedNegativeValues: activatedNegative,
        allowFirstDot: allowFirstDot,
        decimalSeparator: decimalSeparator,
      ),
    ];

    keyboardType = TextInputType.numberWithOptions(
      decimal: decimalRange > 0,
      signed: activatedNegative,
    );
  }
}
