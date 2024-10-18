import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show Intl;
import 'package:pluto_grid/pluto_grid.dart';

import 'helper/platform_helper.dart';
import 'ui/ui.dart';

typedef PlutoOnLoadedEventCallback = void Function(
    PlutoGridOnLoadedEvent event);

typedef PlutoOnChangedEventCallback = void Function(
    PlutoGridOnChangedEvent event);

typedef PlutoOnSelectedEventCallback = void Function(
    PlutoGridOnSelectedEvent event);

typedef PlutoOnSortedEventCallback = void Function(
    PlutoGridOnSortedEvent event);

typedef PlutoOnRowCheckedEventCallback = void Function(
    PlutoGridOnRowCheckedEvent event);

typedef PlutoOnRowDoubleTapEventCallback = void Function(
    PlutoGridOnRowDoubleTapEvent event);

typedef PlutoOnRowSecondaryTapEventCallback = void Function(
    PlutoGridOnRowSecondaryTapEvent event);

typedef PlutoOnRowsMovedEventCallback = void Function(
    PlutoGridOnRowsMovedEvent event);

typedef PlutoOnColumnsMovedEventCallback = void Function(
    PlutoGridOnColumnsMovedEvent event);

typedef CreateHeaderCallBack = Widget Function(
    PlutoGridStateManager stateManager);

typedef CreateFooterCallBack = Widget Function(
    PlutoGridStateManager stateManager);

typedef PlutoRowColorCallback = Color Function(
    PlutoRowColorContext rowColorContext);

/// [PlutoGrid] is a widget that receives columns and rows and is expressed as a grid-type UI.
///
/// [PlutoGrid] supports movement and editing with the keyboard,
/// Through various settings, it can be transformed and used in various UIs.
///
/// Pop-ups such as date selection, time selection,
/// and option selection used inside [PlutoGrid] are created with the API provided outside of [PlutoGrid].
/// Also, the popup to set the filter or column inside the grid is implemented through the setting of [PlutoGrid].
class PlutoGrid extends PlutoStatefulWidget {
  const PlutoGrid({
    Key? key,
    required this.columns,
    required this.rows,
    this.columnGroups,
    this.onLoaded,
    this.onChanged,
    this.onSelected,
    this.onSorted,
    this.onRowChecked,
    this.onRowDoubleTap,
    this.onRowSecondaryTap,
    this.onRowsMoved,
    this.onColumnsMoved,
    this.createHeader,
    this.createFooter,
    this.noRowsWidget,
    this.rowColorCallback,
    this.columnMenuDelegate,
    this.configuration = const PlutoGridConfiguration(),
    this.notifierFilterResolver,
    this.mode = PlutoGridMode.normal,
  }) : super(key: key);

  /// {@template pluto_grid_property_columns}
  /// The [PlutoColumn] column is delivered as a list and can be added or deleted after grid creation.
  ///
  /// Columns can be added or deleted
  /// with [PlutoGridStateManager.insertColumns] and [PlutoGridStateManager.removeColumns].
  ///
  /// Each [PlutoColumn.field] value in [List] must be unique.
  /// [PlutoColumn.field] must be provided to match the map key in [PlutoRow.cells].
  /// should also be provided to match in [PlutoColumnGroup.fields] as well.
  /// {@endtemplate}
  final List<PlutoColumn> columns;

  /// {@template pluto_grid_property_rows}
  /// [rows] contains a call to the [PlutoGridStateManager.initializeRows] method
  /// that handles necessary settings when creating a grid or when a new row is added.
  ///
  /// CPU operation is required as much as [rows.length] multiplied by the number of [PlutoRow.cells].
  /// No problem under normal circumstances, but if there are many rows and columns,
  /// the UI may freeze at the start of the grid.
  /// In this case, the grid is started by passing an empty list to rows
  /// and after the [PlutoGrid.onLoaded] callback is called
  /// Rows initialization can be done asynchronously with [PlutoGridStateManager.initializeRowsAsync] .
  ///
  /// ```dart
  /// stateManager.setShowLoading(true);
  ///
  /// PlutoGridStateManager.initializeRowsAsync(
  ///   columns,
  ///   fetchedRows,
  /// ).then((value) {
  ///   stateManager.refRows.addAll(value);
  ///
  ///   /// In this example,
  ///   /// the loading screen is activated in the onLoaded callback when the grid is created.
  ///   /// If the loading screen is not activated
  ///   /// You must update the grid state by calling the stateManager.notifyListeners() method.
  ///   /// Because calling setShowLoading updates the grid state
  ///   /// No need to call stateManager.notifyListeners.
  ///   stateManager.setShowLoading(false);
  /// });
  /// ```
  /// {@endtemplate}
  final List<PlutoRow> rows;

  /// {@template pluto_grid_property_columnGroups}
  /// [columnGroups] can be expressed in UI by grouping columns.
  /// {@endtemplate}
  final List<PlutoColumnGroup>? columnGroups;

  /// {@template pluto_grid_property_onLoaded}
  /// [PlutoGrid] completes setting and passes [PlutoGridStateManager] to [event].
  ///
  /// When the [PlutoGrid] starts,
  /// the desired setting can be made through [PlutoGridStateManager].
  ///
  /// ex) Change the selection mode to cell selection.
  /// ```dart
  /// onLoaded: (PlutoGridOnLoadedEvent event) {
  ///   event.stateManager.setSelectingMode(PlutoGridSelectingMode.cell);
  /// },
  /// ```
  /// {@endtemplate}
  final PlutoOnLoadedEventCallback? onLoaded;

  /// {@template pluto_grid_property_onChanged}
  /// [onChanged] is called when the cell value changes.
  ///
  /// When changing the cell value directly programmatically
  /// with the [PlutoGridStateManager.changeCellValue] method
  /// When changing the value by calling [callOnChangedEvent]
  /// as false as the parameter of [PlutoGridStateManager.changeCellValue]
  /// The [onChanged] callback is not called.
  /// {@endtemplate}
  final PlutoOnChangedEventCallback? onChanged;

  /// {@template pluto_grid_property_onSelected}
  /// [onSelected] can receive a response only if [PlutoGrid.mode] is set to [PlutoGridMode.select] .
  ///
  /// When a row is tapped or the Enter key is pressed, the row information can be returned.
  /// When [PlutoGrid] is used for row selection, you can use [PlutoGridMode.select] .
  /// Basically, in [PlutoGridMode.select], the [onLoaded] callback works
  /// when the current selected row is tapped or the Enter key is pressed.
  /// This will require a double tap if no row is selected.
  /// In [PlutoGridMode.selectWithOneTap], the [onLoaded] callback works when the unselected row is tapped once.
  /// {@endtemplate}
  final PlutoOnSelectedEventCallback? onSelected;

