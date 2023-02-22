import 'package:brisk/db/db_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

/// This class is to be implemented by the concrete SQLite dao classes.
/// Provides common CRUD Operations by overriding some abstract methods.
/// [E] is the entity class which models the database table.
abstract class AbstractBaseDao<E> {
  /// Singleton instance of the DBProvider
  final DBProvider dbProvider = DBProvider.instance;

  String get tableName;

  /// Abstract method which maps the key-values to an entity object.
  /// [map] contains key value pairs of each column in the row
  /// e.g. for DownloadItem objects, the map will look like this :
  /// {
  ///       'id': entity.id,
  ///       'file_name': 'File.zip',
  ///       'download_url': 'a download link',
  ///       'start_date': '2022-05-31 05:41:42',
  ///       'finish_date': '2022-05-31 05:43:10',
  ///       'progress': '100',
  ///       'queue_order': '4',
  ///       'content_length': '471859200',
  /// }
  E mapToEntity(Map<String, Object?> map);

  /// َAbstract method which does the reverse of [mapToEntity].
  /// each property of the [entity] has to be paired with its value in the map.
  /// Note that the keys must correspond to the column names in the table.
  Map<String, Object> entityToMap(E entity);

  /// Provides the sqflite database object
  @protected
  Future<Database> get database async => await dbProvider.database;

  /// Gets the next id (primary key) from the table.
  /// This method is used to set the new primary key to the
  /// object for the save operation
  Future<int> getNewId() async {
    final db = await dbProvider.database;
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM $tableName");
    var id = table.first["id"];
    return id != null ? id as int : 1;
  }

  Future<int> save(E entity) async {
    final db = await database;
    var values = entityToMap(entity);
    values.remove("id");
    return db.insert(tableName, values);
  }

  Future<int> update(E entity) async {
    final map = entityToMap(entity);
    return (await database).update(tableName, map,
        conflictAlgorithm: ConflictAlgorithm.replace,
        where: "id = ${map["id"]}");
  }

  Future<void> deleteById(int id) async {
    final db = await database;
    await db.delete(tableName, where: "id = $id");
  }

  Future<E> getById(int id) async {
    final db = await database;
    var map =
        (await db.rawQuery('SELECT * FROM $tableName WHERE id = $id')).first;
    return mapToEntity(map);
  }

  Future<List<E>> getAll() async {
    final db = await database;
    final result = await db.rawQuery('SELECT * FROM $tableName');
    return result.map((e) => mapToEntity(e)).toList();
  }

  Future<void> deleteAllRows() async {
    final db = await database;
    await db.delete(tableName);
  }
}
