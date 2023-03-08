import 'package:brisk/model/download_queue.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../db/db_provider.dart';

abstract class AbstractManyToManyDao<E> {
  /// Singleton instance of the DBProvider
  final DBProvider dbProvider = DBProvider.instance;

  /// Provides the sqflite database object
  @protected
  Future<Database> get database async => await dbProvider.database;

  String get junctionTableName;

  String get tableName;

  String get joinedTableName;

  String get joinedTableIdColumnName => "id";

  String get tableIdColumnName => "id";

  String get junctionTableEntityIdColumnName;

  String get junctionTableJoinedEntityColumnName;

  E mapToEntity(List<Map<String, Object?>> map);

  List<E> multiMapToEntity(List<Map<String, Object?>> map);

  int getResultId(Map<String, Object?> map) => map["e.${tableIdColumnName}"] as int;

  Future<E> getById(int id) async {
    final result = await (await database)
        .rawQuery("$baseSelectQuery where e.${tableIdColumnName} = $id");
    return mapToEntity(result);
  }

  Future<int> getNewId() async {
    final db = await dbProvider.database;
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM $tableName");
    var id = table.first["id"];
    return id != null ? id as int : 1;
  }

  String get baseSelectQuery => "select * from $tableName e "
      "join $junctionTableName ju "
      "on e.${tableIdColumnName} = ju.${junctionTableEntityIdColumnName} "
      "join $joinedTableName j "
      "on j.${joinedTableIdColumnName} = ju.${junctionTableJoinedEntityColumnName} ";
}