  /// {@template pluto_grid_property_onSorted}
  /// [onSorted] is a callback that is called when column sorting is changed.
  /// {@endtemplate}
  final PlutoOnSortedEventCallback? onSorted;

  /// {@template pluto_grid_property_onRowChecked}
  /// [onRowChecked] can receive the check status change of the checkbox
  /// when [PlutoColumn.enableRowChecked] is enabled.
  /// {@endtemplate}
  final PlutoOnRowCheckedEventCallback? onRowChecked;

  /// {@template pluto_grid_property_onRowDoubleTap}
  /// [onRowDoubleTap] is called when a row is tapped twice in a row.
  /// {@endtemplate}
  final PlutoOnRowDoubleTapEventCallback? onRowDoubleTap;

  /// {@template pluto_grid_property_onRowSecondaryTap}
  /// [onRowSecondaryTap] is called when a mouse right-click event occurs.
  /// {@endtemplate}
  final PlutoOnRowSecondaryTapEventCallback? onRowSecondaryTap;

  /// {@template pluto_grid_property_onRowsMoved}
  /// [onRowsMoved] is called after the row is dragged and moved
  /// if [PlutoColumn.enableRowDrag] is enabled.
  /// {@endtemplate}
  final PlutoOnRowsMovedEventCallback? onRowsMoved;

  /// {@template pluto_grid_property_onColumnsMoved}
  /// Callback for receiving events
  /// when the column is moved by dragging the column
  /// or frozen it to the left or right.
  /// {@endtemplate}
  final PlutoOnColumnsMovedEventCallback? onColumnsMoved;

  /// {@template pluto_grid_property_createHeader}
  /// [createHeader] is a user-definable area located above the upper column area of [PlutoGrid].
  ///
  /// Just pass a callback that returns [Widget] .
  /// Assuming you created a widget called Header.
  /// ```dart
  /// createHeader: (stateManager) {
  ///   stateManager.headerHeight = 45;
  ///   return Header(
  ///     stateManager: stateManager,
  ///   );
  /// },
  /// ```
  ///
  /// If the widget returned to the callback detects the state and updates the UI,
  /// register the callback in [PlutoGridStateManager.addListener]
  /// and update the UI with [StatefulWidget.setState], etc.
  /// The listener callback registered with [PlutoGridStateManager.addListener]
  /// must remove the listener callback with [PlutoGridStateManager.removeListener]
  /// when the widget returned by the callback is dispose.
  /// {@endtemplate}
  final CreateHeaderCallBack? createHeader;

  /// {@template pluto_grid_property_createFooter}
  /// [createFooter] is equivalent to [createHeader].
  /// However, it is located at the bottom of the grid.
  ///
  /// [CreateFooter] can also be passed an already provided widget for Pagination.
  /// Of course you can pass it to [createHeader] , but it's not a typical UI.
  /// ```dart
  /// createFooter: (stateManager) {
  ///   stateManager.setPageSize(100, notify: false); // default 40
  ///   return PlutoPagination(stateManager);
  /// },
  /// ```
  /// {@endtemplate}
  final CreateFooterCallBack? createFooter;

  /// {@template pluto_grid_property_noRowsWidget}
  /// Widget to be shown if there are no rows.
  ///
  /// Create a widget like the one below and pass it to [PlutoGrid.noRowsWidget].
  /// ```dart
  /// class _NoRows extends StatelessWidget {
  ///   const _NoRows({Key? key}) : super(key: key);
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return IgnorePointer(
  ///       child: Center(
  ///         child: DecoratedBox(
  ///           decoration: BoxDecoration(
  ///             color: Colors.white,
  ///             border: Border.all(),
  ///             borderRadius: const BorderRadius.all(Radius.circular(5)),
  ///           ),
  ///           child: Padding(
  ///             padding: const EdgeInsets.all(10),
  ///             child: Column(
  ///               mainAxisSize: MainAxisSize.min,
  ///               mainAxisAlignment: MainAxisAlignment.center,
  ///               children: const [
  ///                 Icon(Icons.info_outline),
  ///                 SizedBox(height: 5),
  ///                 Text('There are no records'),
  ///               ],
  ///             ),
  ///           ),
  ///         ),
  ///       ),
  ///     );
  ///   }
  /// }
  /// ```
  /// {@endtemplate}
  final Widget? noRowsWidget;

  /// {@template pluto_grid_property_rowColorCallback}
  /// [rowColorCallback] can change the row background color dynamically according to the state.
  ///
  /// Implement a callback that returns a [Color] by referring to the value passed as a callback argument.
  /// An exception should be handled when a column is deleted.
  /// ```dart
  /// rowColorCallback = (PlutoRowColorContext rowColorContext) {
  ///   return rowColorContext.row.cells['column2']?.value == 'green'
  ///       ? const Color(0xFFE2F6DF)
  ///       : Colors.white;
  /// }
  /// ```
  /// {@endtemplate}
  final PlutoRowColorCallback? rowColorCallback;

  /// {@template pluto_grid_property_columnMenuDelegate}
  /// Column menu can be customized.
  ///
  /// See the demo example link below.
  /// https://github.com/bosskmk/pluto_grid/blob/master/demo/lib/screen/feature/column_menu_screen.dart
  /// {@endtemplate}
  final PlutoColumnMenuDelegate? columnMenuDelegate;

  /// {@template pluto_grid_property_configuration}
  /// In [configuration], you can change the style and settings or text used in [PlutoGrid].
  /// {@endtemplate}
  final PlutoGridConfiguration configuration;

  final PlutoChangeNotifierFilterResolver? notifierFilterResolver;

  /// Execution mode of [PlutoGrid].
  ///
  /// [PlutoGridMode.normal]
  /// {@macro pluto_grid_mode_normal}
  ///
  /// [PlutoGridMode.readOnly]
  /// {@macro pluto_grid_mode_readOnly}
  ///
  /// [PlutoGridMode.select], [PlutoGridMode.selectWithOneTap]
  /// {@macro pluto_grid_mode_select}
  ///
  /// [PlutoGridMode.multiSelect]
  /// {@macro pluto_grid_mode_multiSelect}
  ///
  /// [PlutoGridMode.popup]
  /// {@macro pluto_grid_mode_popup}
  final PlutoGridMode mode;

  /// [setDefaultLocale] sets locale when [Intl] package is used in [PlutoGrid].
  ///
  /// {@template intl_default_locale}
  /// ```dart
  /// PlutoGrid.setDefaultLocale('es_ES');
  /// PlutoGrid.initializeDateFormat();
  ///
  /// // or if you already use Intl in your app.
  ///
  /// Intl.defaultLocale = 'es_ES';
  /// initializeDateFormatting();
  /// ```
  /// {@endtemplate}
  static setDefaultLocale(String locale) {
    Intl.defaultLocale = locale;
  }

  /// [initializeDateFormat] should be called
  /// when you need to set date format when changing locale.
  ///
  /// {@macro intl_default_locale}
  static initializeDateFormat() {
    initializeDateFormatting();
  }

  @override
  PlutoGridState createState() => PlutoGridState();
}

class PlutoGridState extends PlutoStateWithChange<PlutoGrid> {
  bool _showColumnTitle = false;

