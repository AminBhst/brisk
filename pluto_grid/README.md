## PlutoGrid for flutter - v7.0.2

[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg)](https://github.com/Solido/awesome-flutter)
[![codecov](https://codecov.io/gh/bosskmk/pluto_grid/branch/master/graph/badge.svg)](https://codecov.io/gh/bosskmk/pluto_grid)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

<br>

`PlutoGrid` is a `DataGrid` that can be operated with the keyboard in various situations such as moving cells.  
It is developed with priority on the web and desktop.  
Improvements such as UI on mobile are being considered.  
If you comment on an issue, mobile improvements can be made quickly.

<br>

### [Demo Web](https://bosskmk.github.io/pluto_grid/build/web/index.html)
> You can try out various functions and usage methods right away.  
> All features provide example code.

<br>

### [Pub.Dev](https://pub.dev/packages/pluto_grid)
> Check out how to install from the official distribution site.

<br>

### [Documentation](https://pluto.weblaze.dev/series/pluto-grid)
> The documentation has more details.

<br>

### [ChangeLog](https://github.com/bosskmk/pluto_grid/blob/master/CHANGELOG.md)
> Please note the changes when changing the version of PlutoGrid you are using.

<br>

### [Issue](https://github.com/bosskmk/pluto_grid/issues)
> Report any questions or errors.

<br>

### Packages

> [PlutoGridExport](https://github.com/bosskmk/pluto_grid/tree/master/packages/pluto_grid_export)  
> This package can export the metadata of PlutoGrid as CSV or PDF.


<br>

### Screenshots

#### Change the color of the rows or make the cells look the way you want them.
![PlutoGrid Normal](https://bosskmk.github.io/images/pluto_grid/2.8.0/pluto_grid_2.8.0_01.png)

<br>

#### Date type input can be easily selected by pop-up and keyboard.
![PlutoGrid Select Popup](https://bosskmk.github.io/images/pluto_grid/3.1.0/pluto_grid_3.1.0_01.png)

<br>

#### The selection type column can be easily selected using a pop-up and keyboard.
![PlutoGrid Select Date](https://bosskmk.github.io/images/pluto_grid/2.8.0/pluto_grid_2.8.0_03.png)

<br>

#### Group columns by desired depth.
![PlutoGrid Cell renderer](https://bosskmk.github.io/images/pluto_grid/2.8.0/pluto_grid_2.8.0_04.png)

<br>

#### Grid can be expressed in dark mode or a combination of desired colors. Also, freeze the column, move it by dragging, or adjust the size.
![PlutoGrid Multi select](https://bosskmk.github.io/images/pluto_grid/2.8.0/pluto_grid_2.8.0_05.png)

<br>

### Example
Generate the data to be used in the grid.
```dart

List<PlutoColumn> columns = [
  /// Text Column definition
  PlutoColumn(
    title: 'text column',
    field: 'text_field',
    type: PlutoColumnType.text(),
  ),
  /// Number Column definition
  PlutoColumn(
    title: 'number column',
    field: 'number_field',
    type: PlutoColumnType.number(),
  ),
  /// Select Column definition
  PlutoColumn(
    title: 'select column',
    field: 'select_field',
    type: PlutoColumnType.select(['item1', 'item2', 'item3']),
  ),
  /// Datetime Column definition
  PlutoColumn(
    title: 'date column',
    field: 'date_field',
    type: PlutoColumnType.date(),
  ),
  /// Time Column definition
  PlutoColumn(
    title: 'time column',
    field: 'time_field',
    type: PlutoColumnType.time(),
  ),
];

List<PlutoRow> rows = [
  PlutoRow(
    cells: {
      'text_field': PlutoCell(value: 'Text cell value1'),
      'number_field': PlutoCell(value: 2020),
      'select_field': PlutoCell(value: 'item1'),
      'date_field': PlutoCell(value: '2020-08-06'),
      'time_field': PlutoCell(value: '12:30'),
    },
  ),
  PlutoRow(
    cells: {
      'text_field': PlutoCell(value: 'Text cell value2'),
      'number_field': PlutoCell(value: 2021),
      'select_field': PlutoCell(value: 'item2'),
      'date_field': PlutoCell(value: '2020-08-07'),
      'time_field': PlutoCell(value: '18:45'),
    },
  ),
  PlutoRow(
    cells: {
      'text_field': PlutoCell(value: 'Text cell value3'),
      'number_field': PlutoCell(value: 2022),
      'select_field': PlutoCell(value: 'item3'),
      'date_field': PlutoCell(value: '2020-08-08'),
      'time_field': PlutoCell(value: '23:59'),
    },
  ),
];
```

Create a grid with the data created above.
```dart
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('PlutoGrid Demo'),
    ),
    body: Container(
      padding: const EdgeInsets.all(30),
      child: PlutoGrid(
          columns: columns,
          rows: rows,
          onChanged: (PlutoGridOnChangedEvent event) {
            print(event);
          },
          onLoaded: (PlutoGridOnLoadedEvent event) {
            print(event);
          }
      ),
    ),
  );
}
```

<br>

### Flutter version compatible

| Flutter          | PlutoGrid             |
|------------------|-----------------------|
| 3.10.0 or higher | 7.0.0 or higher       |
| 3.7.0 or higher  | 6.0.0 or higher       |
| 3.3.0 or higher  | 5.0.6 or higher       |
| 3.0.0 or higher  | 3.0.0-0.pre or higher |
| 2.5.0 or higher  | 2.5.0 or higher       |

For other versions, contact the issue

<br>

### Related packages
> develop packages that make it easy to develop admin pages or CMS with Flutter.
* [PlutoGrid](https://github.com/bosskmk/pluto_grid)
* [PlutoMenuBar](https://github.com/bosskmk/pluto_menu_bar)
* [PlutoLayout](https://github.com/bosskmk/pluto_layout)

<br>

### Donate to this project

[![Buy me a coffee](https://www.buymeacoffee.com/assets/img/custom_images/white_img.png)](https://www.buymeacoffee.com/manki)

<br>

### Jetbrains provides a free license

[<img alt="IDE license support" src="https://resources.jetbrains.com/storage/products/company/brand/logos/jb_beam.png" width="170"/>](https://www.jetbrains.com/community/opensource/#support)
