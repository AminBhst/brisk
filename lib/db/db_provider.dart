import 'dart:io';

import 'package:brisk/db/db_queries.dart';
import 'package:brisk/util/file_util.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../util/settings_cache.dart';

class DBProvider {
  DBProvider._();

  static DBProvider? _instance = DBProvider._();

  static DBProvider get instance {
    _instance ??= DBProvider._();
    return _instance!;
  }

  Database? _database;

  Future<Database> get database async {
    return _database != null ? _database! : await getDB();
  }

  Future<Database> getDB({bool init = false}) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "Brisk", "brisk.db");
    var db = await databaseFactoryFfi.openDatabase(path);
    if (init) {
      await db.execute(DBQueries.createAllTables);
      await initSettings(db);
    }
    return db;
  }

  Future<void> initSettings(Database db) async {
    final downloadDir = await FileUtil.setDefaultSaveDir();
    final temporaryDir = await FileUtil.setDefaultTempDir();
    final defaultSettings = SettingsCache.defaultSettings;
    defaultSettings["savePath"]![1] = downloadDir.path;
    defaultSettings["temporaryPath"]![1] = temporaryDir.path;
    String insertQuery = "INSERT INTO setting (id, name, value, type) VALUES ";
    final len = defaultSettings.keys.length + 1;
    for (var i = 1; i < len; i++) {
      final key = defaultSettings.keys.elementAt(i - 1);
      final value = defaultSettings[key];
      insertQuery += "($i, '$key', '${value![1]}', '${value[0]}')";
      insertQuery += i == len - 1 ? ";" : ", ";
    }
    db.execute(insertQuery);
  }
}