  bool _showColumnFilter = false;

  bool _showColumnFooter = false;

  bool _showColumnGroups = false;

  bool _showFrozenColumn = false;

  bool _showLoading = false;

  bool _hasLeftFrozenColumns = false;

  bool _hasRightFrozenColumns = false;

  double _bodyLeftOffset = 0.0;

  double _bodyRightOffset = 0.0;

  double _rightFrozenLeftOffset = 0.0;

  Widget? _header;

  Widget? _footer;

  final FocusNode _gridFocusNode = FocusNode();

  final LinkedScrollControllerGroup _verticalScroll =
      LinkedScrollControllerGroup();

  final LinkedScrollControllerGroup _horizontalScroll =
      LinkedScrollControllerGroup();

  final List<Function()> _disposeList = [];

  late final PlutoGridStateManager _stateManager;

  late final PlutoGridKeyManager _keyManager;

  late final PlutoGridEventManager _eventManager;

  @override
  PlutoGridStateManager get stateManager => _stateManager;

  @override
  void initState() {
    _initStateManager();

    _initKeyManager();

    _initEventManager();

    _initOnLoadedEvent();

    _initSelectMode();

    _initHeaderFooter();

    _disposeList.add(() {
      _gridFocusNode.dispose();
    });

    super.initState();
  }

  @override
  void dispose() {
    for (var dispose in _disposeList) {
      dispose();
    }

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PlutoGrid oldWidget) {
    super.didUpdateWidget(oldWidget);

    stateManager
      ..setConfiguration(widget.configuration)
      ..setGridMode(widget.mode);
  }

  @override
  void updateState(PlutoNotifierEvent event) {
    _showColumnTitle = update<bool>(
      _showColumnTitle,
      stateManager.showColumnTitle,
    );

    _showColumnFilter = update<bool>(
      _showColumnFilter,
      stateManager.showColumnFilter,
    );

    _showColumnFooter = update<bool>(
      _showColumnFooter,
      stateManager.showColumnFooter,
    );

    _showColumnGroups = update<bool>(
      _showColumnGroups,
      stateManager.showColumnGroups,
    );

    _showFrozenColumn = update<bool>(
      _showFrozenColumn,
      stateManager.showFrozenColumn,
    );

    _showLoading = update<bool>(
      _showLoading,
      stateManager.showLoading,
    );

    _hasLeftFrozenColumns = update<bool>(
      _hasLeftFrozenColumns,
      stateManager.hasLeftFrozenColumns,
    );

    _hasRightFrozenColumns = update<bool>(
      _hasRightFrozenColumns,
      stateManager.hasRightFrozenColumns,
    );

    _bodyLeftOffset = update<double>(
      _bodyLeftOffset,
      stateManager.bodyLeftOffset,
    );

    _bodyRightOffset = update<double>(
      _bodyRightOffset,
      stateManager.bodyRightOffset,
    );

    _rightFrozenLeftOffset = update<double>(
      _rightFrozenLeftOffset,
      stateManager.rightFrozenLeftOffset,
    );
  }

  void _initStateManager() {
    _stateManager = PlutoGridStateManager(
      columns: widget.columns,
      rows: widget.rows,
      gridFocusNode: _gridFocusNode,
      scroll: PlutoGridScrollController(
        vertical: _verticalScroll,
        horizontal: _horizontalScroll,
      ),
      columnGroups: widget.columnGroups,
      onChanged: widget.onChanged,
      onSelected: widget.onSelected,
      onSorted: widget.onSorted,
      onRowChecked: widget.onRowChecked,
      onRowDoubleTap: widget.onRowDoubleTap,
      onRowSecondaryTap: widget.onRowSecondaryTap,
      onRowsMoved: widget.onRowsMoved,
      onColumnsMoved: widget.onColumnsMoved,
      rowColorCallback: widget.rowColorCallback,
      createHeader: widget.createHeader,
      createFooter: widget.createFooter,
      columnMenuDelegate: widget.columnMenuDelegate,
      notifierFilterResolver: widget.notifierFilterResolver,
      configuration: widget.configuration,
      mode: widget.mode,
    );

    // Dispose
    _disposeList.add(() {
      _stateManager.dispose();
    });
  }

  void _initKeyManager() {
    _keyManager = PlutoGridKeyManager(
      stateManager: _stateManager,
    );

    _keyManager.init();

    _stateManager.setKeyManager(_keyManager);

    // Dispose
    _disposeList.add(() {
      _keyManager.dispose();
    });
  }

  void _initEventManager() {
    _eventManager = PlutoGridEventManager(
      stateManager: _stateManager,
    );

    _eventManager.init();

    _stateManager.setEventManager(_eventManager);

    // Dispose
    _disposeList.add(() {
      _eventManager.dispose();
    });
  }

  void _initOnLoadedEvent() {
    if (widget.onLoaded == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onLoaded!(PlutoGridOnLoadedEvent(stateManager: _stateManager));
    });
  }

  void _initSelectMode() {
    if (!widget.mode.isSelectMode) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_stateManager.currentCell == null) {
        _stateManager.setCurrentCell(_stateManager.firstCell, 0);
      }

