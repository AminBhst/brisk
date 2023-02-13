import 'package:brisk/dao/abstract_base_dao.dart';
import 'package:brisk/model/setting.dart';
import 'package:brisk/util/parse_util.dart';

class SettingDao extends AbstractBaseDao<Setting> {
  SettingDao._();

  static final SettingDao instance = SettingDao._();
  @override
  Map<String, Object> entityToMap(Setting entity) {
    return {
      "id": entity.id,
      "name": entity.name,
      "value": entity.value,
      "type": entity.type.name,
    };
  }

  @override
  Setting mapToEntity(Map<String, Object?> map) {
    return Setting(
      id: map["id"] as int,
      name: map["name"] as String,
      value: map["value"] as String,
      type: parseSettingType(map["type"] as String),
    );
  }

  @override
  String get tableName => "setting";

  Future<Setting> findByName(String name) async {
    final db = await database;
    final map =
        (await db.rawQuery('SELECT * FROM $tableName WHERE name = $name'))
            .first;
    return mapToEntity(map);
  }
}