      _stateManager.gridFocusNode.requestFocus();
    });
  }

  void _initHeaderFooter() {
    if (_stateManager.showHeader) {
      _header = _stateManager.createHeader!(_stateManager);
    }

    if (_stateManager.showFooter) {
      _footer = _stateManager.createFooter!(_stateManager);
    }

    if (_header is PlutoPagination || _footer is PlutoPagination) {
      _stateManager.setPage(1, notify: false);
    }
  }

  KeyEventResult _handleGridFocusOnKey(FocusNode focusNode, RawKeyEvent event) {
    if (_keyManager.eventResult.isSkip == false) {
      _keyManager.subject.add(PlutoKeyManagerEvent(
        focusNode: focusNode,
        event: event,
      ));
    }

    return _keyManager.eventResult.consume(KeyEventResult.handled);
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      onFocusChange: _stateManager.setKeepFocus,
      onKey: _handleGridFocusOnKey,
      child: _GridContainer(
        stateManager: _stateManager,
        child: LayoutBuilder(
          builder: (c, size) {
            _stateManager.setLayout(size);

            final style = _stateManager.style;

            final bool showLeftFrozen = _stateManager.showFrozenColumn &&
                _stateManager.hasLeftFrozenColumns;

            final bool showRightFrozen = _stateManager.showFrozenColumn &&
                _stateManager.hasRightFrozenColumns;

            final bool showColumnRowDivider =
                _stateManager.showColumnTitle || _stateManager.showColumnFilter;

            final bool showColumnFooter = _stateManager.showColumnFooter;

            return CustomMultiChildLayout(
              key: _stateManager.gridKey,
              delegate: PlutoGridLayoutDelegate(
                _stateManager,
                Directionality.of(context),
              ),
              children: [
                /// Body columns and rows.
                LayoutId(
                  id: _StackName.bodyRows,
                  child: PlutoBodyRows(_stateManager),
                ),
                LayoutId(
                  id: _StackName.bodyColumns,
                  child: PlutoBodyColumns(_stateManager),
                ),

                /// Body columns footer.
                if (showColumnFooter)
                  LayoutId(
                    id: _StackName.bodyColumnFooters,
                    child: PlutoBodyColumnsFooter(stateManager),
                  ),

                /// Left columns and rows.
                if (showLeftFrozen) ...[
                  LayoutId(
                    id: _StackName.leftFrozenColumns,
                    child: PlutoLeftFrozenColumns(_stateManager),
                  ),
                  LayoutId(
                      id: _StackName.leftFrozenRows,
                      child: PlutoLeftFrozenRows(_stateManager)),
                  LayoutId(
                    id: _StackName.leftFrozenDivider,
                    child: PlutoShadowLine(
                      axis: Axis.vertical,
                      color: style.gridBorderColor,
                      shadow: style.enableGridBorderShadow,
                    ),
                  ),
                  if (showColumnFooter)
                    LayoutId(
                      id: _StackName.leftFrozenColumnFooters,
                      child: PlutoLeftFrozenColumnsFooter(stateManager),
                    ),
                ],

                /// Right columns and rows.
                if (showRightFrozen) ...[
                  LayoutId(
                    id: _StackName.rightFrozenColumns,
                    child: PlutoRightFrozenColumns(_stateManager),
                  ),
                  LayoutId(
                      id: _StackName.rightFrozenRows,
                      child: PlutoRightFrozenRows(_stateManager)),
                  LayoutId(
                    id: _StackName.rightFrozenDivider,
                    child: PlutoShadowLine(
                      axis: Axis.vertical,
                      color: style.gridBorderColor,
                      shadow: style.enableGridBorderShadow,
                      reverse: true,
                    ),
                  ),
                  if (showColumnFooter)
                    LayoutId(
                      id: _StackName.rightFrozenColumnFooters,
                      child: PlutoRightFrozenColumnsFooter(stateManager),
                    ),
                ],

                /// Column and row divider.
                if (showColumnRowDivider)
                  LayoutId(
                    id: _StackName.columnRowDivider,
                    child: PlutoShadowLine(
                      axis: Axis.horizontal,
                      color: style.gridBorderColor,
                      shadow: style.enableGridBorderShadow,
                    ),
                  ),

                /// Header and divider.
                if (_stateManager.showHeader) ...[
                  LayoutId(
                    id: _StackName.headerDivider,
                    child: PlutoShadowLine(
                      axis: Axis.horizontal,
                      color: style.gridBorderColor,
                      shadow: style.enableGridBorderShadow,
                    ),
                  ),
                  LayoutId(
                    id: _StackName.header,
                    child: _header!,
                  ),
                ],

                /// Column footer divider.
                if (showColumnFooter)
                  LayoutId(
                    id: _StackName.columnFooterDivider,
                    child: PlutoShadowLine(
                      axis: Axis.horizontal,
                      color: style.gridBorderColor,
                      shadow: style.enableGridBorderShadow,
                    ),
                  ),

                /// Footer and divider.
                if (_stateManager.showFooter) ...[
                  LayoutId(
                    id: _StackName.footerDivider,
                    child: PlutoShadowLine(
                      axis: Axis.horizontal,
                      color: style.gridBorderColor,
                      shadow: style.enableGridBorderShadow,
                      reverse: true,
                    ),
                  ),
                  LayoutId(
                    id: _StackName.footer,
                    child: _footer!,
                  ),
                ],

                /// Loading screen.
                if (_stateManager.showLoading)
                  LayoutId(
                    id: _StackName.loading,
                    child: PlutoLoading(
                      level: _stateManager.loadingLevel,
                      backgroundColor: style.gridBackgroundColor,
                      indicatorColor: style.activatedBorderColor,
                      text: _stateManager.localeText.loadingText,
                      textStyle: style.cellTextStyle,
                    ),
                  ),

                /// NoRows
                if (widget.noRowsWidget != null)
                  LayoutId(
                    id: _StackName.noRows,
                    child: PlutoNoRowsWidget(
                      stateManager: _stateManager,
                      child: widget.noRowsWidget!,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class PlutoGridLayoutDelegate extends MultiChildLayoutDelegate {
  final PlutoGridStateManager _stateManager;

  final TextDirection _textDirection;

  PlutoGridLayoutDelegate(this._stateManager, this._textDirection)
      : super(relayout: _stateManager.resizingChangeNotifier) {
    // set textDirection before the first frame is laid-out
    _stateManager.setTextDirection(_textDirection);
  }

  @override
  void performLayout(Size size) {
    bool isLTR = _stateManager.isLTR;
    double bodyRowsTopOffset = 0;
    double bodyRowsBottomOffset = 0;
    double columnsTopOffset = 0;
    double bodyLeftOffset = 0;
    double bodyRightOffset = 0;

    // first layout header and footer and see what remains for the scrolling part
    if (hasChild(_StackName.header)) {
      // maximum 40% of the height
      var s = layoutChild(
        _StackName.header,
        BoxConstraints.loose(Size(size.width, _safe(size.height / 100 * 40))),
      );

      _stateManager.headerHeight = s.height;

      bodyRowsTopOffset += s.height;

      columnsTopOffset += s.height;
    }

    if (hasChild(_StackName.headerDivider)) {
      layoutChild(
        _StackName.headerDivider,
        BoxConstraints.tight(
          Size(size.width, PlutoGridSettings.gridBorderWidth),
        ),
      );

      positionChild(
        _StackName.headerDivider,
        Offset(0, columnsTopOffset),
      );
    }

    if (hasChild(_StackName.footer)) {
      // maximum 40% of the height
      var s = layoutChild(
        _StackName.footer,
        BoxConstraints.loose(Size(size.width, _safe(size.height / 100 * 40))),
      );

      _stateManager.footerHeight = s.height;

      bodyRowsBottomOffset += s.height;

      positionChild(
        _StackName.footer,
        Offset(0, size.height - bodyRowsBottomOffset),
      );
    }

    if (hasChild(_StackName.footerDivider)) {
      layoutChild(
        _StackName.footerDivider,
        BoxConstraints.tight(
          Size(size.width, PlutoGridSettings.gridBorderWidth),
        ),
      );

      positionChild(
        _StackName.footerDivider,
        Offset(0, size.height - bodyRowsBottomOffset),
      );
    }

    // now layout columns of frozen sides and see what remains for the body width
    if (hasChild(_StackName.leftFrozenColumns)) {
      var s = layoutChild(
        _StackName.leftFrozenColumns,
        BoxConstraints.loose(size),
      );

      final double posX = isLTR ? 0 : size.width - s.width;

      positionChild(
        _StackName.leftFrozenColumns,
        Offset(posX, columnsTopOffset),
      );

      if (isLTR) {
        bodyLeftOffset = s.width;
      } else {
        bodyRightOffset = s.width;
      }
    }

    if (hasChild(_StackName.leftFrozenDivider)) {
      var s = layoutChild(
        _StackName.leftFrozenDivider,
        BoxConstraints.tight(
          Size(
            PlutoGridSettings.gridBorderWidth,
            _safe(size.height - columnsTopOffset - bodyRowsBottomOffset),
          ),
        ),
      );

      final double posX = isLTR
          ? bodyLeftOffset
          : size.width - bodyRightOffset - PlutoGridSettings.gridBorderWidth;

      positionChild(
        _StackName.leftFrozenDivider,
        Offset(posX, columnsTopOffset),
      );

      if (isLTR) {
        bodyLeftOffset += s.width;
      } else {
        bodyRightOffset += s.width;
      }
    }

    if (hasChild(_StackName.rightFrozenColumns)) {
      var s = layoutChild(
        _StackName.rightFrozenColumns,
        BoxConstraints.loose(size),
      );

      final double posX =
          isLTR ? size.width - s.width + PlutoGridSettings.gridBorderWidth : 0;

      positionChild(
        _StackName.rightFrozenColumns,
        Offset(posX, columnsTopOffset),
      );

      if (isLTR) {
        bodyRightOffset = s.width;
      } else {
        bodyLeftOffset = s.width;
      }
    }

    if (hasChild(_StackName.rightFrozenDivider)) {
      var s = layoutChild(
        _StackName.rightFrozenDivider,
        BoxConstraints.tight(
          Size(
            PlutoGridSettings.gridBorderWidth,
            _safe(size.height - columnsTopOffset - bodyRowsBottomOffset),
          ),
        ),
      );

      final double posX = isLTR
          ? size.width - bodyRightOffset - PlutoGridSettings.gridBorderWidth
          : bodyLeftOffset;

      positionChild(
        _StackName.rightFrozenDivider,
        Offset(posX, columnsTopOffset),
      );

      if (isLTR) {
        bodyRightOffset += s.width;
      } else {
        bodyLeftOffset += s.width;
      }
    }

    if (hasChild(_StackName.bodyColumns)) {
      var s = layoutChild(
        _StackName.bodyColumns,
        BoxConstraints.loose(
          Size(
            _safe(size.width - bodyLeftOffset - bodyRightOffset),
            size.height,
          ),
        ),
      );

      final double posX =
          isLTR ? bodyLeftOffset : size.width - s.width - bodyRightOffset;

      positionChild(
        _StackName.bodyColumns,
        Offset(posX, columnsTopOffset),
      );

      bodyRowsTopOffset += s.height;
    }

    if (hasChild(_StackName.bodyColumnFooters)) {
      var s = layoutChild(
        _StackName.bodyColumnFooters,
        BoxConstraints.loose(
          Size(
            _safe(size.width - bodyLeftOffset - bodyRightOffset),
            size.height,
          ),
        ),
      );

      _stateManager.columnFooterHeight = s.height;

      final double posX =
          isLTR ? bodyLeftOffset : size.width - s.width - bodyRightOffset;

      positionChild(
        _StackName.bodyColumnFooters,
        Offset(posX, size.height - bodyRowsBottomOffset - s.height),
      );

      bodyRowsBottomOffset += s.height;
    }

    if (hasChild(_StackName.columnFooterDivider)) {
      var s = layoutChild(
        _StackName.columnFooterDivider,
        BoxConstraints.tight(
          Size(size.width, PlutoGridSettings.gridBorderWidth),
        ),
      );

      positionChild(
        _StackName.columnFooterDivider,
        Offset(0, size.height - bodyRowsBottomOffset - s.height),
      );
    }

    // layout rows
    if (hasChild(_StackName.columnRowDivider)) {
      var s = layoutChild(
        _StackName.columnRowDivider,
        BoxConstraints.tight(
          Size(size.width, PlutoGridSettings.gridBorderWidth),
        ),
      );

      positionChild(
        _StackName.columnRowDivider,
        Offset(0, bodyRowsTopOffset),
      );

      bodyRowsTopOffset += s.height;
    } else {
      bodyRowsTopOffset += PlutoGridSettings.gridBorderWidth;
    }

    if (hasChild(_StackName.leftFrozenRows)) {
      final double offset = isLTR ? bodyLeftOffset : bodyRightOffset;
      final double posX = isLTR
          ? 0
          : size.width - bodyRightOffset + PlutoGridSettings.gridBorderWidth;

      layoutChild(
        _StackName.leftFrozenRows,
        BoxConstraints.loose(
          Size(
            offset,
            _safe(size.height - bodyRowsTopOffset - bodyRowsBottomOffset),
          ),
        ),
      );

      positionChild(
        _StackName.leftFrozenRows,
        Offset(posX, bodyRowsTopOffset),
      );
    }

    if (hasChild(_StackName.leftFrozenColumnFooters)) {
      final double offset = isLTR ? bodyLeftOffset : bodyRightOffset;
      final double posX = isLTR
          ? 0
          : size.width - bodyRightOffset + PlutoGridSettings.gridBorderWidth;

      layoutChild(
        _StackName.leftFrozenColumnFooters,
        BoxConstraints.loose(
          Size(offset, _safe(size.height - bodyRowsBottomOffset)),
        ),
      );

      positionChild(
        _StackName.leftFrozenColumnFooters,
        Offset(posX, size.height - bodyRowsBottomOffset),
      );
    }

    if (hasChild(_StackName.rightFrozenRows)) {
      final double offset = isLTR ? bodyRightOffset : bodyLeftOffset;
      final double posX = isLTR
          ? size.width - bodyRightOffset + PlutoGridSettings.gridBorderWidth
          : 0;

      layoutChild(
        _StackName.rightFrozenRows,
        BoxConstraints.loose(
          Size(
            offset,
            _safe(size.height - bodyRowsTopOffset - bodyRowsBottomOffset),
          ),
        ),
      );

      positionChild(
        _StackName.rightFrozenRows,
        Offset(posX, bodyRowsTopOffset),
      );
    }

    if (hasChild(_StackName.rightFrozenColumnFooters)) {
      final double offset = isLTR ? bodyRightOffset : bodyLeftOffset;
      var s = layoutChild(
        _StackName.rightFrozenColumnFooters,
        BoxConstraints.loose(Size(offset, size.height)),
      );

      final double posX =
          isLTR ? size.width - s.width + PlutoGridSettings.gridBorderWidth : 0;

      positionChild(
        _StackName.rightFrozenColumnFooters,
        Offset(posX, size.height - bodyRowsBottomOffset),
      );
    }

    if (hasChild(_StackName.bodyRows)) {
      layoutChild(
        _StackName.bodyRows,
        BoxConstraints.tight(Size(
          _safe(size.width - bodyLeftOffset - bodyRightOffset),
          _safe(
            size.height - bodyRowsTopOffset - bodyRowsBottomOffset,
          ),
        )),
      );

      positionChild(
        _StackName.bodyRows,
        Offset(bodyLeftOffset, bodyRowsTopOffset),
      );
    }

    if (hasChild(_StackName.loading)) {
      Size loadingSize;

      switch (_stateManager.loadingLevel) {
        case PlutoGridLoadingLevel.grid:
          loadingSize = size;
          break;
        case PlutoGridLoadingLevel.rows:
          loadingSize = Size(size.width, 3);
          positionChild(
            _StackName.loading,
            Offset(0, bodyRowsTopOffset),
          );
          break;
        case PlutoGridLoadingLevel.rowsBottomCircular:
          loadingSize = const Size(30, 30);
          positionChild(
            _StackName.loading,
            Offset(
              (size.width / 2) + 15,
              size.height - bodyRowsBottomOffset - 45,
            ),
          );
          break;
      }

      layoutChild(
        _StackName.loading,
        BoxConstraints.tight(loadingSize),
      );
    }

    if (hasChild(_StackName.noRows)) {
      layoutChild(
        _StackName.noRows,
        BoxConstraints.loose(
          Size(
            size.width,
            _safe(size.height - bodyRowsTopOffset - bodyRowsBottomOffset),
          ),
        ),
      );

      positionChild(
        _StackName.noRows,
        Offset(0, bodyRowsTopOffset),
      );
    }
  }

  @override
  bool shouldRelayout(covariant PlutoGridLayoutDelegate oldDelegate) {
    return true;
  }

  double _safe(double value) => max(0, value);
}

class _GridContainer extends StatelessWidget {
  final PlutoGridStateManager stateManager;

  final Widget child;

  const _GridContainer({
    required this.stateManager,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = stateManager.style;

    final borderRadius = style.gridBorderRadius.resolve(TextDirection.ltr);

    return Focus(
      focusNode: stateManager.gridFocusNode,
      child: ScrollConfiguration(
        behavior: PlutoScrollBehavior(
          isMobile: PlatformHelper.isMobile,
          userDragDevices: stateManager.configuration.scrollbar.dragDevices,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: style.gridBackgroundColor,
            borderRadius: style.gridBorderRadius,
            border: Border.all(
              color: style.gridBorderColor,
              width: PlutoGridSettings.gridBorderWidth,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(PlutoGridSettings.gridPadding),
            child: borderRadius == BorderRadius.zero
                ? child
                : ClipRRect(borderRadius: borderRadius, child: child),
          ),
        ),
      ),
    );
  }
}

/// [PlutoGrid.onLoaded] Argument received by registering callback.
class PlutoGridOnLoadedEvent {
  final PlutoGridStateManager stateManager;

  const PlutoGridOnLoadedEvent({
    required this.stateManager,
  });
}

/// Event called when the value of [PlutoCell] is changed.
///
/// Notice.
/// [columnIdx], [rowIdx] are the values in the current screen state.
/// Values in their current state, not actual data values
/// with filtering, sorting, or pagination applied.
/// This value is from
/// [PlutoGridStateManager.columns] and [PlutoGridStateManager.rows].
///
/// All data is in
/// [PlutoGridStateManager.refColumns.originalList]
/// [PlutoGridStateManager.refRows.originalList]
class PlutoGridOnChangedEvent {
  final int columnIdx;
  final PlutoColumn column;
  final int rowIdx;
  final PlutoRow row;
  final dynamic value;
  final dynamic oldValue;

  const PlutoGridOnChangedEvent({
    required this.columnIdx,
    required this.column,
    required this.rowIdx,
    required this.row,
    this.value,
    this.oldValue,
  });

  @override
  String toString() {
    String out = '[PlutoOnChangedEvent] ';
    out += 'ColumnIndex : $columnIdx, RowIndex : $rowIdx\n';
    out += '::: oldValue : $oldValue\n';
    out += '::: newValue : $value';
    return out;
  }
}

/// This is the argument value of the [PlutoGrid.onSelected] callback
/// that is called when the [PlutoGrid.mode] value is in select mode.
///
/// If [row], [rowIdx], [cell] is [PlutoGridMode.select] or [PlutoGridMode.selectWithOneTap],
/// Information of the row selected with the tab or enter key.
/// If the Escape key is pressed, these values are null.
///
/// [selectedRows] is valid only in case of [PlutoGridMode.multiSelect].
/// If rows are selected by tab or keyboard, the selected rows are included.
/// If the Escape key is pressed, this value is null.
class PlutoGridOnSelectedEvent {
  final PlutoRow? row;
  final int? rowIdx;
  final PlutoCell? cell;
  final List<PlutoRow>? selectedRows;

  const PlutoGridOnSelectedEvent({
    this.row,
    this.rowIdx,
    this.cell,
    this.selectedRows,
  });

  @override
  String toString() {
    return '[PlutoGridOnSelectedEvent] rowIdx: $rowIdx, selectedRows: ${selectedRows?.length}';
  }
}

/// Argument of [PlutoGrid.onSorted] callback for receiving column sort change event.
class PlutoGridOnSortedEvent {
  final PlutoColumn column;

  final PlutoColumnSort oldSort;

  const PlutoGridOnSortedEvent({
    required this.column,
    required this.oldSort,
  });

  @override
  String toString() {
    return '[PlutoGridOnSortedEvent] ${column.title} (changed: ${column.sort}, old: $oldSort)';
  }
}

/// Argument of [PlutoGrid.onRowChecked] callback to receive row checkbox event.
///
/// [runtimeType] is [PlutoGridOnRowCheckedAllEvent] if [isAll] is true.
/// When [isAll] is true, it means the entire check button event of the column.
///
/// [runtimeType] is [PlutoGridOnRowCheckedOneEvent] if [isRow] is true.
/// If [isRow] is true, it means the check button event of a specific row.
abstract class PlutoGridOnRowCheckedEvent {
  bool get isAll => runtimeType == PlutoGridOnRowCheckedAllEvent;

  bool get isRow => runtimeType == PlutoGridOnRowCheckedOneEvent;

  final PlutoRow? row;
  final int? rowIdx;
  final bool? isChecked;

  const PlutoGridOnRowCheckedEvent({
    this.row,
    this.rowIdx,
    this.isChecked,
  });

  @override
  String toString() {
    String checkMessage = isAll ? 'All rows ' : 'RowIdx $rowIdx ';
    checkMessage += isChecked == true ? 'checked' : 'unchecked';
    return '[PlutoGridOnRowCheckedEvent] $checkMessage';
  }
}

/// Argument of [PlutoGrid.onRowChecked] callback when the checkbox of the row is tapped.
class PlutoGridOnRowCheckedOneEvent extends PlutoGridOnRowCheckedEvent {
  const PlutoGridOnRowCheckedOneEvent({
    required PlutoRow row,
    required int rowIdx,
    required bool? isChecked,
  }) : super(row: row, rowIdx: rowIdx, isChecked: isChecked);
}

/// Argument of [PlutoGrid.onRowChecked] callback when all checkboxes of the column are tapped.
class PlutoGridOnRowCheckedAllEvent extends PlutoGridOnRowCheckedEvent {
  const PlutoGridOnRowCheckedAllEvent({
    bool? isChecked,
  }) : super(row: null, rowIdx: null, isChecked: isChecked);
}

/// The argument of the [PlutoGrid.onRowDoubleTap] callback
/// to receive the event of double-tapping the row.
class PlutoGridOnRowDoubleTapEvent {
  final PlutoRow row;
  final int rowIdx;
  final PlutoCell cell;

  const PlutoGridOnRowDoubleTapEvent({
    required this.row,
    required this.rowIdx,
    required this.cell,
  });
}

/// Argument of the [PlutoGrid.onRowSecondaryTap] callback
/// to receive the event of tapping the row with the right mouse button.
class PlutoGridOnRowSecondaryTapEvent {
  final PlutoRow row;
  final int rowIdx;
  final PlutoCell cell;
  final Offset offset;

  const PlutoGridOnRowSecondaryTapEvent({
    required this.row,
    required this.rowIdx,
    required this.cell,
    required this.offset,
  });
}

/// Argument of [PlutoGrid.onRowsMoved] callback
/// to receive the event of moving the row by dragging it.
class PlutoGridOnRowsMovedEvent {
  final int idx;
  final List<PlutoRow> rows;

  const PlutoGridOnRowsMovedEvent({
    required this.idx,
    required this.rows,
  });
}

/// Argument of [PlutoGrid.onColumnsMoved] callback
/// to move columns by dragging or receive left or right fixed events.
///
/// [idx] means the actual index of
/// [PlutoGridStateManager.columns] or [PlutoGridStateManager.refColumns].
///
/// [visualIdx] means the order displayed on the screen, not the actual index.
/// For example, if there are 5 columns of [0, 1, 2, 3, 4]
/// If 1 column is frozen to the right, [visualIndex] becomes 4.
/// But the actual index is preserved.
class PlutoGridOnColumnsMovedEvent {
  final int idx;
  final int visualIdx;
  final List<PlutoColumn> columns;

  const PlutoGridOnColumnsMovedEvent({
    required this.idx,
    required this.visualIdx,
    required this.columns,
  });

  @override
  String toString() {
    String text =
        '[PlutoGridOnColumnsMovedEvent] idx: $idx, visualIdx: $visualIdx\n';

    text += columns.map((e) => e.title).join(',');

    return text;
  }
}

/// Argument of [PlutoGrid.rowColumnCallback] callback
/// to dynamically change the background color of a row.
class PlutoRowColorContext {
  final PlutoRow row;

  final int rowIdx;

  final PlutoGridStateManager stateManager;

  const PlutoRowColorContext({
    required this.row,
    required this.rowIdx,
    required this.stateManager,
  });
}

/// Extension class for [ScrollConfiguration.behavior] of [PlutoGrid].
class PlutoScrollBehavior extends MaterialScrollBehavior {
  const PlutoScrollBehavior({
    required this.isMobile,
    Set<PointerDeviceKind>? userDragDevices,
  })  : _dragDevices = userDragDevices ??
            (isMobile ? _mobileDragDevices : _desktopDragDevices),
        super();

  final bool isMobile;

  @override
  Set<PointerDeviceKind> get dragDevices => _dragDevices;

  final Set<PointerDeviceKind> _dragDevices;

  static const Set<PointerDeviceKind> _mobileDragDevices = {
    PointerDeviceKind.touch,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.unknown,
  };

  static const Set<PointerDeviceKind> _desktopDragDevices = {
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.unknown,
  };

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

/// A class for changing the value of a nullable property in a method such as [copyWith].
class PlutoOptional<T> {
  const PlutoOptional(this.value);

  final T? value;
}

abstract class PlutoGridSettings {
  /// If there is a frozen column, the minimum width of the body
  /// (if it is less than the value, the frozen column is released)
  static const double bodyMinWidth = 200.0;

  /// Default column width
  static const double columnWidth = 200.0;

  /// Column width
  static const double minColumnWidth = 80.0;

  /// Frozen column division line (ShadowLine) size
  static const double shadowLineSize = 3.0;

  /// Sum of frozen column division line width
  static const double totalShadowLineWidth =
      PlutoGridSettings.shadowLineSize * 2;

  /// Grid - padding
  static const double gridPadding = 2.0;

  /// Grid - border width
  static const double gridBorderWidth = 1.0;

  static const double gridInnerSpacing =
      (gridPadding * 2) + (gridBorderWidth * 2);

  /// Row - Default row height
  static const double rowHeight = 45.0;

  /// Row - border width
  static const double rowBorderWidth = 1.0;

  /// Row - total height
  static const double rowTotalHeight = rowHeight + rowBorderWidth;

  /// Cell - padding
  static const EdgeInsets cellPadding = EdgeInsets.symmetric(horizontal: 10);

  /// Column title - padding
  static const EdgeInsets columnTitlePadding =
      EdgeInsets.symmetric(horizontal: 10);

  static const EdgeInsets columnFilterPadding = EdgeInsets.all(5);

  /// Cell - fontSize
  static const double cellFontSize = 14;

  /// Scroll when multi-selection is as close as that value from the edge
  static const double offsetScrollingFromEdge = 10.0;

  /// Size that scrolls from the edge at once when selecting multiple
  static const double offsetScrollingFromEdgeAtOnce = 200.0;

  static const int debounceMillisecondsForColumnFilter = 300;
}

enum PlutoGridMode {
  /// {@template pluto_grid_mode_normal}
  /// Basic mode with most functions not limited, such as editing and selection.
  /// {@endtemplate}
  normal,

  /// {@template pluto_grid_mode_readOnly}
  /// Cell cannot be edited.
  /// To try to edit by force, it is possible as follows.
  ///
  /// ```dart
  /// stateManager.changeCellValue(
  ///   stateManager.currentCell!,
  ///   'test',
  ///   force: true,
  /// );
  /// ```
  /// {@endtemplate}
  readOnly,

  /// {@template pluto_grid_mode_select}
  /// Mode for selecting one list from a specific list.
  /// Tap a row or press Enter to select the current row.
  ///
  /// [select]
  /// Call the [PlutoGrid.onSelected] callback when the selected row is tapped.
  /// To select an unselected row, select the row and then tap once more.
  /// [selectWithOneTap]
  /// Same as [select], but calls [PlutoGrid.onSelected] with one tap.
  ///
  /// This mode is non-editable, but programmatically possible.
  /// ```dart
  /// stateManager.changeCellValue(
  ///   stateManager.currentRow!.cells['column_1']!,
  ///   value,
  ///   force: true,
  /// );
  /// ```
  /// {@endtemplate}
  select,

  /// {@macro pluto_grid_mode_select}
  selectWithOneTap,

  /// {@template pluto_grid_mode_multiSelect}
  /// Mode to select multiple rows.
  /// When a row is tapped, it is selected or deselected and the [PlutoGrid.onSelected] callback is called.
  /// [PlutoGridOnSelectedEvent.selectedRows] contains the selected rows.
  /// When a row is selected with keyboard shift + arrowDown/Up keys,
  /// the [PlutoGrid.onSelected] callback is called only when the Enter key is pressed.
  /// When the Escape key is pressed,
  /// the selected row is canceled and the [PlutoGrid.onSelected] callback is called
  /// with a [PlutoGridOnSelectedEvent.selectedRows] value of null.
  /// {@endtemplate}
  multiSelect,

  /// {@template pluto_grid_mode_popup}
  /// This is a mode for popup type.
  /// It is used when calling a popup for filtering or column setting
  /// inside [PlutoGrid], and it is not a mode for users.
  ///
  /// If the user wants to run [PlutoGrid] as a popup,
  /// use [PlutoGridPopup] or [PlutoGridDualGridPopup].
  /// {@endtemplate}
  popup;

  bool get isNormal => this == PlutoGridMode.normal;

  bool get isReadOnly => this == PlutoGridMode.readOnly;

  bool get isEditableMode => isNormal || isPopup;

  bool get isSelectMode => isSingleSelectMode || isMultiSelectMode;

  bool get isSingleSelectMode => isSelect || isSelectWithOneTap;

  bool get isMultiSelectMode => isMultiSelect;

  bool get isSelect => this == PlutoGridMode.select;

  bool get isSelectWithOneTap => this == PlutoGridMode.selectWithOneTap;

  bool get isMultiSelect => this == PlutoGridMode.multiSelect;

  bool get isPopup => this == PlutoGridMode.popup;
}

/// When calling loading screen with [PlutoGridStateManager.setShowLoading] method
/// Determines the level of loading.
///
/// {@template pluto_grid_loading_level_grid}
/// [grid] makes the entire grid opaque and puts the loading indicator in the center.
/// The user is in a state where no interaction is possible.
/// {@endtemplate}
///
/// {@template pluto_grid_loading_level_rows}
/// [rows] represents the [LinearProgressIndicator] at the top of the widget area
/// that displays the rows.
/// User can interact.
/// {@endtemplate}
///
/// {@template pluto_grid_loading_level_rowsBottomCircular}
/// [rowsBottomCircular] represents the [CircularProgressIndicator] at the bottom of the widget
/// that displays the rows.
/// User can interact.
/// {@endtemplate}
enum PlutoGridLoadingLevel {
  /// {@macro pluto_grid_loading_level_grid}
  grid,

  /// {@macro pluto_grid_loading_level_rows}
  rows,

  /// {@macro pluto_grid_loading_level_rowsBottomCircular}
  rowsBottomCircular;

  bool get isGrid => this == PlutoGridLoadingLevel.grid;

  bool get isRows => this == PlutoGridLoadingLevel.rows;

  bool get isRowsBottomCircular =>
      this == PlutoGridLoadingLevel.rowsBottomCircular;
}

enum _StackName {
  header,
  headerDivider,
  leftFrozenColumns,
  leftFrozenColumnFooters,
  leftFrozenRows,
  leftFrozenDivider,
  bodyColumns,
  bodyColumnFooters,
  bodyRows,
  rightFrozenColumns,
  rightFrozenColumnFooters,
  rightFrozenRows,
  rightFrozenDivider,
  columnRowDivider,
  columnFooterDivider,
  footer,
  footerDivider,
  loading,
  noRows,
}
